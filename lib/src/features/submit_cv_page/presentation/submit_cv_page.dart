import 'dart:io';
import 'package:eps_client/src/features/submit_cv_page/controller/cv_controller.dart';
import 'package:eps_client/src/utils/async_value_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../common_widgets/custom_app_bar_view.dart';
import '../../../widgets/loading_view.dart';

class SubmitCvPage extends ConsumerStatefulWidget {
  const SubmitCvPage({super.key});

  @override
  ConsumerState<SubmitCvPage> createState() => _SubmitCvPageState();
}

class _SubmitCvPageState extends ConsumerState<SubmitCvPage> {
  static const _maxBytes = 5 * 1024 * 1024; /// 5 MB

  PlatformFile? _file;
  bool _uploading = false;
  double _progress = 0;

  Future<void> _pickCv() async {
    setState(() => _progress = 0);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'png', 'pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final f = result.files.first;
    final ext = (f.extension ?? '').toLowerCase();
    if (!['pdf', 'doc', 'docx'].contains(ext)) {
      _showSnack('Only PDF, DOC, DOCX are accepted.');
      return;
    }
    final size = f.size > 0 ? f.size : await File(f.path!).length();
    if (size > _maxBytes) {
      _showSnack('File too large. Max size is 5 MB.');
      return;
    }
    setState(() => _file = f);
  }

  Future<void> _uploadCv() async {
    if (_file?.path == null || _uploading) return;

    setState(() => _uploading = true);

    final ok = await ref
        .read(cvControllerProvider.notifier)
        .submit(File(_file!.path!));

    if (!mounted) return;
    setState(() => _uploading = false);

    if (ok) {
      _showSnack('CV uploaded successfully!');
    } else {
      _showSnack('Upload failed.');
    }
  }


  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final state = ref.watch(cvControllerProvider);

    ///show error dialog when network response error
    ref.listen<AsyncValue>(
      cvControllerProvider,
          (_, state) => state.showAlertDialogOnError(context),
    );

    return Scaffold(
      appBar: CustomAppBarView(title: 'Submit Your CV'),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  'Upload your resume so agents and employers can contact you with matching jobs.',
                  style: tt.bodyMedium?.copyWith(color: cs.outline),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                /// Upload tile (like your mock)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _pickCv,
                  child: Ink(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
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
                          child: Icon(Icons.upload_outlined, color: cs.outline),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _file == null ? 'Upload CV' : _file!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (_file != null)
                          TextButton(
                            onPressed: _pickCv,
                            child: const Text('Replace'),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  'Accepted formats: PDF, DOC, Max size 5 MB',
                  style: tt.bodySmall?.copyWith(color: cs.outline),
                ),

                if (_file != null) ...[
                  const SizedBox(height: 20),
                  _uploading
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 8),
                      Text('${(_progress * 100).toStringAsFixed(0)}%',
                          style: tt.bodySmall),
                    ],
                  )
                      : FilledButton(
                    onPressed: _uploadCv,
                    child: const Text('Submit CV'),
                  ),
                ],
              ],
            ),
          ),

          ///loading view
          if (state.isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: LoadingView(
                  indicatorColor: Colors.white,
                  indicator: Indicator.ballRotate,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
