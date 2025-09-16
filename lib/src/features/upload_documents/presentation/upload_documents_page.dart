import 'package:flutter/material.dart';

import '../../../common_widgets/custom_app_bar_view.dart';
import '../../confirm_document/presentation/confirm_document_page.dart';

class UploadDocumentsPage extends StatelessWidget {
  const UploadDocumentsPage({
    super.key,
    this.title = 'Upload Passport/ Visa',
  });

  final String title;

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
            UploadActionTile(
              icon: Icons.document_scanner_outlined,
              label: 'Scan Document',
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfirmDocumentPage(
                      details: DocumentDetails(
                        passportNumber: 'MG123456',
                        dateOfBirth: DateTime(1987, 9, 15),
                        nationality: 'Myanmar',
                        gender: 'Male',
                        expiryDate: DateTime(2027, 9, 15),
                      ),
                    ),
                  ),
                );

              },
            ),
            const SizedBox(height: 14),
            UploadActionTile(
              icon: Icons.upload_file_outlined,
              label: 'Upload File',
              onTap: (){},
            ),
          ],
        ),
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
