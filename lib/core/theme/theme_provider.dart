import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;

  ThemeProvider._internal() {
    _loadThemeFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading theme from prefs: $e");
    }
  }

  Future<void> toggleTheme(bool isEnabled) async {
    _isDarkMode = isEnabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode_enabled', isEnabled);
    } catch (e) {
      debugPrint("Error saving theme to prefs: $e");
    }
  }
}
