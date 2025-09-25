import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../model/id_fields.dart';

class IdOcrParser {
  static final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<IdFields> scanFile(String filePath) async {
    final input = InputImage.fromFilePath(filePath);
    final text = await _recognizer.processImage(input);
    return _parse(text);
  }

  static Future<IdFields> scanInputImage(InputImage image) async {
    final text = await _recognizer.processImage(image);
    return _parse(text);
  }

  // Label sets
  static const _DOB = ['DATE OF BIRTH', 'DOB', 'BIRTH DATE', 'BORN', 'D.O.B'];
  static const _DOI = ['DATE OF ISSUE', 'ISSUE DATE', 'DATE OF ISSUED', 'ISSUED DATE', 'DATE OF DELIVERY'];
  static const _DOE = ['DATE OF EXPIRY', 'EXPIRY DATE', 'DATE OF EXPIRE', 'EXPIRATION DATE', 'VALID UNTIL', 'EXPIRES'];
  static const _POB = ['PLACE OF BIRTH', 'BIRTH PLACE', 'PLACE OF BORN'];

  static IdFields _parse(RecognizedText recognized) {
    final raw = recognized.text
        .replaceAll('‹', '<')
        .replaceAll('«', '<')
        .replaceAll('—', '-');

    // Lines and uppercase twin
    final lines = recognized.blocks
        .expand((b) => b.lines.map((l) => l.text.trim()))
        .where((l) => l.isNotEmpty)
        .toList();
    final uLines = lines.map((e) => e.toUpperCase()).toList();

    // Collect all date hits with their line index
    final hits = _collectDateHits(lines);

    final out = IdFields(rawText: raw);

    // --- Basic fields (kept from before) ---
    out.eoiNo = _valueAfter(uLines, lines, ['EOI', 'EOI NO', 'EOINO']);
    out.idNumber = _valueAfter(uLines, lines, [
      'ID NO', 'ID NUMBER', 'CARD NO', 'NO.', 'REF NO', 'E0I NO', 'EOI NO',
    ]) ??
        _firstMatch(raw, RegExp(r'\b[A-Z]{1,3}\d{6,12}\b')) ??
        _firstMatch(raw, RegExp(r'\b\d{9,13}\b'));

    out.name = _extractName(lines, uLines);
    out.nationality = _valueAfter(uLines, lines, ['NATIONALITY', 'COUNTRY', 'COUNTRY CODE']);
    out.gender = _valueAfter(uLines, lines, ['GENDER', 'SEX']) ??
        RegExp(r'\b([MF])\b').firstMatch(raw)?.group(1);
    out.placeOfBirth = _valueAfter(uLines, lines, _POB, takeNextIfEmpty: true);

    // --- Dates by nearest label (first pass, most reliable) ---
    out.dateOfBirth  = _nearestDateToLabels(uLines, hits, _DOB);
    out.dateOfIssue  = _nearestDateToLabels(uLines, hits, _DOI);
    out.dateOfExpiry = _nearestDateToLabels(uLines, hits, _DOE);

    // --- MRZ fallback for DOB/DOE ---
    final mrz = _tryParseMrz(raw);
    out.dateOfBirth  ??= mrz?.dob;
    out.dateOfExpiry ??= mrz?.expiry;

    // --- Heuristics fallback if still missing ---
    final allIso = hits.map((h) => h.iso).toList()..addAll(_allIsoDates(raw));
    final uniqIso = {...allIso}.toList()..sort();

    if (out.dateOfBirth == null && uniqIso.isNotEmpty) {
      out.dateOfBirth = _chooseDob(uniqIso);
    }
    if (out.dateOfExpiry == null && uniqIso.isNotEmpty) {
      out.dateOfExpiry = _chooseDoe(uniqIso);
    }
    if (out.dateOfIssue == null && uniqIso.isNotEmpty) {
      out.dateOfIssue = _chooseDoi(
        uniqIso,
        dobIso: out.dateOfBirth,
        doeIso: out.dateOfExpiry,
      );
    }

    // Avoid identical Issue/Expiry if 2+ distinct dates exist:
    if (out.dateOfIssue != null &&
        out.dateOfExpiry != null &&
        out.dateOfIssue == out.dateOfExpiry &&
        uniqIso.length >= 2) {
      // Try pick another reasonable issue date (latest past distinct from expiry)
      final pastDates = uniqIso.map(DateTime.parse)
          .where((d) => d.isBefore(DateTime.now()))
          .toList()
        ..sort();
      if (pastDates.isNotEmpty) {
        final pick = pastDates.last;
        if (_iso(pick) != out.dateOfExpiry) {
          out.dateOfIssue = _iso(pick);
        }
      }
    }

    return out;
  }

  // ---------- VALUE HELPERS ----------
  static String? _valueAfter(
      List<String> upper,
      List<String> orig,
      List<String> labels, {
        bool takeNextIfEmpty = true,
      }) {
    for (int i = 0; i < upper.length; i++) {
      final u = upper[i];
      for (final lab in labels) {
        if (u.contains(lab)) {
          final same = _rightOfLabel(orig[i], lab);
          if (_isMeaningful(same)) return _cleanField(same!);

          if (takeNextIfEmpty && i + 1 < orig.length && !upper[i + 1].contains('ALSO KNOWN AS')) {
            final next = orig[i + 1].trim();
            if (_isMeaningful(next)) return _cleanField(next);
          }
        }
      }
    }
    return null;
  }

  static String? _rightOfLabel(String line, String labelUpper) {
    final u = line.toUpperCase();
    final idx = u.indexOf(labelUpper);
    if (idx == -1) return null;
    var tail = line.substring(idx + labelUpper.length);
    tail = tail.replaceFirst(RegExp(r'^[\s:\-–—]+'), '');
    return tail.isEmpty ? null : tail;
  }

  static bool _isMeaningful(String? s) =>
      s != null && s.trim().isNotEmpty && s.trim() != '-' && s.trim().length > 1;

  static String _cleanField(String v) =>
      v.replaceAll(RegExp(r'\s+'), ' ').replaceAll('<', ' ').trim();

  // ---------- NAME ----------
  static String? _extractName(List<String> lines, List<String> uLines) {
    for (int i = 0; i < uLines.length; i++) {
      if (uLines[i].contains('NAME')) {
        final same = _rightOfLabel(lines[i], 'NAME');
        if (_isMeaningful(same)) {
          final cleaned = _cleanName(_stripAka(same!));
          if (_nameLooksValid(cleaned)) return cleaned;
        }
        if (i + 1 < lines.length && !uLines[i + 1].contains('ALSO KNOWN AS')) {
          final cleaned = _cleanName(lines[i + 1]);
          if (_nameLooksValid(cleaned)) return cleaned;
        }
      }
    }

    final given = _valueAfter(uLines, lines, ['GIVEN NAME', 'GIVEN NAMES']);
    final sur   = _valueAfter(uLines, lines, ['SURNAME', 'LAST NAME']);
    if (_isMeaningful(given) && _isMeaningful(sur)) {
      final full = _cleanName('$given $sur');
      if (_nameLooksValid(full)) return full;
    }

    return _guessName(lines);
  }

  static String _cleanName(String v) =>
      v.replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll('<', ' ')
          .replaceAll(RegExp(r"[^A-Za-z\s\-'.]"), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

  static bool _nameLooksValid(String v) => v.split(' ').length >= 2 && v.length <= 40;
  static String _stripAka(String v) =>
      v.replaceAll(RegExp(r'ALSO\s+KNOWN\s+AS.*$', caseSensitive: false), '').trim();

  static String? _guessName(List<String> lines) {
    final cands = lines.where((l) {
      final w = l.trim().split(RegExp(r'\s+'));
      final onlyLetters = l.replaceAll(RegExp(r"[^A-Za-z\s\-'.]"), '');
      final ratio = onlyLetters.isEmpty ? 0.0 : onlyLetters.length / l.length;
      return w.length >= 2 && ratio > 0.7 && l.length <= 40;
    }).toList();
    cands.sort((a, b) => b.length.compareTo(a.length));
    return cands.isNotEmpty ? cands.first.trim() : null;
  }

  // ---------- DATES & NEAREST-LABEL SELECTION ----------
  static String? _nearestDateToLabels(
      List<String> uLines,
      List<_DateHit> hits,
      List<String> labels, {
        int window = 4,
      }) {
    final labelIdxs = <int>[];
    for (int i = 0; i < uLines.length; i++) {
      if (labels.any((lab) => uLines[i].contains(lab))) labelIdxs.add(i);
    }
    if (labelIdxs.isEmpty || hits.isEmpty) return null;

    _DateHit? best;
    int bestDist = 1 << 30;

    for (final li in labelIdxs) {
      // Prefer date found on same line tail
      // (Quick check: try to parse only the right-of-label tail)
      for (final lab in labels) {
        if (uLines[li].contains(lab)) {
          final tail = _rightOfLabel(uLines[li], lab);
          if (tail != null) {
            final iso = _firstIsoDate(tail);
            if (iso != null) return iso;
          }
        }
      }

      for (final h in hits) {
        final d = (h.line - li).abs();
        if (d <= window && d < bestDist) {
          best = h;
          bestDist = d;
        }
      }
    }
    return best?.iso;
  }

  static List<_DateHit> _collectDateHits(List<String> lines) {
    final hits = <_DateHit>[];
    for (int i = 0; i < lines.length; i++) {
      final found = _allIsoDates(lines[i]);
      for (final iso in found) {
        hits.add(_DateHit(iso: iso, line: i, dt: DateTime.parse(iso)));
      }
    }
    // Dedup (iso+line)
    final keyed = <String, _DateHit>{};
    for (final h in hits) {
      keyed['${h.iso}@${h.line}'] = h;
    }
    return keyed.values.toList();
  }

  static String? _firstIsoDate(String src) {
    final all = _allIsoDates(src);
    return all.isEmpty ? null : all.first;
  }

  static List<String> _allIsoDates(String src) {
    final s = src.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\s/:\-]'), ' ');
    final monthShort = {
      'JAN':1,'FEB':2,'MAR':3,'APR':4,'MAY':5,'JUN':6,
      'JUL':7,'AUG':8,'SEP':9,'OCT':10,'NOV':11,'DEC':12,
    };
    final monthFull = {
      'JANUARY':1,'FEBRUARY':2,'MARCH':3,'APRIL':4,'MAY':5,'JUNE':6,
      'JULY':7,'AUGUST':8,'SEPTEMBER':9,'OCTOBER':10,'NOVEMBER':11,'DECEMBER':12,
    };

    final out = <DateTime>[];

    // dd MMM yyyy
    for (final m in RegExp(r'\b(\d{1,2})\s+([A-Z]{3})\s+(\d{2,4})\b').allMatches(s)) {
      out.add(_mkDate(m.group(3)!, monthShort[m.group(2)!] ?? 1, m.group(1)!));
    }
    // dd MMMM yyyy
    for (final m in RegExp(r'\b(\d{1,2})\s+([A-Z]{4,9})\s+(\d{2,4})\b').allMatches(s)) {
      final mon = monthFull[m.group(2)!];
      if (mon != null) out.add(_mkDate(m.group(3)!, mon, m.group(1)!));
    }
    // dd/MM/yyyy or dd-MM-yyyy or dd/MM/yy
    for (final m in RegExp(r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})\b').allMatches(s)) {
      out.add(_mkDate(m.group(3)!, int.parse(m.group(2)!), m.group(1)!));
    }
    // yyyy-MM-dd
    for (final m in RegExp(r'\b(20\d{2}|19\d{2})-(\d{1,2})-(\d{1,2})\b').allMatches(s)) {
      out.add(DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!)));
    }

    // Dedup + sort
    final uniq = <String, DateTime>{};
    for (final d in out) {
      uniq[_iso(d)] = d;
    }
    final sorted = uniq.values.toList()..sort();
    return sorted.map(_iso).toList();
  }

  static DateTime _mkDate(String yRaw, int m, String dRaw) {
    var y = int.parse(yRaw);
    if (y >= 2400) y -= 543;                 // Thai BE → CE
    if (y < 100) y += (y >= 50 ? 1900 : 2000);
    final d = int.parse(dRaw);
    return DateTime(y, m, d);
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  // ---------- Heuristic picks ----------
  static String? _chooseDob(List<String> allIso) {
    final now = DateTime.now();
    final ds = allIso.map(DateTime.parse).where((d) => d.isBefore(now) && d.year >= 1900).toList()
      ..sort();
    return ds.isEmpty ? null : _iso(ds.first);
  }

  static String? _chooseDoe(List<String> allIso) {
    final now = DateTime.now();
    final ds = allIso.map(DateTime.parse).toList()..sort();
    final future = ds.where((d) => !d.isBefore(now)).toList();
    return _iso((future.isNotEmpty ? future.last : ds.last));
  }

  static String? _chooseDoi(List<String> allIso, {String? dobIso, String? doeIso}) {
    final now = DateTime.now();
    final ds = allIso.map(DateTime.parse).toList()..sort();
    final dob = dobIso != null ? DateTime.parse(dobIso) : null;
    final doe = doeIso != null ? DateTime.parse(doeIso) : null;

    // Prefer a date after DOB & before DOE, and in the past
    DateTime? pick = ds.reversed.firstWhere(
          (d) => d.isBefore(now) && (dob == null || d.isAfter(dob)) && (doe == null || d.isBefore(doe)),
      orElse: () => ds.reversed.firstWhere(
            (d) => d.isBefore(now),
        orElse: () => ds.first,
      ),
    );
    return _iso(pick);
  }

  // ---------- MRZ (2 lines) ----------
  static _MrzDates? _tryParseMrz(String raw) {
    final lines = raw.split(RegExp(r'[\r\n]+'))
        .map((e) => e.trim().replaceAll(' ', '').replaceAll('‹', '<').replaceAll('«', '<'))
        .where((e) => e.isNotEmpty)
        .toList();

    final mrzish = lines.where((t) => RegExp(r'^[A-Z0-9<]{25,}$').hasMatch(t)).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    if (mrzish.length < 2) return null;
    final l2 = mrzish[1];

    final yyMMdd = RegExp(r'(\d{2})(\d{2})(\d{2})');
    final mAll = yyMMdd.allMatches(l2).toList();
    if (mAll.length >= 2) {
      final dob = _mrzDateToIso(mAll[0].group(0)!);
      final exp = _mrzDateToIso(mAll[1].group(0)!);
      return _MrzDates(dob: dob, expiry: exp);
    }
    return null;
  }

  static String? _mrzDateToIso(String yymmdd) {
    if (yymmdd.length != 6) return null;
    final yy = int.parse(yymmdd.substring(0, 2));
    final mm = int.parse(yymmdd.substring(2, 4));
    final dd = int.parse(yymmdd.substring(4, 6));
    final nowYY = DateTime.now().year % 100;
    final year = (yy <= nowYY ? 2000 + yy : 1900 + yy);
    try {
      return _iso(DateTime(year, mm, dd));
    } catch (_) {
      return null;
    }
  }

  static String? _firstMatch(String s, RegExp r) => r.firstMatch(s)?.group(0);
}

class _DateHit {
  final String iso;
  final int line;
  final DateTime dt;
  _DateHit({required this.iso, required this.line, required this.dt});
}

class _MrzDates {
  final String? dob;
  final String? expiry;
  _MrzDates({this.dob, this.expiry});
}
