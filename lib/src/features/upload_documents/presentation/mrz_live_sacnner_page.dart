import 'dart:async';
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../model/passport_mrz_vo.dart';

class LiveMrzScannerPage extends StatefulWidget {
  const LiveMrzScannerPage({
    super.key,
    this.onFound,
  });

  /// Called as soon as a TD3 MRZ is parsed.
  final void Function(PassportMrz mrz)? onFound;

  @override
  State<LiveMrzScannerPage> createState() => _LiveMrzScannerPageState();
}

class _LiveMrzScannerPageState extends State<LiveMrzScannerPage>
    with SingleTickerProviderStateMixin {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  DateTime _lastScan = DateTime.fromMillisecondsSinceEpoch(0);
  bool _busy = false;

  late final AnimationController _pulse =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarView(title: 'Scan'),
      body: CameraAwesomeBuilder.custom(
        previewFit: CameraPreviewFit.contain,
        previewAlignment: Alignment.center,
        previewPadding: EdgeInsets.zero,
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          aspectRatio: CameraAspectRatios.ratio_16_9,
          flashMode: FlashMode.none,
        ),
        saveConfig: SaveConfig.photo(),
        imageAnalysisConfig: AnalysisConfig(
          maxFramesPerSecond: 5,
          androidOptions: const AndroidAnalysisOptions.nv21(width: 640),
        ),

        onImageForAnalysis: _onImageForAnalysis,

        builder: (state, preview) => state.when(
          onPhotoMode: (_) => const _OverlayAlignedToPreview(
            aspect: 4 / 6,
            bandHeightRatio: .32,
            bandHorizontalPaddingRatio: .05,
            bandBottomPaddingRatio: 0.4,
          ),
          onPreviewMode: (_) => const _OverlayAlignedToPreview(),
          onVideoMode: (_) => const _OverlayAlignedToPreview(),
          onVideoRecordingMode: (_) => const _OverlayAlignedToPreview(),
        ),
      ),
    );
  }


  /// --------- analysis ---------
  Future<void> _onImageForAnalysis(AnalysisImage image) async {
    final now = DateTime.now();
    if (_busy || now.difference(_lastScan) < const Duration(milliseconds: 450)) {
      return;
    }
    _busy = true;
    _lastScan = now;

    try {
      final input = image.toMlkitInputImage();
      final text = await _recognizer.processImage(input);

      final lines = text.text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .map(_normalizeMrz)
          .toList();

      final mrzish = lines.where(_looksMrzLine).toList();
      if (mrzish.length < 2) return;

      List<String> candidate = [];

      for (int i = 0; i + 1 < mrzish.length; i++) {
        final a = mrzish[i], b = mrzish[i + 1];
        if (_isLikelyTd3First(a) && _looksMrzLine(b)) {
          candidate = [a, b];
        }
      }
      if (candidate.isEmpty) {
        candidate = mrzish.length >= 2
            ? [mrzish[mrzish.length - 2], mrzish[mrzish.length - 1]]
            : [];
      }

      if (candidate.length == 2) {
        final mrz = _parseTd3(candidate[0], candidate[1]);
        if (mrz != null) {
          if (mounted) {
            widget.onFound?.call(mrz);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('MRZ detected: ${mrz.documentNumber}')),
            );
          }
        }
      }
    } catch (e) {
      dev.log('MRZ scan error: $e');
    } finally {
      _busy = false;
    }
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// AnalysisImage → InputImage (camerawesome 2.5.x)
/// NV21 (Android) and BGRA8888 (iOS) with safe bytesPerRow defaults.
/// ─────────────────────────────────────────────────────────────────────────
extension _ToMlkit on AnalysisImage {
  InputImage toMlkitInputImage() {
    final InputImageRotation rot;
    switch (rotation) {
      case 90:  rot = InputImageRotation.rotation90deg;  break;
      case 180: rot = InputImageRotation.rotation180deg; break;
      case 270: rot = InputImageRotation.rotation270deg; break;
      case 0:
      default:  rot = InputImageRotation.rotation0deg;   break;
    }

    return when(
      nv21: (img) => InputImage.fromBytes(
        bytes: img.bytes,
        metadata: InputImageMetadata(
          size: img.size,
          rotation: rot,
          format: InputImageFormat.nv21,
          bytesPerRow: img.size.width.toInt(),
        ),
      ),
      bgra8888: (img) => InputImage.fromBytes(
        bytes: img.bytes,
        metadata: InputImageMetadata(
          size: img.size,
          rotation: rot,
          format: InputImageFormat.bgra8888,
          bytesPerRow: img.size.width.toInt() * 4,
        ),
      ),
    )!;
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// Overlay (transparent rounded window + border)
/// ─────────────────────────────────────────────────────────────────────────
class _MrzOverlayMask extends StatelessWidget {
  const _MrzOverlayMask();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _MrzOverlayPainter());
}

class _MrzOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hole = _frame(size);
    final full = Offset.zero & size;

    // dim layer with punched hole
    canvas.saveLayer(full, Paint());
    canvas.drawRect(full, Paint()..color = const Color(0xAA000000));
    canvas.drawRRect(
      RRect.fromRectAndRadius(hole, const Radius.circular(16)),
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();

    // border
    canvas.drawRRect(
      RRect.fromRectAndRadius(hole, const Radius.circular(16)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  Rect _frame(Size s) {
    final w = s.width * 0.88;
    final h = s.height * 0.22; // MRZ band
    final left = (s.width - w) / 2;
    final top = s.height * 0.62;
    return Rect.fromLTWH(left, top, w, h);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MrzOverlayClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final r = _frame(size);
    return Path()..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(16)));
  }

  Rect _frame(Size s) {
    final w = s.width * 0.88;
    final h = s.height * 0.22;
    final left = (s.width - w) / 2;
    final top = s.height * 0.62;
    return Rect.fromLTWH(left, top, w, h);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// ─────────────────────────────────────────────────────────────────────────
/// MRZ helpers & TD3 parser
/// ─────────────────────────────────────────────────────────────────────────
String _normalizeMrz(String s) =>
    s.toUpperCase().replaceAll(' ', '').replaceAll('«', '<').replaceAll('‹', '<').replaceAll('>', '<');

bool _looksMrzLine(String s) =>
    RegExp(r'^[A-Z0-9<]{20,}$').hasMatch(s) && s.countChar('<') >= 3;

bool _isLikelyTd3First(String s) =>
    s.startsWith('P<') && s.length >= 35 && s.countChar('<') >= 4;

extension on String {
  int countChar(String c) => split('').where((e) => e == c).length;
}

/// Parse TD3 (2 lines, 44 chars each). Be tolerant to lengths.
PassportMrz? _parseTd3(String l1, String l2) {
  try {
    // pad to length 44 if shorter (tolerant)
    l1 = l1.padRight(44, '<');
    l2 = l2.padRight(44, '<');

    // L1
    // 0-1: 'P<'
    final issuing = l1.substring(2, 5);
    final namesRaw = l1.substring(5, 44);
    final parts = namesRaw.split('<<');
    final primary = parts.isNotEmpty ? parts[0].replaceAll('<', ' ').trim() : '';
    final secondary = parts.length > 1 ? parts[1].replaceAll('<', ' ').trim() : '';

    // L2
    final docNumber = l2.substring(0, 9).replaceAll('<', '');
    // l2[9] check digit (ignored)
    final nationality = l2.substring(10, 13).replaceAll('<', '');
    final dobStr = l2.substring(13, 19); // YYMMDD
    // l2[19] check digit (ignored)
    final sex = l2.substring(20, 21);
    final expStr = l2.substring(21, 27); // YYMMDD
    // l2[27] check digit (ignored)
    // personal number: 28..42 (ignored)
    // l2[43] composite check (ignored)

    final dob = _parseMrzDate(dobStr);
    final exp = _parseMrzDate(expStr, isExpiry: true);

    return PassportMrz(
      issuingCountry: issuing,
      documentNumber: docNumber,
      nationality: nationality,
      birthDate: dob,
      sex: sex,
      expiryDate: exp,
      primaryIdentifier: primary,
      secondaryIdentifier: secondary,
    );
  } catch (e) {
    dev.log('TD3 parse error: $e');
    return null;
  }
}

DateTime? _parseMrzDate(String yymmdd, {bool isExpiry = false}) {
  if (yymmdd.length < 6) return null;
  final yy = int.tryParse(yymmdd.substring(0, 2));
  final mm = int.tryParse(yymmdd.substring(2, 4));
  final dd = int.tryParse(yymmdd.substring(4, 6));
  if (yy == null || mm == null || dd == null) return null;

  final now = DateTime.now();
  final nowYY = now.year % 100;
  final year = isExpiry
      ? (yy < nowYY + 20 ? 2000 + yy : 1900 + yy) // bias to future-ish
      : (yy <= nowYY ? 2000 + yy : 1900 + yy);
  try {
    return DateTime(year, mm, dd);
  } catch (_) {
    return null;
  }
}


class _OverlayAlignedToPreview extends StatelessWidget {
  const _OverlayAlignedToPreview({
    super.key,
    this.aspect = 4 / 3,
    this.bandHeightRatio = .32,
    this.bandHorizontalPaddingRatio = .05,
    this.bandBottomPaddingRatio = .04,
  });

  final double aspect;
  final double bandHeightRatio;
  final double bandHorizontalPaddingRatio;
  final double bandBottomPaddingRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth, h = c.maxHeight;
      final screenAR = w / h;

      // Compute the centered preview rect for the given aspect
      late double pw, ph;
      if (screenAR > aspect) { ph = h; pw = h * aspect; } else { pw = w; ph = w / aspect; }
      final left = (w - pw) / 2;
      final top  = (h - ph) / 2;

      // MRZ band metrics
      final bandH = ph * bandHeightRatio.clamp(.20, .50);
      final bandW = pw * (1 - 2 * bandHorizontalPaddingRatio);
      final bandLeft = left + pw * bandHorizontalPaddingRatio;
      final bandTop  = top + ph - bandH - ph * bandBottomPaddingRatio;

      final mrzRect = Rect.fromLTWH(bandLeft, bandTop, bandW, bandH);

      return Stack(children: [
        /// Dim everything
        Container(color: const Color(0xAA000000)),
        /// Cut out the MRZ band + border
        Positioned.fromRect(rect: mrzRect, child: CustomPaint(painter: _CutoutPainter())),
        /// Helper text
        Positioned(
          left: 16, right: 16, bottom: 24,
          child: Text(
            'Align MRZ inside the frame',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70, fontWeight: FontWeight.w600),
          ),
        ),
      ]);
    });
  }
}

class _CutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.saveLayer(r, Paint());
    canvas.drawRect(r, Paint()..blendMode = BlendMode.clear); // punch hole
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(16)),
      Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.white,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
