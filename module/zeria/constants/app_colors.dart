import 'package:flutter/material.dart';

// App Colors - Zeria visual system inspired by the launch artwork
class AppColors {
  // Brand
  static const Color primaryMain = Color(0xFF321424);
  static const Color primaryLight = Color(0xFF5A2640);
  static const Color primaryDark = Color(0xFF200C18);
  static const Color primaryContrastText = Color(0xFFFFFFFF);

  static const Color secondaryMain = Color(0xFFF45E9F);
  static const Color secondaryLight = Color(0xFFFF85BA);
  static const Color secondaryDark = Color(0xFFD93C83);

  static const Color accentMain = Color(0xFFFF4D99);
  static const Color accentLight = Color(0xFFFF7AB5);
  static const Color accentDark = Color(0xFFFFA04D);

  // Semantic
  static const Color success = Color(0xFF2DBA84);
  static const Color warning = Color(0xFFFFA63F);
  static const Color error = Color(0xFFF05C73);
  static const Color info = Color(0xFF5A8DFF);

  // Backgrounds
  static const Color bgPrimary = Color(0xFFFDF7FA);
  static const Color bgSecondary = Color(0xFFF8EEF3);
  static const Color bgTertiary = Color(0xFFF1DCE5);
  static const Color bgOverlay = Color(0x66230C18);

  // Text
  static const Color textPrimary = Color(0xFF2F1724);
  static const Color textSecondary = Color(0xFF7D5B6E);
  static const Color textDisabled = Color(0xFFC9B0BE);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Specialty
  static const Color brandPeach = Color(0xFFFFC2D6);
  static const Color brandBlush = Color(0xFFFFE4EF);
  static const Color brandPink = Color(0xFFFF5BA2);
  static const Color brandHotPink = Color(0xFFFF2E8D);
  static const Color brandOrange = Color(0xFFFFB347);
  static const Color brandInk = Color(0xFF23101C);
  static const Color surfaceStrong = Color(0xFFFDFBFC);
  static const Color surfaceMuted = Color(0xFFF7EAF1);
  static const Color surfaceTint = Color(0xFFFDE6EE);

  // Gradients
  static const Gradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7CCD9),
      Color(0xFFF67FB2),
      Color(0xFFFF4D9C),
    ],
    stops: [0.0, 0.52, 1.0],
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFBF4B),
      Color(0xFFFF4D99),
    ],
  );

  static const Gradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xEFFFFFFF),
      Color(0xCCFFF1F6),
    ],
  );

  static const Gradient backgroundVeil = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x33FFFFFF),
      Color(0x0DFFFFFF),
    ],
  );

  // Glass
  static const Color glassBackground = Color(0xD9FFFFFF);
  static const Color glassBorder = Color(0x7AFFFFFF);
  static const Color glassShadow = Color(0x1F1B0712);

  // Legacy accent aliases kept for compatibility
  static const Color neonPurple = Color(0xFFFF77B5);
  static const Color neonPink = Color(0xFFFF3F97);
  static const Color neonBlue = Color(0xFFFFBB6B);
}
