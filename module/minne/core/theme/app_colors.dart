import 'package:flutter/material.dart';

/// App Colors - Daily Happiness Design System
/// Based on Erin Flink's modern social design expertise
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryMain = Color(0xFFFF4757);
  static const Color primaryLight = Color(0xFFFF4757);
  static const Color primaryDark = Color(0xFFFF4757);
  static const Color primaryContrast = Color(0xFFFFFFFF);

  // Secondary Colors
  static const Color secondaryMain = Color(0xFF2ED573);
  static const Color secondaryLight = Color(0xFF2ED573);
  static const Color secondaryDark = Color(0xFF2ED573);

  // Accent Colors
  static const Color accentMain = Color(0xFF5352ED);
  static const Color accentLight = Color(0xFF5352ED);
  static const Color accentDark = Color(0xFF5352ED);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Background Colors
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF5F5F5);
  static const Color bgTertiary = Color(0xFFEFEFF4);
  static const Color bgOverlay = Color(0x66000000);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textDisabled = Color(0xFFCCCCCC);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFFF4757),
    Color(0xFFFF6B81),
    Color(0xFFFFA8C5),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF2ED573),
    Color(0xFF26AF61),
    Color(0xFF7BED9F),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF5352ED),
    Color(0xFF70A1FF),
    Color(0xFF5352ED),
  ];

  // Social Gradient (Community Page)
  static const List<Color> socialGradient = [
    Color(0xFFA855F7),
    Color(0xFFEC4899),
    Color(0xFFF97316),
  ];

  // Shadow Colors
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x29000000);

  // Card Colors
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0x0D000000);

  // Button Colors
  static const Color buttonPrimary = Color(0xFFFF4757);
  static const Color buttonSecondary = Color(0xFF2ED573);
  static const Color buttonDisabled = Color(0xFFCCCCCC);

  // Input Colors
  static const Color inputBg = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFEFEFF4);
  static const Color inputFocus = Color(0xFFFF4757);

  // Divider
  static const Color divider = Color(0x1E000000);
}
