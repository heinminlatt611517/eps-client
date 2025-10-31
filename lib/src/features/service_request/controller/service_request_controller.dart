import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/service_request_repository.dart';
import '../form/service_request_form_notifier.dart';

part 'service_request_controller.g.dart';

@riverpod
class ServiceRequestController extends _$ServiceRequestController {
  bool _mounted = true;

  @override
  FutureOr<void> build() {
    ref.onDispose(() => _mounted = false);
  }

  /// Returns `true` on success, `false` on error.
  Future<bool> submit() async {
    debugPrint("Submit Service Request");
    final repo = ref.read(serviceRequestRepositoryProvider);
    final form = ref.read(serviceRequestFormNotifierProvider);

    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
          () => repo.submitServiceRequest(form.toPayload()),
    );
    if (_mounted) {
      state = result;
    }
    return state.hasError == false;
  }
}
