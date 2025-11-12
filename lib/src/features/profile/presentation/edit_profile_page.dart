import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/features/profile/data/profile_repository.dart';
import 'package:eps_client/src/utils/extensions.dart';

class EditCustomerProfilePage extends ConsumerStatefulWidget {
  const EditCustomerProfilePage({super.key, required this.profile});
  final dynamic profile;

  @override
  ConsumerState<EditCustomerProfilePage> createState() =>
      _EditCustomerProfilePageState();
}

class _EditCustomerProfilePageState
    extends ConsumerState<EditCustomerProfilePage> {
  final _form = GlobalKey<FormState>();

  /// Core
  late final TextEditingController _nameEn;
  late final TextEditingController _nameMm;
  String? _gender;
  DateTime? _dob;

  /// Identity
  late final TextEditingController _nrc;

  /// Passport
  late final TextEditingController _passportNo;
  DateTime? _passportExpiry;
  late final TextEditingController _prevPassportNo;

  /// Visa
  late final TextEditingController _visaType;
  late final TextEditingController _visaNumber;
  DateTime? _visaExpiry;

  /// CI
  late final TextEditingController _ciNo;
  DateTime? _ciExpiry;

  /// Pink Card
  late final TextEditingController _pinkCardNo;
  DateTime? _pinkCardExpiry;

  /// Contact
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _phone2;
  late final TextEditingController _address;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;

    /// Core
    _nameEn = TextEditingController(text: p?.name ?? '');
    _nameMm = TextEditingController(text: p?.nameMm ?? '');
    _gender = (p?.sex ?? '').toString().isEmpty ? null : p?.sex as String?;
    _dob = p?.dob;

    /// Identity
    _nrc = TextEditingController(text: p?.nrcNo ?? '');

    /// Passport
    _passportNo = TextEditingController(text: p?.passportNo ?? '');
    _passportExpiry = _parseDate(p?.passportExpiry);
    _prevPassportNo = TextEditingController(text: p?.prevPassportNo ?? '');

    /// Visa
    _visaType = TextEditingController(text: p?.visaType ?? '');
    _visaNumber = TextEditingController(text: p?.visaNumber ?? '');
    _visaExpiry = _parseDate(p?.visaExpiry);

    /// CI
    _ciNo = TextEditingController(text: p?.ciNo ?? '');
    _ciExpiry = _parseDate(p?.ciExpiry);

    /// Pink Card
    _pinkCardNo = TextEditingController(text: p?.pinkCardNo ?? '');
    _pinkCardExpiry = _parseDate(p?.pinkCardExpiry);

    /// Contact
    _email = TextEditingController(text: p?.email ?? '');
    _phone = TextEditingController(text: p?.phone ?? '');
    _phone2 = TextEditingController(text: p?.phoneSecondary ?? '');
    _address = TextEditingController(text: p?.address ?? '');
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameMm.dispose();
    _nrc.dispose();
    _passportNo.dispose();
    _prevPassportNo.dispose();
    _visaType.dispose();
    _visaNumber.dispose();
    _ciNo.dispose();
    _pinkCardNo.dispose();
    _email.dispose();
    _phone.dispose();
    _phone2.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, ValueSetter<DateTime?> setValue,
      {DateTime? initial}) async {
    final now = DateTime.now();
    final first = DateTime(1900);
    final last = DateTime(now.year + 30);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: first,
      lastDate: last,
    );
    if (!mounted) return;
    setValue(picked);
    setState(() {});
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'name': _nameEn.text.trim(),
        'name_mm': _nameMm.text.trim(),
        'sex': _gender,
        'dob': _dob?.toIso8601String(),
        'nrc_no': _nrc.text.trim(),
        'passport_no': _passportNo.text.trim(),
        'passport_expiry': _passportExpiry?.toIso8601String(),
        'prev_passport_no': _prevPassportNo.text.trim(),
        'visa_type': _visaType.text.trim(),
        'visa_number': _visaNumber.text.trim(),
        'visa_expiry': _visaExpiry?.toIso8601String(),
        'ci_no': _ciNo.text.trim(),
        'ci_expiry': _ciExpiry?.toIso8601String(),
        'pink_card_no': _pinkCardNo.text.trim(),
        'pink_card_expiry': _pinkCardExpiry?.toIso8601String(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'phone_secondary': _phone2.text.trim(),
        'address': _address.text.trim(),
      };

      body.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));

      final repo = ref.read(profileRepositoryProvider);
      await repo.editProfile(body);

      ref.invalidate(fetchProfileDataProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    InputDecoration _dec(String label, {Widget? suffix}) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixIcon: suffix,
    );

    Widget _dateTile(
        String label, DateTime? value, ValueSetter<DateTime?> setV) {
      return InkWell(
        onTap: () => _pickDate(context, setV, initial: value ?? DateTime.now()),
        child: InputDecorator(
          decoration: _dec(label),
          child: Text(
            value?.formattedFullDate ?? 'Select',
            style: tt.bodyLarge?.copyWith(
              color: value == null ? cs.outline : null,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBarView(
        title: 'Edit Profile',
        trailing: _saving
            ? Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: cs.primary),
          ),
        )
            : TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text('Identity',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameEn,
              decoration: _dec('Name (EN)'),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameMm,
              decoration: _dec('Name (MM)'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: _dec('Gender'),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 10),
            _dateTile('Date of Birth', _dob, (v) => setState(() => _dob = v)),
            const SizedBox(height: 10),
            TextFormField(controller: _nrc, decoration: _dec('NRC No.')),

            const SizedBox(height: 18),
            Text('Passport',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextFormField(
                controller: _passportNo, decoration: _dec('Passport No.')),
            const SizedBox(height: 10),
            _dateTile('Expiry', _passportExpiry, (v) => _passportExpiry = v),
            const SizedBox(height: 10),
            TextFormField(
                controller: _prevPassportNo,
                decoration: _dec('Previous Passport')),

            const SizedBox(height: 18),
            Text('Visa',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextFormField(controller: _visaType, decoration: _dec('Type')),
            const SizedBox(height: 10),
            TextFormField(controller: _visaNumber, decoration: _dec('Number')),
            const SizedBox(height: 10),
            _dateTile('Expiry', _visaExpiry, (v) => _visaExpiry = v),

            const SizedBox(height: 18),
            Text('CI',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextFormField(controller: _ciNo, decoration: _dec('CI No.')),
            const SizedBox(height: 10),
            _dateTile('CI Expiry', _ciExpiry, (v) => _ciExpiry = v),

            const SizedBox(height: 18),
            Text('Pink Card',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextFormField(
                controller: _pinkCardNo, decoration: _dec('Pink Card No.')),
            const SizedBox(height: 10),
            _dateTile('Pink Card Expiry', _pinkCardExpiry,
                    (v) => _pinkCardExpiry = v),

            const SizedBox(height: 18),
            Text('Contact',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: _dec('Email'),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return null;
                final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s);
                return ok ? null : 'Invalid email';
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: _dec('Phone'),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phone2,
              keyboardType: TextInputType.phone,
              decoration: _dec('Secondary Phone'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _address,
              decoration: _dec('Address'),
              maxLines: 3,
            ),

            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
