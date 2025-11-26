import 'dart:io';
import 'package:eps_client/src/features/auth/presentations/register_page.dart';
import 'package:eps_client/src/utils/async_value_ui.dart';
import 'package:eps_client/src/utils/extensions.dart';
import 'package:eps_client/src/utils/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' as g;
import 'package:loading_indicator/loading_indicator.dart';

import '../../../env/env.dart';
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

  /// ----- Google Sign-In -----
  late final g.GoogleSignIn _google = g.GoogleSignIn(
    scopes: const ['email'],
    clientId: Platform.isIOS ? Env.googleClientId : null,
  );
  bool _googleLoading = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _usernameNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }


  ///input decoration
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
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(width: 1.4),
      ),
      border: base,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  ///submit login
  Future<void> _submit() async {
    final state = ref.read(loginControllerProvider);
    if (state.isLoading) return;

    final ok = await ref
        .read(loginControllerProvider.notifier)
        .login(email: _username.text.trim(), password: _password.text.trim());

    if (ok && mounted) {
      await ref.read(secureStorageProvider).saveAuthStatus(kAuthLoggedIn);
      ref.invalidate(secureStorageProvider);
    }
  }

  /// ----- Google Sign-In flow -----
  Future<void> _signInWithGoogle() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);

    try {
      final g.GoogleSignInAccount? account = await _google.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      final accessToken = auth.accessToken ?? '';

      final payload = {
        "provider"       :"google",
        "provider_id"    :accessToken,
        "email": account.email,
        "name": account.displayName ?? '',
      };

      final ok = await ref
          .read(loginControllerProvider.notifier)
          .signInWithGoogle(payload);

      if (ok && mounted) {
        await ref.read(secureStorageProvider).saveAuthStatus(kAuthLoggedIn);
        ref.invalidate(secureStorageProvider);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
    } finally {
      if (mounted) setState(() => _googleLoading = false);
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
                      hint: 'Email',
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
                    decoration:
                        _underlineInput(
                          hint: 'Password',
                          icon: Icons.lock,
                          accent: primary,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscured = !_obscured),
                            icon: Icon(
                              _obscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                        backgroundColor: const Color(0xFF69B1DB),
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

                  /// Sign up button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        textStyle: const TextStyle(
                          letterSpacing: .5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('SIGN UP'),
                    ),
                  ),

                  24.vGap,

                  Row(
                    children: const [
                      Expanded(child: Divider(height: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('Or continue with'),
                      ),
                      Expanded(child: Divider(height: 1)),
                    ],
                  ),
                  24.vGap,

                  /// Google Sign-in
                  OutlinedButton.icon(
                    onPressed: (ctrlState.isLoading || _googleLoading)
                        ? null
                        : _signInWithGoogle,
                    icon: Image.asset(
                      'assets/images/google.png',
                      width: 20,
                      height: 20,
                    ),
                    label: Text(
                      _googleLoading ? 'Signing in…' : 'Sign in with Google',
                      style: const TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Loading overlay
          if (ctrlState.isLoading || _googleLoading)
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
