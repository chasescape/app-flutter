import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Pink Mist Theme
  static const Color primary = Color(0xFFE8B4D9);
  static const Color primaryLight = Color(0xFFF5E6F1);
  static const Color primaryDark = Color(0xFF8B5A7D);

  // Secondary Colors - Purple Accent
  static const Color secondary = Color(0xFFB8A4D9);
  static const Color secondaryLight = Color(0xFFE6E0F5);
  static const Color secondaryDark = Color(0xFF6B5A8B);

  // Accent Colors - Coral & Teal
  static const Color accent1 = Color(0xFFFFB4A2);
  static const Color accent2 = Color(0xFFA2D5D9);
  static const Color accent3 = Color(0xFFFFD4B8);

  // Gradient Colors
  static const List<Color> gradientPink = [Color(0xFFE8B4D9), Color(0xFFF5E6F1)];
  static const List<Color> gradientPurple = [Color(0xFFB8A4D9), Color(0xFFE6E0F5)];
  static const List<Color> gradientCoral = [Color(0xFFFFB4A2), Color(0xFFFFD4B8)];
  static const List<Color> gradientTeal = [Color(0xFFA2D5D9), Color(0xFFD4F1F4)];
  static const List<Color> gradientSunset = [Color(0xFFFFB4A2), Color(0xFFE8B4D9), Color(0xFFB8A4D9)];
  static const List<Color> gradientPeach = [Color(0xFFFFC1A1), Color(0xFFFFE2D1)];
  static const List<Color> gradientLavender = [Color(0xFFD0C4F2), Color(0xFFF2ECFF)];
  static const List<Color> gradientMint = [Color(0xFFB8E4D0), Color(0xFFDFF5E8)];

  // Neutral Colors - Light Theme
  static const Color background = Color(0xFFF5E6F1);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Functional Colors
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);

  // Helper methods to get theme-aware colors
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : background;
  }

  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surface;
  }

  static Color getCard(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : surface;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }
}
