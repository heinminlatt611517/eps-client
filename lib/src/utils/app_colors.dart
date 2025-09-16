import 'package:flutter/material.dart';

/// Use Remote-Config–driven colors from your Theme (set via remoteThemesProvider).
extension AppColors on BuildContext {
  Color get kBackgroundColor => Theme.of(this).colorScheme.background;
  Color get kPrimaryColor    => Theme.of(this).colorScheme.primary;
  Color get kSecondaryColor  => Theme.of(this).colorScheme.secondary;
}
