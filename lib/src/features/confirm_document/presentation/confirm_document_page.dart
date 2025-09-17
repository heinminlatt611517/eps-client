import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:flutter/material.dart';
import '../../upload_documents/model/passport_mrz_vo.dart';

class ConfirmDetailsPage extends StatelessWidget {
  const ConfirmDetailsPage({super.key, required this.mrz});

  final PassportMrz mrz;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = _firstGivenName(mrz.secondaryIdentifier);
    final lastName = mrz.primaryIdentifier;
    final nationality = _iso3ToName(mrz.nationality);
    final gender = _prettySex(mrz.sex);

    return Scaffold(
      appBar: CustomAppBarView(title: 'Confirm Details'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please review and confirm details',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Personal Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              _ReadonlyField(
                label: 'Passport Number',
                value: mrz.documentNumber,
              ),
              const SizedBox(height: 10),
              _ReadonlyField(label: 'First Name', value: firstName),
              const SizedBox(height: 10),
              _ReadonlyField(label: 'Last Name', value: lastName),
              const SizedBox(height: 10),
              _ReadonlyField(
                label: 'Date of Birth',
                value: _fmtDate(mrz.birthDate),
                hint: 'dd MMM yyyy',
              ),
              const SizedBox(height: 10),
              _ReadonlyField(label: 'Nationality', value: nationality),
              const SizedBox(height: 10),
              _ReadonlyField(label: 'Gender', value: gender),
              const SizedBox(height: 10),
              _ReadonlyField(
                label: 'Expiry date',
                value: _fmtDate(mrz.expiryDate),
                hint: 'dd MMM yyyy',
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, mrz),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _firstGivenName(String names) {
    final parts = names.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '';
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  static String _prettySex(String s) {
    switch (s.toUpperCase()) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      default:
        return 'Unspecified';
    }
  }

  static String _iso3ToName(String iso3) {
    const map = {
      'MMR': 'Myanmar',
      'THA': 'Thailand',
      'USA': 'United States',
      'GBR': 'United Kingdom',
      'FRA': 'France',
      'DEU': 'Germany',
      'CHN': 'China',
      'JPN': 'Japan',
      'KOR': 'South Korea',
      'IND': 'India',
    };
    return map[iso3.toUpperCase()] ?? iso3;
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? (hint ?? '') : value,
            style: tt.titleMedium?.copyWith(
              color: value.isEmpty ? Colors.grey : cs.onSurface,
              fontWeight: value.isEmpty ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
