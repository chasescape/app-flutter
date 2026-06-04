import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Extended Color Utilities
class AppColors {
  // Primary colors
  static const Color primaryMain = AppTheme.primaryMain;
  static const Color secondaryMain = AppTheme.secondaryMain;
  static const Color accentMain = AppTheme.accentMain;

  // Semantic colors
  static const Color success = AppTheme.success;
  static const Color warning = AppTheme.warning;
  static const Color error = AppTheme.error;
  static const Color info = AppTheme.info;

  // Background
  static const Color bgPrimary = AppTheme.bgPrimary;
  static const Color bgSecondary = AppTheme.bgSecondary;
  static const Color bgTertiary = AppTheme.bgTertiary;
  static const Color bgCard = AppTheme.bgCard;
  static const Color bgOverlay = AppTheme.bgOverlay;

  // Text
  static const Color textPrimary = AppTheme.textPrimary;
  static const Color textSecondary = AppTheme.textSecondary;
  static const Color textDisabled = AppTheme.textDisabled;
  static const Color textAccent = AppTheme.textAccent;

  // Utility methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
