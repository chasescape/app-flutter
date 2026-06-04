import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Theme Service - Manages app theme globally
class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final RxBool _isDarkMode = false.obs;

  /// Get dark mode status
  bool get isDarkMode => _isDarkMode.value;

  /// Dark mode stream
  RxBool get isDarkModeStream => _isDarkMode;

  /// Toggle theme
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeTheme(
      _isDarkMode.value ? _getDarkTheme() : _getLightTheme(),
    );
  }

  /// Get light theme
  ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF009246),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFF009246),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF009246),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  /// Get dark theme
  ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF009246),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      cardColor: const Color(0xFF2A2A2A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  /// Get current theme
  ThemeData get currentTheme =>
      _isDarkMode.value ? _getDarkTheme() : _getLightTheme();
}
