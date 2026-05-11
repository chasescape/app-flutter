import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryMain = Color(0xFFF55CA8);
  static const Color primaryLight = Color(0xFFFF9ACB);
  static const Color primaryDark = Color(0xFFB43E74);
  static const Color primaryContrastText = Color(0xFFFFFFFF);

  // Secondary Colors
  static const Color secondaryMain = Color(0xFFFFD76B);
  static const Color secondaryLight = Color(0xFFFFF0B5);
  static const Color secondaryDark = Color(0xFFE8A63A);

  // Accent Colors
  static const Color accentMain = Color(0xFF22111F);
  static const Color accentLight = Color(0xFF5A4255);
  static const Color accentDark = Color(0xFF140A13);

  // Semantic Colors
  static const Color success = Color(0xFF4FB58A);
  static const Color warning = Color(0xFFF1A83B);
  static const Color error = Color(0xFFE15874);
  static const Color info = Color(0xFF72A8F7);

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFF8FD);
  static const Color backgroundSecondary = Color(0xFFFFECF6);
  static const Color backgroundTertiary = Color(0xFFFFF5CB);
  static const Color backgroundOverlay = Color(0xD9FFFFFF);
  static const Color backgroundCard = Color(0xFFFDF9FC);
  static const Color backgroundSurface = Color(0xFFFFFFFF);
  static const Color cardStroke = Color(0xFFEFD8E7);
  static const Color softLavender = Color(0xFFEADFFF);
  static const Color softBlue = Color(0xFFDDF2FF);
  static const Color softPink = Color(0xFFFFE2F1);

  // Text Colors
  static const Color textPrimary = Color(0xFF22111F);
  static const Color textSecondary = Color(0xFF8D7D8B);
  static const Color textDisabled = Color(0xFFBAAFB8);
  static const Color textInverse = Color(0xFF000000);
  static const Color textDark = Color(0xFF1F1020);
  static const Color textGrey = Color(0xFF7B6E79);

  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFA8D2),
      Color(0xFFFFEAF5),
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFBFD),
      Color(0xFFFCECF7),
      Color(0xFFFFF7D9),
    ],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB8D8),
      Color(0xFFFFE07A),
      Color(0xFFDDEBFF),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF25111F),
      Color(0xFF12070F),
    ],
  );
}
