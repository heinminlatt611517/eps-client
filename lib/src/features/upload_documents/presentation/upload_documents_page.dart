import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../common_widgets/custom_app_bar_view.dart';
import '../../confirm_document/presentation/confirm_document_page.dart';
import 'camera_id_ocr_page.dart';
import 'mrz_live_sacnner_page.dart';

class UploadDocumentsPage extends StatefulWidget {
  const UploadDocumentsPage({super.key, this.title = 'Upload Passport/ Visa'});

  final String title;

  @override
  State<UploadDocumentsPage> createState() => _UploadDocumentsPageState();
}

class _UploadDocumentsPageState extends State<UploadDocumentsPage> {
  static const _maxBytes = 5 * 1024 * 1024;

  /// 5 MB
  PlatformFile? _file;
  bool _uploading = false;
  double _progress = 0.0;
  String? _lastError;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickFile() async {
    setState(() {
      _progress = 0;
      _lastError = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final f = result.files.first;
    final ext = (f.extension ?? '').toLowerCase();
    if (!['pdf', 'doc', 'docx'].contains(ext)) {
      _showSnack('Only PDF, DOC, DOCX are accepted.');
      return;
    }

    final bytes = f.size > 0 ? f.size : await File(f.path!).length();
    if (bytes > _maxBytes) {
      _showSnack('File too large. Max size is 5 MB.');
      return;
    }

    setState(() => _file = f);
  }

  Future<void> _uploadFile() async {
    if (_file?.path == null) return;

    // TODO: Replace this simulated upload with your backend call (e.g., Dio multipart)
    setState(() {
      _uploading = true;
      _progress = 0.0;
    });

    for (int i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 70));
      if (!mounted) return;
      setState(() => _progress = i / 20);
    }

    if (!mounted) return;
    setState(() => _uploading = false);
    _showSnack('File uploaded successfully!');
    // Optionally clear the selection:
    // setState(() => _file = null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBarView(title: 'Upload Passport/ Visa'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            /// Scan flow (kept as-is)
            UploadActionTile(
              icon: Icons.document_scanner_outlined,
              label: 'Scan Document',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveMrzScannerPage(
                      onFound: (mrz) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ConfirmDetailsPage(mrz: mrz),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            UploadActionTile(
              icon: Icons.upload_file_outlined,
              label: 'Upload File',
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraIdOcrPage(
                      onParsed: (fields) {
                        debugPrint("Id Number>>>>>${fields.idNumber}");
                        debugPrint("Fields Name>>>>>${fields.name}");
                        debugPrint("Date of birth>>>>>${fields.dateOfBirth}");
                        debugPrint("Issue date>>>>>${fields.dateOfIssue}");
                        debugPrint("Expire date>>>>>${fields.dateOfExpiry}");
                      },
                    ),
                  ),
                );
              },
            ),

            if (_file != null) ...[
              const SizedBox(height: 16),
              _SelectedFileCard(
                file: _file!,
                uploading: _uploading,
                progress: _progress,
                onReplace: _pickFile,
                onUpload: _uploading ? null : _uploadFile,
              ),
            ],

            if (_lastError != null) ...[
              const SizedBox(height: 8),
              Text(_lastError!, style: TextStyle(color: cs.error)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small card that shows the picked file and upload actions.
class _SelectedFileCard extends StatelessWidget {
  const _SelectedFileCard({
    required this.file,
    required this.uploading,
    required this.progress,
    required this.onReplace,
    required this.onUpload,
  });

  final PlatformFile file;
  final bool uploading;
  final double progress;
  final VoidCallback onReplace;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected file', style: tt.titleSmall),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.insert_drive_file, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(onPressed: onReplace, child: const Text('Replace')),
            ],
          ),
          const SizedBox(height: 8),
          if (uploading) ...[
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: tt.bodySmall?.copyWith(color: cs.outline),
            ),
          ] else
            FilledButton(onPressed: onUpload, child: const Text('Upload')),
        ],
      ),
    );
  }
}

/// Reusable rounded tile
class UploadActionTile extends StatelessWidget {
  const UploadActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.surfaceVariant.withOpacity(.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: cs.outline),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}
