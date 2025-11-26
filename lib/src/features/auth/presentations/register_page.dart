import 'package:eps_client/src/common_widgets/common_button.dart';
import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/common_widgets/password_input_view.dart';
import 'package:eps_client/src/features/auth/controllers/register_controller.dart';
import 'package:eps_client/src/utils/async_value_ui.dart';
import 'package:eps_client/src/utils/dimens.dart';
import 'package:eps_client/src/utils/extensions.dart';
import 'package:eps_client/src/utils/gap.dart';
import 'package:eps_client/src/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../../utils/secure_storage.dart';
import '../../../utils/strings.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  PhoneNumber? _phone;
  String? _phoneError;

  /// Controllers
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  /// Focus (optional)
  final FocusNode _phoneFocus = FocusNode();

  /// Selections
  String _selectedCountry = 'Myanmar';
  String _selectedGender = 'Male';
  String _dialCode = '+95';

  /// Country/Nationality dropdown options
  static const List<String> _countries = <String>[
    'Myanmar', 'Thailand', 'United States', 'United Kingdom',
    'France', 'Germany', 'China', 'Japan', 'South Korea', 'India',
  ];

  /// Gender dropdown options
  static const List<String> _genders = <String>['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _dobCtrl.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  /// ───────────────────────── Validators ─────────────────────────
  String? _req(String? v, [String label = 'This field']) {
    if ((v ?? '').trim().isEmpty) return '$label is required';
    return null;
  }

  String? _emailValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$').hasMatch(t);
    return ok ? null : 'Invalid email';
  }

  String? _passwordValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Password is required';
    if (t.length < 8) return 'Minimum 8 characters';
    return null;
  }

  String? _confirmValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please confirm your password';
    if (t != _passwordCtrl.text.trim()) return 'Passwords do not match';
    return null;
  }

  String? _validatePhoneForSubmit(PhoneNumber? p) {
    final digits = (p?.number ?? '').trim();
    if (digits.isEmpty) return 'Phone is required';
    if (digits.length < 6 || digits.length > 15) return 'Enter 6–15 digits';
    return null;
  }

  /// ───────────────────────── Helpers ─────────────────────────
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: initial,
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final phoneErr = _validatePhoneForSubmit(_phone);
    setState(() => _phoneError = phoneErr);
    final othersOk = _formKey.currentState?.validate() ?? false;

    if (phoneErr != null || !othersOk) return;

    final payload = {
      "email": _emailCtrl.text.trim(),
      "password": _passwordCtrl.text.trim(),
      "password_confirmation": _confirmCtrl.text.trim(),
      "phone": '$_dialCode${_phoneCtrl.text.trim()}',
      "dob": _dobCtrl.text.trim(),
      "address": _addressCtrl.text.trim(),
      "nationality": _selectedCountry.toLowerCase(),
      "gender": _selectedGender,
    };

    final ok = await ref.read(registerControllerProvider.notifier).signUp(
      payload: payload
    );

    if (ok && mounted) {
      await ref.read(secureStorageProvider).saveAuthStatus(kAuthLoggedIn);
      ref.invalidate(secureStorageProvider);
    }

  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);

    ref.listen<AsyncValue>(
      registerControllerProvider,
          (_, s) => s.showAlertDialogOnError(context),
    );

    return Scaffold(
      appBar: CustomAppBarView(title: 'Sign Up'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: kMarginMedium2,vertical: kMarginMedium2),
            child: Form(
              key: _formKey,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xffe5e7eb),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Email
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: _input('Email'),
                        validator: _emailValidator,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      14.vGap,

                      /// Phone (Intl)
                      IntlPhoneField(
                        autovalidateMode: AutovalidateMode.disabled,
                        disableLengthCheck: true,
                        initialCountryCode: 'TH',
                        languageCode: 'en',
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          errorText: _phoneError,
                        ),
                        onChanged: (p) {
                          _phone = p;
                          if (_phoneError != null) {
                            setState(() => _phoneError = null);
                          }
                        },
                        onCountryChanged: (c) {
                          if (_phone != null) {
                            _phone = PhoneNumber(
                              countryISOCode: c.code,
                              countryCode: '+${c.fullCountryCode}',
                              number: _phone!.number,
                            );
                          }
                        },
                      ),

                      14.vGap,

                      /// Address
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: _input('Address'),
                        validator: (v) => _req(v, 'Address'),
                        textInputAction: TextInputAction.next,
                      ),
                      14.vGap,

                      /// Country / Nationality (Dropdown)
                      DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        items: _countries
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCountry = v ?? _selectedCountry),
                        decoration: _input(''),
                        validator: (v) => (v == null || v.isEmpty) ? 'Please select a country' : null,
                      ),
                      14.vGap,

                      /// Gender (Dropdown)
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        items: _genders
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedGender = v ?? _selectedGender),
                        decoration: _input(''),
                        validator: (v) => (v == null || v.isEmpty) ? 'Please select gender' : null,
                      ),
                      14.vGap,

                      /// DOB
                      TextFormField(
                        controller: _dobCtrl,
                        readOnly: true,
                        onTap: _pickDob,
                        decoration: _input('Date of Birth (yyyy-MM-dd)').copyWith(
                          suffixIcon: const Icon(Icons.calendar_month_rounded),
                        ),
                        validator: (v) => _req(v, 'Date of birth'),
                      ),
                      14.vGap,

                      /// Password
                      PasswordInputField(
                        controller: _passwordCtrl,
                        hintText: 'Password',
                        isPassword: true,
                        validator: _passwordValidator,
                      ),
                      14.vGap,

                      /// Confirm Password
                      PasswordInputField(
                        controller: _confirmCtrl,
                        hintText: 'Confirm Password',
                        isPassword: true,
                        validator: _confirmValidator,
                      ),

                      22.vGap,

                      /// Sign Up
                      SizedBox(
                        width: double.infinity,
                        child: CommonButton(
                          text: 'Sign Up',
                          onTap: state.isLoading ? null : _submit,
                          bgColor: context.primary,
                          buttonTextColor: Colors.white,
                          containerHPadding: 0,
                          containerVPadding: 12,
                        ),
                      ),

                      20.vGap,
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (state.isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: LoadingView(
                  indicator: Indicator.ballRotate,
                  indicatorColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ───────────────────────── UI helpers ─────────────────────────
  InputDecoration _input(String label) => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hint: Text(label),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  InputDecoration _phoneDecoration() => InputDecoration(
    labelText: 'Phone Number',
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

