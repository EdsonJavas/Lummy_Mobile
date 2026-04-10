import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  /// Enquanto true, o [MaterialApp] fica em tema claro (login, cadastro, etc.).
  /// Depois do login no app principal, passa a respeitar a preferência salva.
  bool _preLoginLightOnly = true;

  ThemeMode get themeMode => _themeMode;

  /// Tema efetivo na raiz do app (diálogos, overlay, etc.).
  ThemeMode get materialThemeMode =>
      _preLoginLightOnly ? ThemeMode.light : _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  void setPreLoginLightOnly(bool value) {
    if (_preLoginLightOnly == value) return;
    _preLoginLightOnly = value;
    notifyListeners();
  }

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, mode == ThemeMode.dark);
  }
}
