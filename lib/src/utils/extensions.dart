import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

extension SnackBarExtensions on BuildContext {
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

extension DialogExtensions on BuildContext {
  void showErrorDialog(String message, String title) {
    showDialog(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

extension GreetingExtension on DateTime {
  String get greeting {
    final hour = this.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }
}

extension FormattedDateExtension on DateTime {
  /// Example: "Tuesday, Nov 17, 2025"
  String get formattedFullDate {
    final formatter = DateFormat('EEEE, MMM d, y');
    return formatter.format(this);
  }
}


extension FormattedTimeExtension on DateTime {
  /// Returns time in 12-hour format with AM/PM, e.g. "09:00 AM"
  String get time12h {
    return DateFormat('hh:mm a').format(this);
  }
}

extension StringCasingExtension on String {
  /// Capitalizes the first letter of the string
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}


extension MLKitInputImage on AnalysisImage {
  InputImage toInputImage() {
    final rotation =
    InputImageRotation.values.byName(this.rotation.name); // 0/90/180/270

    return when(
      // ANDROID: NV21
      nv21: (image) => InputImage.fromBytes(
        bytes: image.bytes,
        metadata: InputImageMetadata(
          size: image.size,
          rotation: rotation,
          format: InputImageFormat.nv21,     // NV21
          bytesPerRow: image.planes.first.bytesPerRow, // single plane
        ),
      ),
      // iOS: BGRA8888
      bgra8888: (image) => InputImage.fromBytes(
        bytes: image.bytes,
        metadata: InputImageMetadata(
          size: image.size,
          rotation: rotation,                    // not used by iOS conversion
          format: InputImageFormat.bgra8888,     // BGRA
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      ),
    )!;
  }
}


