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
        print('🎨 Theme loaded from storage: $state');
      } else {
        print('🎨 No saved theme, using system default');
      }
    } catch (e) {
      print('❌ Error loading theme mode: $e');
    }
  }

  /// Save theme mode to storage
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
      print('💾 Theme saved: $mode');
    } catch (e) {
      print('❌ Error saving theme mode: $e');
    }
  }

  /// Set theme to light mode
  void setLightMode() {
    state = ThemeMode.light;
    _saveThemeMode(ThemeMode.light);
  }

  /// Set theme to dark mode
  void setDarkMode() {
    state = ThemeMode.dark;
    _saveThemeMode(ThemeMode.dark);
  }

  /// Set theme to system mode (follows device settings)
  void setSystemMode() {
    state = ThemeMode.system;
    _saveThemeMode(ThemeMode.system);
  }

  /// Toggle between light and dark (skips system mode)
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setDarkMode();
    } else {
      setLightMode();
    }
  }

  /// Check if currently using dark theme
  bool isDarkMode(BuildContext context) {
    if (state == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }

  /// Get user-friendly name for current theme mode
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

  /// Get icon for current theme mode
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

/// Provider for theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
