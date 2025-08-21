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
Future<void> showExceptionAlertDialog({
  required BuildContext context,
  // required String title,
  required dynamic exception,
}) =>
    showAlertDialog(
      context: context,
      // title: title,
      content: Text(
        exception.toString(),
        style: const TextStyle(color: Colors.white),
      ),
      defaultActionText: "Close",
    );

Future<void> showNotImplementedAlertDialog({required BuildContext context}) =>
    showAlertDialog(
      context: context,
      title: 'Not implemented',
    );