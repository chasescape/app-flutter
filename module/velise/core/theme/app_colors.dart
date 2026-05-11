import 'package:flutter/material.dart';

/// App Colors - Design System
/// Deep violet launch-inspired palette with warm editorial surfaces.
class AppColors {
  AppColors._();

  // Brand colors
  static const Color primaryMain = Color(0xFFA25DFF);
  static const Color primaryLight = Color(0xFFD6B4FF);
  static const Color primaryDark = Color(0xFF6723D0);
  static const Color primaryContrast = Color(0xFFFFFFFF);

  // Surface and accent colors
  static const Color secondaryMain = Color(0xFFFFF5EC);
  static const Color secondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryDark = Color(0xFFEADACF);

  static const Color accentMain = Color(0xFFFFC278);
  static const Color accentLight = Color(0xFFFFDDB4);
  static const Color accentDark = Color(0xFFFF985E);

  // Semantic Colors
  static const Color success = Color(0xFF3FC781);
  static const Color warning = Color(0xFFFFB54A);
  static const Color error = Color(0xFFFF6B85);
  static const Color info = Color(0xFF75B5FF);

  // Background Colors
  static const Color backgroundPrimary = Color(0xFF090312);
  static const Color backgroundSecondary = Color(0xFF14091F);
  static const Color backgroundTertiary = Color(0xFF231036);
  static const Color backgroundOverlay = Color(0x8C05010B);

  // Surface Colors
  static const Color surfacePrimary = Color(0xFFFFF8F2);
  static const Color surfaceSecondary = Color(0x14FFFFFF);
  static const Color surfaceElevated = Color(0x20FFFFFF);
  static const Color surfaceTint = Color(0x26C79BFF);

  // Borders
  static const Color borderPrimary = Color(0x24FFFFFF);
  static const Color borderStrong = Color(0x40FFFFFF);
  static const Color borderAccent = Color(0x4DA25DFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFF7F0FF);
  static const Color textSecondary = Color(0xCCDDD0F1);
  static const Color textDisabled = Color(0x8075688E);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textOnSurface = Color(0xFF20112C);
  static const Color textOnSurfaceMuted = Color(0xFF6E5E83);
  static const Color textOnSurfaceSoft = Color(0xFF9B8AAA);

  // Gradients
  static const LinearGradient lavenderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB570FF), Color(0xFF8D32F8), Color(0xFFCF8BFF)],
  );

  static const LinearGradient pinkPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF13051B), Color(0xFF2D0E47), Color(0xFF5A1A8F)],
  );

  static const LinearGradient nightfallGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8B27FF), Color(0xFF2B054A), Color(0xFF07020D)],
    stops: [0.0, 0.35, 1.0],
  );

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDF7FF), Color(0xFFF8EFE8)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x29FFFFFF), Color(0x14FFFFFF)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF9F1), Color(0xFFF6E7FF)],
  );

  static const LinearGradient photoScrimGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x14000000), Color(0xAA090312)],
  );
}
