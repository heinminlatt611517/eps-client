import 'package:eps_client/src/utils/async_value_ui.dart';
import 'package:eps_client/src/utils/extensions.dart';
import 'package:eps_client/src/utils/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../utils/secure_storage.dart';
import '../../../utils/strings.dart';
import '../../../widgets/loading_view.dart';
import '../controllers/login_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _usernameNode = FocusNode();
  final _passwordNode = FocusNode();
  bool _obscured = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _usernameNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  InputDecoration _underlineInput({
    required String hint,
    required IconData icon,
    required Color accent,
  }) {
    const base = UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE5E5E5), width: 1),
    );
    return InputDecoration(
      prefixIcon: Icon(icon, color: accent),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black87),
      enabledBorder: base,
      focusedBorder:
      const UnderlineInputBorder(borderSide: BorderSide(width: 1.4)),
      border: base,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  Future<void> _submit() async {
    final state = ref.read(loginControllerProvider);

    if (state.isLoading) return;

    final ok = await ref.read(loginControllerProvider.notifier).login(
      email: _username.text.trim(),
      password: _password.text.trim(),
    );

    if (ok && mounted) {
      await ref.read(secureStorageProvider).saveAuthStatus(kAuthLoggedIn);
      ref.invalidate(secureStorageProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final primary = context.primary;


    ref.listen<AsyncValue>(
      loginControllerProvider,
          (_, next) => next.showAlertDialogOnError(context),
    );

    final ctrlState = ref.watch(loginControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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

                  /// Username
                  TextField(
                    controller: _username,
                    focusNode: _usernameNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passwordNode.requestFocus(),
                    decoration: _underlineInput(
                      hint: 'Username',
                      icon: Icons.person,
                      accent: primary,
                    ),
                  ),

                  32.vGap,

                  /// Password
                  TextField(
                    controller: _password,
                    focusNode: _passwordNode,
                    obscureText: _obscured,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: _underlineInput(
                      hint: 'Password',
                      icon: Icons.lock,
                      accent: primary,
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscured = !_obscured),
                        icon: Icon(
                          _obscured ? Icons.visibility_off : Icons.visibility,
                          color: primary,
                        ),
                      ),
                    ),
                  ),

                  36.vGap,

                  /// Sign in button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF69B1DB), // match mock
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        textStyle: const TextStyle(
                          letterSpacing: .5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('SIGN IN'),
                    ),
                  ),

                  16.vGap,

                  TextButton(
                    onPressed: () {
                      // TODO: push Forgot Password flow
                    },
                    child: Text(
                      'Forgot your password?',
                      style: tt.bodyMedium?.copyWith(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Loading overlay
          if (ctrlState.isLoading)
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
