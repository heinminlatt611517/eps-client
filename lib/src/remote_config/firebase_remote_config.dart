import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// ---- helpers --------------------------------------------------------------

Color? _hex(String? s) {
  if (s == null || s.isEmpty) return null;
  final v = s.replaceAll('#', '').toUpperCase();
  final full = v.length == 6 ? 'FF$v' : v;
  try { return Color(int.parse(full, radix: 16)); } catch (_) { return null; }
}

ThemeData _buildTheme({
  required Brightness brightness,
  required Color primary,
  required Color secondary,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    primary: primary,
    secondary: secondary,
    brightness: brightness,
  );
  return ThemeData(useMaterial3: true, colorScheme: scheme);
}

/// A pair of ThemeData for light & dark.
class AppThemes {
  final ThemeData light;
  final ThemeData dark;
  const AppThemes(this.light, this.dark);
}

/// ---- provider -------------------------------------------------------------

final remoteThemesProvider =
StateNotifierProvider<RemoteThemeController, AppThemes>((ref) {
  return RemoteThemeController()..init();
});

class RemoteThemeController extends StateNotifier<AppThemes> {
  RemoteThemeController()
      : super(
    AppThemes(
      _buildTheme(
        brightness: Brightness.light,
        primary: const Color(0xFF0A84FF),
        secondary: const Color(0xFFFF3B30),
      ),
      _buildTheme(
        brightness: Brightness.dark,
        primary: const Color(0xFF0A84FF),
        secondary: const Color(0xFFFF3B30),
      ),
    ),
  );

  late final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    await _rc.setDefaults(const {
      'primary_color': '#0A84FF',
      'secondary_color': '#FF3B30',
      'primary_color_dark': '',
      'secondary_color_dark': '',
    });

    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));

    await refresh();

    _rc.onConfigUpdated.listen((event) async {
      await _rc.activate();
      _apply();
    });
  }

  Future<void> refresh() async {
    try { await _rc.fetchAndActivate(); } catch (_) {}
    _apply();
  }

  void _apply() {
    final p = _hex(_rc.getString('primary_color')) ?? const Color(0xFF0A84FF);
    final s = _hex(_rc.getString('secondary_color')) ?? const Color(0xFFFF3B30);

    final pd = _hex(_rc.getString('primary_color_dark')) ?? p;
    final sd = _hex(_rc.getString('secondary_color_dark')) ?? s;

    state = AppThemes(
      _buildTheme(brightness: Brightness.light, primary: p, secondary: s),
      _buildTheme(brightness: Brightness.dark, primary: pd, secondary: sd),
    );
  }
}
