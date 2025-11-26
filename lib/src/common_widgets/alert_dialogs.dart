import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const kDialogDefaultKey = Key('dialog-default-key');

/// Generic function to show a platform-aware Material or Cupertino dialog
Future<bool?> showAlertDialog({
  required BuildContext context,
  String? title,
  Widget? content,
  String? cancelActionText,
  String? defaultActionText = "Close",
  Color color = Colors.red,
}) async {
  if (kIsWeb || !Platform.isIOS) {
    return showDialog(
      context: context,
      barrierDismissible: cancelActionText != null,
      builder: (context) => AlertDialog(
        backgroundColor: color,
        title: title != null ? Text(title) : null,
        content: content ?? const SizedBox(),
        actions: <Widget>[
          if (cancelActionText != null)
            TextButton(
              child: Text(cancelActionText),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          TextButton(
            key: kDialogDefaultKey,
            child: defaultActionText != null
                ? Text(
              defaultActionText.tr(),
              style: const TextStyle(color: Colors.white),
            )
                : const SizedBox(),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  return showDialog(
    context: context,
    barrierDismissible: cancelActionText != null,
    builder: (context) => AlertDialog(
      backgroundColor: color,
      title: title != null ? Text(title) : null,
      content: content ?? const SizedBox(),
      actions: <Widget>[
        if (cancelActionText != null)
          TextButton(
            child: Text(
              cancelActionText,
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        TextButton(
          key: kDialogDefaultKey,
          child: defaultActionText != null
              ? Text(defaultActionText.tr(),
              style: const TextStyle(color: Colors.white))
              : const SizedBox(),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}

/// Generic function to show a platform-aware Material or Cupertino error dialog
// Future<void> showExceptionAlertDialog({
//   required BuildContext context,
//   // required String title,
//   required dynamic exception,
// }) =>
//     showAlertDialog(
//       context: context,
//       // title: title,
//       content: Text(
//         exception.toString(),
//         style: const TextStyle(color: Colors.white),
//       ),
//       defaultActionText: "Close",
//     );
Future<void> showExceptionAlertDialog({
  required BuildContext context,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.red.shade400,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showNotImplementedAlertDialog({required BuildContext context}) =>
    showAlertDialog(
      context: context,
      title: 'Not implemented',
    );