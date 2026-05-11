import 'package:flutter/material.dart';

/// App Color System - Design Tokens
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryMain = Color(0xFFD999FF);
  static const Color primaryLight = Color(0xFFF2D6FF);
  static const Color primaryDark = Color(0xFF7E4FD3);
  static const Color primaryContrastText = Color(0xFFFFFFFF);

  // Secondary Colors
  static const Color secondaryMain = Color(0xFFFFB8EA);
  static const Color secondaryLight = Color(0xFFFFE4F7);
  static const Color secondaryDark = Color(0xFFE78AD0);

  // Accent Colors
  static const Color accentMain = Color(0xFF88A2FF);
  static const Color accentLight = Color(0xFFB8C5FF);
  static const Color accentDark = Color(0xFF5364D8);

  // Semantic Colors
  static const Color success = Color(0xFF81F0C3);
  static const Color warning = Color(0xFFFFD58F);
  static const Color error = Color(0xFFFF92B6);
  static const Color info = Color(0xFF96CBFF);

  // Background Colors
  static const Color backgroundPrimary = Color(0xFF090D2C);
  static const Color backgroundSecondary = Color(0xFF151A48);
  static const Color backgroundTertiary = Color(0xFF1F265C);
  static const Color backgroundOverlay = Color(0x88080A1C);

  // Text Colors
  static const Color textPrimary = Color(0xFFFDF9FF);
  static const Color textSecondary = Color(0xFFD5C8F4);
  static const Color textDisabled = Color(0xFF8F91C4);
  static const Color textMuted = Color(0xFFB7B0DB);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Glass Colors
  static const Color glassLight = Color(0x24FFFFFF);
  static const Color glassMedium = Color(0x1CFFFFFF);
  static const Color glassStrong = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassBorderStrong = Color(0x4DFFFFFF);
  static const Color softSurface = Color(0x33A293FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFC46CFF), Color(0xFFFF9AD8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF8AA2FF), Color(0xFFD6A1FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF06081F),
      Color(0xFF221257),
      Color(0xFF6D2A80),
      Color(0xFFF6B2B7)
    ],
    stops: [0.0, 0.36, 0.76, 1.0],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFCEBFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient mutedGradient = LinearGradient(
    colors: [Color(0x66FFFFFF), Color(0x33FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sheetGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x14FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: const Color(0xFF030413).withOpacity(0.16),
          offset: const Offset(0, 8),
          blurRadius: 16,
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: const Color(0xFF030413).withOpacity(0.26),
          offset: const Offset(0, 16),
          blurRadius: 36,
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: const Color(0xFF030413).withOpacity(0.34),
          offset: const Offset(0, 20),
          blurRadius: 52,
        ),
      ];

  static List<BoxShadow> get glowMd => [
        BoxShadow(
          color: primaryMain.withOpacity(0.22),
          offset: const Offset(0, 14),
          blurRadius: 28,
        ),
        BoxShadow(
          color: secondaryMain.withOpacity(0.16),
          offset: const Offset(0, 6),
          blurRadius: 18,
        ),
      ];
}
