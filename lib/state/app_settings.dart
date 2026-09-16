import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  String _profileName = 'Portfolio Developer';
  bool _isDarkMode = false;

  String get profileName => _profileName;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void setProfileName(String value) {
    final normalizedName = value.trim();
    final nextName = normalizedName.isEmpty
        ? 'Portfolio Developer'
        : normalizedName;

    if (_profileName == nextName) {
      return;
    }

    _profileName = nextName;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode == value) {
      return;
    }

    _isDarkMode = value;
    notifyListeners();
  }

  void reset() {
    _profileName = 'Portfolio Developer';
    _isDarkMode = false;
    notifyListeners();
  }
}
