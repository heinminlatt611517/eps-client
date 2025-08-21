import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

