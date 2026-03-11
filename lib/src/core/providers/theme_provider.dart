import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeMode>((ref) {
  return ThemeProvider();
});

class ThemeProvider extends StateNotifier<ThemeMode> {
  ThemeProvider() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('theme_mode') ?? 'system';
    
    switch (themeMode) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setLightMode() async {
    state = ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', 'light');
  }

  Future<void> setDarkMode() async {
    state = ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', 'dark');
  }

  Future<void> setSystemMode() async {
    state = ThemeMode.system;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', 'system');
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }
}