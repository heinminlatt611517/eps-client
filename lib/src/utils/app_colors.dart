import 'package:flutter/material.dart';

/// Use Remote-Config–driven colors from your Theme (set via remoteThemesProvider).
extension AppColors on BuildContext {
  Color get kBackgroundColor => Theme.of(this).colorScheme.background;
  Color get kPrimaryColor    => Theme.of(this).colorScheme.primary;
  Color get kSecondaryColor  => Theme.of(this).colorScheme.secondary;
}

const Color kBackgroundColor = Color(0xFF111111);
const Color kPrimaryColor = Color(0xFFFF8901);
const Color kSecondaryColor = Color(0XFF1F3681);
const Color kGreenAccentColor = Color(0XFFCDDC39);
const Color kOrangeAccentColor = Color(0XFFFAA82C);
const Color kBlueAccentColor = Color(0XFF0CAEDD);
const Color kYellowAccentColor = Color(0XFFCDDC39);
const Color kRedAccentColor = Color(0xFFF15A25);
const Color kDarkGreyColor = Color(0XFFAEAEAE);
const Color kGreyColor = Color(0XFF808080);
const Color kLightGreyColor = Color(0XFFCFCFCF);
