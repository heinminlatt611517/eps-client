import 'dart:async';
import 'package:eps_client/src/common_widgets/custom_app_bar_view.dart';
import 'package:eps_client/src/utils/dimens.dart';
import 'package:eps_client/src/utils/gap.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const _otpLen = 6;
  static const _initialSeconds = 60;

  final _pinCtrl = TextEditingController();
  late final StreamController<ErrorAnimationType> _errorCtrl;

  Timer? _timer;
  int _seconds = _initialSeconds;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _errorCtrl = StreamController<ErrorAnimationType>();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _errorCtrl.close();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = _initialSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _verify() async {
    final code = _pinCtrl.text.trim();
    if (code.length != _otpLen) {
      _errorCtrl.add(ErrorAnimationType.shake);
      return;
    }
    setState(() => _loading = true);
    // try {
    //   final ok = await widget.onVerify(code);
    //   if (!ok) {
    //     _errorCtrl.add(ErrorAnimationType.shake);
    //     if (mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Invalid code, please try again.')),
    //       );
    //     }
    //   }
    // } finally {
    //   if (mounted) setState(() => _loading = false);
    // }
  }

  void _resend() {
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final primary = cs.primary;

    return Scaffold(
      appBar: CustomAppBarView(title: 'OTP Verification'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kMarginMedium3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            48.vGap,
            /// Logo placeholder box
            Container(
              width: 180,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            48.vGap,

            Text(
              'Please check and enter',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: Colors.black,fontWeight: FontWeight.w600),
            ),
            12.vGap,
            Text(
              'We have sent OTP code to your phone number.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.outline),
            ),
            const SizedBox(height: 16),

            /// OTP input (matches your config)
            PinCodeTextField(
              backgroundColor: Colors.transparent,
              keyboardType: TextInputType.number,
              autoDisposeControllers: true,
              cursorColor: Colors.blue,
              appContext: context,
              length: _otpLen,
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                selectedFillColor: Colors.white,
                inactiveColor: Colors.grey,
                activeColor: Colors.white,
                inactiveFillColor: Colors.white,
                shape: PinCodeFieldShape.box,
                borderWidth: 1,
                inactiveBorderWidth: 1,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 50,
                fieldWidth: 50,
                activeFillColor: primary,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              errorAnimationController: _errorCtrl,
              controller: _pinCtrl,
              onCompleted: (_) => _verify(),
              onChanged: (_) {},
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Verify'),
              ),
            ),

            const SizedBox(height: 16),

            if (_seconds > 0)
              Column(
                children: [
                  Text(
                    'Didn\'t get OTP code?',
                    style: tt.bodySmall?.copyWith(color: cs.outline),
                  ),
                  4.vGap,
                  Text(
                    'Resend in 00:${_seconds.toString().padLeft(2, '0')} seconds',
                    style: tt.bodySmall?.copyWith(color: Colors.red),
                  ),
                ],
              )
            else
              TextButton.icon(
                onPressed: _resend,
                icon: const Icon(Icons.refresh),
                label: const Text('Resend Code'),
              ),
          ],
        ),
      ),
    );
  }
}
