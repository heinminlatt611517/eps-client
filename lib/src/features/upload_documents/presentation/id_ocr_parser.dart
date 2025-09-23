import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../model/id_fields.dart';

class IdOcrParser {
  static final _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// OCR any image file path and return parsed fields
  static Future<IdFields> scanFile(String filePath) async {
    final input = InputImage.fromFilePath(filePath);
    final text = await _recognizer.processImage(input);
    return _parse(text);
  }

  /// Use this if you already have an InputImage (e.g., from a live camera)
  static Future<IdFields> scanInputImage(InputImage image) async {
    final text = await _recognizer.processImage(image);
    return _parse(text);
  }

  static IdFields _parse(RecognizedText recognized) {
    final raw = recognized.text
        .replaceAll('‹', '<')
        .replaceAll('«', '<')
        .replaceAll('—', '-');

    final lines = recognized.blocks
        .expand((b) => b.lines.map((l) => l.text))
        .toList();
    // Upper and compact for label matching
    final uLines = lines.map((e) => e.toUpperCase()).toList();

    String? _after(List<String> ls, List<String> labels) {
      for (int i = 0; i < ls.length; i++) {
        for (final lab in labels) {
          if (ls[i].contains(lab)) {
            // Value may be after ":" or on next line
            final rawLine = lines[i];
            final v = rawLine.split(':').length > 1
                ? rawLine.split(':').last.trim()
                : (i + 1 < lines.length ? lines[i + 1].trim() : null);
            if (v != null && v.isNotEmpty) return v;
          }
        }
      }
      return null;
    }

    String? _searchByRegex(RegExp r) {
      final m = r.firstMatch(raw);
      return m == null ? null : m.group(0);
    }

    String? _dateToIso(String s) {
      final src = s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\s/-]'), ' ');
      final monthMap = {
        'JAN': 1,
        'FEB': 2,
        'MAR': 3,
        'APR': 4,
        'MAY': 5,
        'JUN': 6,
        'JUL': 7,
        'AUG': 8,
        'SEP': 9,
        'OCT': 10,
        'NOV': 11,
        'DEC': 12,
      };

      final m1 = RegExp(
        r'\b(\d{1,2})\s+([A-Z]{3})\s+(\d{2,4})\b',
      ).firstMatch(src);
      if (m1 != null) {
        final d = int.parse(m1.group(1)!);
        final mon = monthMap[m1.group(2)!] ?? 1;
        var y = int.parse(m1.group(3)!);
        if (y >= 2400) y -= 543; // BE → CE
        if (y < 100) y += (y >= 50 ? 1900 : 2000);
        return _safeIso(y, mon, d);
      }

      // dd-MM-yyyy / dd/MM/yyyy
      final m2 = RegExp(
        r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})\b',
      ).firstMatch(src);
      if (m2 != null) {
        final d = int.parse(m2.group(1)!);
        final mon = int.parse(m2.group(2)!);
        var y = int.parse(m2.group(3)!);
        if (y >= 2400) y -= 543;
        if (y < 100) y += (y >= 50 ? 1900 : 2000);
        return _safeIso(y, mon, d);
      }

      // yyyy-MM-dd
      final m3 = RegExp(
        r'\b(20\d{2}|19\d{2})-(\d{1,2})-(\d{1,2})\b',
      ).firstMatch(src);
      if (m3 != null) {
        final y = int.parse(m3.group(1)!);
        final mon = int.parse(m3.group(2)!);
        final d = int.parse(m3.group(3)!);
        return _safeIso(y, mon, d);
      }

      return null;
    }

    String? _extractDateNearLabels(List<String> labels) {
      final idx = uLines.indexWhere(
        (l) => labels.any((lab) => l.contains(lab)),
      );
      if (idx == -1) return null;
      final window = [
        if (idx > 0) lines[idx - 1],
        lines[idx],
        if (idx + 1 < lines.length) lines[idx + 1],
      ].join(' ');
      return _dateToIso(window);
    }

    String _cleanName(String v) =>
        v.replaceAll(RegExp(r'\s+'), ' ').replaceAll('<', ' ').trim();

    String? _digits13(String s) {
      final only = s.replaceAll(RegExp(r'\D'), '');
      final m = RegExp(r'\d{13}').firstMatch(only);
      return m?.group(0);
    }

    final out = IdFields(rawText: raw);

    // ID / EOI patterns
    out.eoiNo = _after(uLines, ['EOI', 'EOI NO', 'EOINO']);
    out.idNumber =
        _after(uLines, [
          'ID NO',
          'ID NUMBER',
          'CARD NO',
          'NO.',
          'REF NO',
          'E0I NO',
          'EOI NO',
        ]) ??
        _searchByRegex(RegExp(r'\b[A-Z]{1,3}\d{6,10}\b')) ??
        _digits13(raw);

    // Name
    out.name =
        _after(uLines, [
          'NAME',
          'SURNAME',
          'GIVEN NAME',
          'GIVEN NAMES',
        ])?.let(_cleanName) ??
        _guessName(lines);

    // Nationality
    out.nationality = _after(uLines, [
      'NATIONALITY',
      'COUNTRY',
      'COUNTRY CODE',
    ]);

    // Gender
    out.gender =
        _after(uLines, ['GENDER', 'SEX']) ??
        RegExp(r'\b([MF])\b').firstMatch(raw)?.group(1);

    // Place of birth & Authority
    out.placeOfBirth = _after(uLines, ['PLACE OF BIRTH', 'BIRTH PLACE']);
    out.authority = _after(uLines, ['AUTHORITY', 'ISSUED BY']);

    // Dates
    out.dateOfBirth =
        _extractDateNearLabels(['DATE OF BIRTH', 'DOB']) ?? _dateToIso(raw);
    out.dateOfIssue = _extractDateNearLabels(['DATE OF ISSUE', 'ISSUE DATE']);
    out.dateOfExpiry = _extractDateNearLabels([
      'DATE OF EXPIRY',
      'EXPIRY DATE',
      'EXPIRE',
      'DATE OF EXPIRE',
    ]);

    return out;
  }

  static String? _guessName(List<String> lines) {
    // Heuristic: longest line with ≥2 words, mostly letters/spaces, near “Name” text region.
    final cands = lines.where((l) {
      final w = l.trim().split(RegExp(r'\s+'));
      final lettersRatio =
          l.replaceAll(RegExp(r'[^A-Za-z\s]'), '').length / l.length;
      return w.length >= 2 && lettersRatio > 0.7 && l.length <= 40;
    }).toList();
    cands.sort((a, b) => b.length.compareTo(a.length));
    return cands.isNotEmpty ? cands.first.trim() : null;
  }
}

// tiny safe date builder
String? _safeIso(int y, int m, int d) {
  try {
    final dt = DateTime(y, m, d);
    if (dt.year == y && dt.month == m && dt.day == d) {
      return '${y.toString().padLeft(4, '0')}-'
          '${m.toString().padLeft(2, '0')}-'
          '${d.toString().padLeft(2, '0')}';
    }
  } catch (_) {}
  return null;
}

// small “let” helper
extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
