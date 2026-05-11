import 'package:flutter/material.dart';

/// App colors aligned with the provided Tavia splash direction.
class AppColors {
  AppColors._();

  static const Color primaryMain = Color(0xFFFF4FA1);
  static const Color primaryLight = Color(0xFFFF8AC4);
  static const Color primaryDark = Color(0xFFE52C89);
  static const Color primaryContrastText = Color(0xFFFFFFFF);

  static const Color secondaryMain = Color(0xFFFF9A62);
  static const Color secondaryLight = Color(0xFFFFC37E);
  static const Color secondaryDark = Color(0xFFFF7B4F);

  static const Color accentMain = Color(0xFFFFC928);
  static const Color accentLight = Color(0xFFFFDE73);
  static const Color accentDark = Color(0xFFE1A80C);

  static const Color semanticSuccess = Color(0xFF2DB885);
  static const Color semanticWarning = Color(0xFFFF9800);
  static const Color semanticError = Color(0xFFE74B72);
  static const Color semanticInfo = Color(0xFF5B8EFF);

  static const Color backgroundPrimary = Color(0xFFFFC3DC);
  static const Color backgroundSecondary = Color(0xFFFF8FBD);
  static const Color backgroundTertiary = Color(0xFFFFE7F1);
  static const Color backgroundOverlay = Color(0x33FFFFFF);
  static const Color scaffoldBase = Color(0xFFFFF7FB);
  static const Color surface = Color(0xFFFDF2F8);
  static const Color surfaceStrong = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFFFD8E9);

  static const Color textPrimary = Color(0xFF5B2151);
  static const Color textSecondary = Color(0xFF8B5F82);
  static const Color textDisabled = Color(0xFFC38DAD);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFFFD0E3);

  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF2A1230);

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [
      Color(0xFFF7C6DD),
      Color(0xFFF58CB8),
      Color(0xFFFF3E98),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient candyGlowGradient = LinearGradient(
    colors: [
      Color(0xFFFFBF2E),
      Color(0xFFFF8E4C),
      Color(0xFFFF4FA1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient creamButtonGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF4F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient purplePinkGradient = sunsetGradient;
  static const LinearGradient triColorGradient = candyGlowGradient;

  static Color shadowColor(Color color, {double opacity = 0.16}) {
    return color.withValues(alpha: opacity);
  }
}
