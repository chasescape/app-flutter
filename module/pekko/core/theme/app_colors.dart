import 'package:flutter/material.dart';

/// Deeper plum-lavender color system with clearer contrast and minimal surfaces.
class AppColors {
  AppColors._();

  // Brand tones
  static const Color primary = Color(0xFF4E3478);
  static const Color primaryLight = Color(0xFF7351A3);
  static const Color primaryDark = Color(0xFF341F56);
  static const Color primaryContrastText = Color(0xFFFCFAFF);

  static const Color secondary = Color(0xFF9377C6);
  static const Color secondaryLight = Color(0xFFC4B0E8);
  static const Color secondaryDark = Color(0xFF64458F);

  static const Color accent = Color(0xFFDDD2F2);
  static const Color accentLight = Color(0xFFF1EBFB);
  static const Color accentDark = Color(0xFFAF99D8);

  // Semantic colors
  static const Color success = Color(0xFF6E8A7B);
  static const Color warning = Color(0xFFB79A65);
  static const Color error = Color(0xFFB87486);
  static const Color info = Color(0xFF6851A0);

  // Surfaces
  static const Color backgroundPrimary = Color(0xFFF5F1FB);
  static const Color backgroundSecondary = Color(0xFFEAE1F7);
  static const Color backgroundTertiary = Color(0xFFD7C8EE);
  static const Color backgroundElevated = Color(0xFFFFFCFF);
  static const Color backgroundOverlay = Color(0x66000000);

  // Text
  static const Color textPrimary = Color(0xFF241835);
  static const Color textSecondary = Color(0xFF5F5079);
  static const Color textMuted = Color(0xFF8E80AA);
  static const Color textDisabled = Color(0xFFB9ADD0);
  static const Color textInverse = Color(0xFFFEFCFF);

  // Plum gradients
  static const List<Color> heroGradient = [
    Color(0xFF45286E),
    Color(0xFF68469A),
    Color(0xFF967AC6),
  ];

  // Backward-compatible alias for existing pages that still reference the
  // previous theme token.
  static const List<Color> sunsetGradient = heroGradient;

  static const List<Color> cardGradient = [
    Color(0xFFF4EEFD),
    Color(0xFFE4D9F8),
  ];

  static const List<Color> softHighlightGradient = [
    Color(0xFFFFFCFF),
    Color(0xFFEFE7FB),
  ];

  // Decorative layers
  static const Color glassBackground = Color(0x26FFFDFE);
  static const Color glassBorder = Color(0x52CBB7EF);
  static const Color oliveMist = Color(0x332C2340);
  static const Color goldLine = Color(0xFF9878CB);

  // Cards
  static const Color cardBackground = Color(0xFFFFFCFF);
  static const Color cardBackgroundSecondary = Color(0xFFEEE6FA);
  static const Color cardBackgroundDark = Color(0xFF4B2F78);
  static const Color cardShadow = Color(0x162E2145);

  // Shimmer / placeholders
  static const Color shimmerBase = Color(0xFFDDCFF3);
  static const Color shimmerHighlight = Color(0xFFF6F0FE);
}
