import 'package:flutter/material.dart';

/// Application color system.
///
/// The palette is tuned to the reference: a soft mint canvas, warm cream
/// surfaces, powder pink glow, and a calm ink color for readability.
class AppColors {
  AppColors._();

  // ==================== Core Palette ====================
  static const Color dreamCream = Color(0xFFFFFCF5);
  static const Color mintMist = Color(0xFFE8FFF2);
  static const Color aquaMist = Color(0xFFD7FBF6);
  static const Color blushMist = Color(0xFFFFE3F8);
  static const Color lilacMist = Color(0xFFE8E2FF);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceWarm = Color(0xFFFFF8FD);
  static const Color surfaceMint = Color(0xFFF4FFF9);

  static const Color ink = Color(0xFF31423B);
  static const Color inkSoft = Color(0xFF63746D);
  static const Color inkMuted = Color(0xFF94A29B);

  static const Color rose = Color(0xFFEFA7DF);
  static const Color roseDeep = Color(0xFFBA70A9);
  static const Color mint = Color(0xFF8CE7C5);
  static const Color aqua = Color(0xFF82DCE5);
  static const Color lilac = Color(0xFFC7B7FF);

  // ==================== Legacy Accessors ====================
  static const Color primaryDark = dreamCream;
  static const Color backgroundLight = surfaceWarm;
  static const Color backgroundMedium = surfaceMint;

  static const Color secondaryPink = roseDeep;
  static const Color accentPink = rose;

  static Color neonPinkOpaque = rose.withOpacity(0.30);
  static Color neonPinkSubtle = rose.withOpacity(0.16);

  // ==================== Semantic Colors ====================
  static const Color successGreen = Color(0xFF3B9E77);
  static const Color warningOrange = Color(0xFFD8934C);
  static const Color errorRed = Color(0xFFD86672);
  static const Color infoBlue = Color(0xFF5B9ECF);

  // ==================== Text Colors ====================
  static const Color textPrimary = ink;
  static const Color textSecondary = inkSoft;
  static const Color textDisabled = inkMuted;
  static const Color textInverse = Color(0xFFFFFFFF);

  // ==================== Surface Colors ====================
  static const Color lightBackground = dreamCream;
  static const Color lightSurface = surface;

  // ==================== Gradients ====================
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      mintMist,
      dreamCream,
      blushMist,
      lilacMist,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [mint, rose, lilac],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGradient = LinearGradient(
    colors: [
      surface.withOpacity(0.82),
      surfaceWarm.withOpacity(0.76),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
        return infoBlue;
      case 'in progress':
      case 'inprogress':
        return warningOrange;
      case 'finished':
        return successGreen;
      default:
        return textSecondary;
    }
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
