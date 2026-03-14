import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  static late SharedPreferences _prefs;

  static const _keyIsDark = 'isDark';

  /// Inicializa o serviço e carrega a preferência salva.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs.getBool(_keyIsDark) ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Alterna e persiste o modo escuro.
  static Future<void> setDarkMode(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setBool(_keyIsDark, isDark);
  }
}
