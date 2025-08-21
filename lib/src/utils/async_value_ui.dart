import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common_widgets/alert_dialogs.dart';
import '../exceptions/app_exception.dart';

/// * this code is important, it is used for showing error dialog listening by 'ref.listen'
extension AsyncValueUI on AsyncValue {
  void showAlertDialogOnError(BuildContext context) {
    if (!isLoading && hasError) {
      final message = _errorMessage(error);
      showExceptionAlertDialog(
        context: context,
        exception: message,
      );
    }
  }

  String _errorMessage(Object? error) {
    if (error is AppException) {
      return error.message;
    } else {
      return error.toString();
    }
  }
}