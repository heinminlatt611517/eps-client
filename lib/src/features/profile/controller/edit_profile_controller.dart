import 'package:eps_client/src/features/profile/data/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_profile_controller.g.dart';

@riverpod
class EditProfileController extends _$EditProfileController {
  bool _mounted = true;

  @override
  FutureOr<void> build() {
    ref.onDispose(() => _mounted = false);
  }

  Future<bool> editProfile(dynamic requestData) async {
    final repo = ref.read(profileRepositoryProvider);
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
          () => repo.editProfile(requestData),
    );
    if (_mounted) {
      state = result;
    }
    return state.hasError == false;
  }
}
