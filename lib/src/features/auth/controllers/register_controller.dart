import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';

part 'register_controller.g.dart';

@riverpod
class RegisterController extends _$RegisterController {
  bool mounted = true;

  @override
  FutureOr<void> build() {
    /// * this code is for  preventing error caused by popping out or going to other screen while the app is sending fcm request
    ref.onDispose(() => mounted = false);
  }

  Future<bool> signUp({
    dynamic payload
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryNoTokenProvider);
    final res = await AsyncValue.guard(
          () => repo.signUp(payload),
    );
    state = res;
    return !state.hasError;
  }
}
