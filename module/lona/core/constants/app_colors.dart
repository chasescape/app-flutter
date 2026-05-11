import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryMain = Color(0xFFFF6600);
  static const Color secondaryMain = Color(0xFFFF7A00);
  static const Color accentMain = Color(0xFFFFD69C);
  static const Color warmMain = Color(0xFFFFB449);
  static const Color plumMain = Color(0xFF7A3200);

  static const Color backgroundPrimary = Color(0xFFFFF5E9);
  static const Color backgroundSecondary = Color(0xFFFFE4C1);
  static const Color backgroundTertiary = Color(0xFFFFFAF1);
  static const Color backgroundDark = Color(0xFF4D1B00);
  static const Color backgroundOverlay = Color(0xD8FFF7EE);

  static const Color textPrimary = Color(0xFF351405);
  static const Color textSecondary = Color(0xFF88532D);
  static const Color textDisabled = Color(0xFFC08E63);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color semanticSuccess = Color(0xFF4CAF50);
  static const Color semanticWarning = Color(0xFFFF9800);
  static const Color semanticError = Color(0xFFF44336);
  static const Color semanticInfo = Color(0xFF2196F3);

  static const Color cardBackground = Color(0xF7FFF8F0);
  static const Color cardBackgroundStrong = Color(0xFFFFFCF7);
  static const Color dividerColor = Color(0x55FFFFFF);
  static const Color outlineSoft = Color(0x73FFDDB5);
  static const Color shadowColor = Color(0x26B84C00);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient backdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF6B00),
      Color(0xFFFF7D08),
      Color(0xFFFFA632),
    ],
    stops: [0.0, 0.52, 1.0],
  );

  static const LinearGradient surface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF9FFFBF4),
      Color(0xEDFFF1DE),
    ],
  );

  static const LinearGradient surfaceWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF0D7),
      Color(0xFFFFF8ED),
    ],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF5A00),
      Color(0xFFFFA526),
    ],
  );

  static const LinearGradient accentSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFA543),
      Color(0xFFFFD79C),
    ],
  );

  static const LinearGradient whitePill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFAF2),
    ],
  );

  static const LinearGradient darkVignette = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x0F5F1C00),
      Color(0x1A4A1600),
    ],
    stops: [0.0, 0.7, 1.0],
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
