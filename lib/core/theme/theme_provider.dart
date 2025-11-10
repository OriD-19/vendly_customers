import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode notifier that persists user preference
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeModeKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);
      
      if (themeModeString != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      } else {
      }
    } catch (e) {
    }
  }

  /// Save theme mode to storage
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
    } catch (e) {
    }
  }

  void setLightMode() {
    state = ThemeMode.light;
    _saveThemeMode(ThemeMode.light);
  }

  void setDarkMode() {
    state = ThemeMode.dark;
    _saveThemeMode(ThemeMode.dark);
  }

  void setSystemMode() {
    state = ThemeMode.system;
    _saveThemeMode(ThemeMode.system);
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setDarkMode();
    } else {
      setLightMode();
    }
  }

  bool isDarkMode(BuildContext context) {
    if (state == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }

  String get themeName {
    switch (state) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  IconData get themeIcon {
    switch (state) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
