import 'dart:io';

import 'package:eps_client/src/features/submit_cv_page/data/upload_cv_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cv_controller.g.dart';

@riverpod
class CvController extends _$CvController {
  @override
  FutureOr<void> build() {}

  Future<bool> submit(File file) async {
    state = const AsyncLoading();
    final repo = ref.read(uploadCVRepositoryProvider);
    final res = await AsyncValue.guard(() => repo.submitCv(file));
    state = res;
    return !state.hasError;
  }
}
