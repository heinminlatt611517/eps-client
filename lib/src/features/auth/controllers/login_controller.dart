import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  bool mounted = true;

  @override
  FutureOr<void> build() {
    /// * this code is for  preventing error caused by popping out or going to other screen while the app is sending fcm request
    ref.onDispose(() => mounted = false);
  }

  Future<bool> login({required String email, required String password}) async {
    final authRepository = ref.read(authRepositoryNoTokenProvider);
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
          () => authRepository.login(email: email, password: password),
    );
    if (mounted) {
      state = result;
    }

    return state.hasError == false;
  }

  Future<bool> signInWithGoogle(dynamic payload) async {
    final authRepository = ref.read(authRepositoryNoTokenProvider);
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
          () => authRepository.signInWithGoogle(payload),
    );
    if (mounted) {
      state = result;
    }

    return state.hasError == false;
  }
}
