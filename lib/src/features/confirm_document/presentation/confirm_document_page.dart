import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmDocumentPage extends StatelessWidget {
  const ConfirmDocumentPage({
    super.key,
    this.details,
  });

  final DocumentDetails? details;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    String _fmt(DateTime? d) =>
        d == null ? '' : DateFormat('d MMM yyyy').format(d);

    final d = details ?? const DocumentDetails();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Details'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('Please review and confirm details',
                style: tt.bodyMedium?.copyWith(color: cs.outline)),
            const SizedBox(height: 16),

            Text('Personal Details',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),

            DetailField(label: 'Passport Number', value: d.passportNumber),
            DetailField(label: 'First Name', value: d.firstName),
            DetailField(label: 'Last Name', value: d.lastName),
            DetailField(label: 'Date of Birth', value: _fmt(d.dateOfBirth)),
            DetailField(label: 'Nationality', value: d.nationality),
            DetailField(label: 'Gender', value: d.gender),
            DetailField(label: 'Expiry date', value: _fmt(d.expiryDate)),

            const SizedBox(height: 24),
            FilledButton(
              onPressed: (){},
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

/// One read-only field card (label + value / placeholder)
class DetailField extends StatelessWidget {
  const DetailField({
    super.key,
    required this.label,
    this.value,
    this.placeholder = '',
  });

  final String label;
  final String? value;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasValue = value != null && value!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            hasValue ? value! : (placeholder.isNotEmpty ? placeholder : ''),
            style: hasValue
                ? tt.bodyMedium
                : tt.bodyMedium?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}

/// Data model (all fields nullable)
class DocumentDetails {
  final String? passportNumber;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? gender;
  final DateTime? expiryDate;

  const DocumentDetails({
    this.passportNumber,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.nationality,
    this.gender,
    this.expiryDate,
  });
}
