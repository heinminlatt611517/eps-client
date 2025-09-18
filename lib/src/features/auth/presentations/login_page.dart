import 'package:eps_client/src/common_widgets/common_input_view.dart';
import 'package:eps_client/src/utils/async_value_ui.dart';
import 'package:eps_client/src/utils/extensions.dart';
import 'package:eps_client/src/utils/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../common_widgets/common_button.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isShowPassword = true;

  void onTapToggleObscured() {
    setState(() {
      isShowPassword = !isShowPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(getAuthStatusProvider).value;
    debugPrint("AuthStatus:::$authStatus");

    ///show error dialog when network response error
    ref.listen<AsyncValue>(
      loginControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    ///provider state
    final state = ref.watch(loginControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ///body view
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ///user name input view
                CommonInputView(
                  controller: emailController,
                  hintLabel: 'Email',
                  hintTextColor: context.primary,
                ),

                15.vGap,

                ///password input view
                CommonInputView(
                  controller: passwordController,
                  hintLabel: 'Password',
                  hintTextColor: context.primary,
                  isSecure: isShowPassword,
                  isPasswordView: true,
                  toggleObscured: onTapToggleObscured,
                  toggleObscuredColor: context.primary,
                ),

                50.vGap,

                ///login button
                CommonButton(
                  containerVPadding: 10,
                  containerHPadding: 60,
                  text: 'Login',
                  onTap: () async {
                    if (!state.isLoading) {
                      final bool isSuccess = await ref
                          .read(loginControllerProvider.notifier)
                          .login(
                            email: emailController.text,
                            password: passwordController.text.trim(),
                          );

                      ///is success login
                      if (isSuccess) {
                        await ref
                            .read(secureStorageProvider)
                            .saveAuthStatus(kAuthLoggedIn);
                        ref.invalidate(secureStorageProvider);
                      }
                    }
                  },
                  bgColor: context.primary,
                  buttonTextColor: Colors.white,
                ),
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
