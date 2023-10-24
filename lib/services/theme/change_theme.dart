import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeTheme extends ChangeNotifier {
  bool isDark = false;

  set changeTheme(bool value) {
    isDark = value;
    setTheme(value: value);
    notifyListeners();
  }

  ThemeMode get getMode => isDark ? ThemeMode.dark : ThemeMode.light;

  // * Shared preferences
  final String _keyTheme = 'Key_Theme';
  // * Set
  Future<void> setTheme({required bool value}) async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setBool(_keyTheme, value);
  }

  // * Get
  Future<bool> get getTheme async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getBool(_keyTheme) ?? false;
  }

  void updateSharedTheme() async {
    if (isDark != await getTheme) {
      isDark = await getTheme;
      notifyListeners();
    }
  }
}
