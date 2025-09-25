import 'package:camerawesome/camerawesome_plugin.dart' as aw;
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import '../model/id_fields.dart';
import 'id_ocr_parser.dart';

class CameraIdOcrPage extends StatefulWidget {
  const CameraIdOcrPage({super.key, this.onParsed});

  /// Called when OCR finishes successfully.
  final void Function(IdFields fields)? onParsed;

  @override
  State<CameraIdOcrPage> createState() => _CameraIdOcrPageState();
}

class _CameraIdOcrPageState extends State<CameraIdOcrPage> {
  PhotoCameraState? _photoState;
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan ID')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// The preview is drawn by CamerAwesome; we only draw the overlay UI.
          CameraAwesomeBuilder.custom(
            sensorConfig: SensorConfig.single(
              sensor: Sensor.position(SensorPosition.back),
              aspectRatio: CameraAspectRatios.ratio_16_9,
              flashMode: FlashMode.none,
            ),
            saveConfig: SaveConfig.photo(),
            previewFit: CameraPreviewFit.contain,
            imageAnalysisConfig: null,
            onMediaCaptureEvent: (aw.MediaCapture media) async {
              if (!media.isPicture ||
                  media.status != aw.MediaCaptureStatus.success)
                return;

              final filePath = media.captureRequest.when(
                single: (aw.SingleCaptureRequest single) => single.file?.path,
                multiple: (aw.MultipleCaptureRequest multi) =>
                    multi.fileBySensor.values.first?.path,
              );

              if (filePath != null) {
                await _runOcr(filePath);
              }
            },
            builder: (state, preview) => state.when(
              onPhotoMode: (photo) {
                _photoState ??= photo;
                return Stack(
                  children: [
                    // Simple guide frame
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * .86,
                        height: MediaQuery.of(context).size.height * .34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white70, width: 2),
                        ),
                      ),
                    ),

                    // Capture button
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 28,
                      child: Center(
                        child: FilledButton(
                          onPressed: _busy
                              ? null
                              : () => _photoState?.takePhoto(),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Take Photo'),
                        ),
                      ),
                    ),

                    // Flash toggle
                    Positioned(
                      right: 16,
                      top: 16,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black38,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.flash_on),
                        onPressed: () async {
                          final mode = _photoState?.sensorConfig.flashMode;
                          final next = switch (mode) {
                            FlashMode.none => FlashMode.auto,
                            FlashMode.auto => FlashMode.always,
                            FlashMode.always => FlashMode.none,
                            _ => FlashMode.none,
                          };
                          await _photoState?.sensorConfig.setFlashMode(next);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                );
              },
              // other states won't occur here, but must be returned
              onPreviewMode: (_) => const SizedBox.shrink(),
              onVideoMode: (_) => const SizedBox.shrink(),
              onVideoRecordingMode: (_) => const SizedBox.shrink(),
            ),
          ),

          if (_busy)
            Container(
              color: Colors.black38,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),

          if (_error != null && !_busy)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.error),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _runOcr(String filePath) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final fields = await IdOcrParser.scanFile(filePath);

      if (!mounted) return;
      if (widget.onParsed != null) {
        widget.onParsed!(fields);
        Navigator.of(context).maybePop();
      } else {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _ResultSheet(fields: fields),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'OCR failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Simple result display (replace with your Confirm page navigation)
class _ResultSheet extends StatelessWidget {
  const _ResultSheet({required this.fields});

  final IdFields fields;

  @override
  Widget build(BuildContext context) {
    Text _row(String k, String? v) =>
        Text('$k: ${v ?? '-'}', style: const TextStyle(fontSize: 14));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Parsed Fields',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _row('Name', fields.name),
              _row('ID Number', fields.idNumber),
              _row('EOI No', fields.eoiNo),
              _row('Nationality', fields.nationality),
              _row('Gender', fields.gender),
              _row('DOB', fields.dateOfBirth),
              _row('Issue', fields.dateOfIssue),
              _row('Expiry', fields.dateOfExpiry),
              _row('Place of Birth', fields.placeOfBirth),
              _row('Authority', fields.authority),
              const Divider(height: 20),
              const Text(
                'Raw OCR',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(fields.rawText, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
