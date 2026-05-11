import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Text system with serif-forward editorial headings and clean body text.
class AppTextStyles {
  AppTextStyles._();

  static const String headingFontFamily = 'Georgia';
  static const String bodyFontFamily = 'SF Pro Text';

  static const TextStyle display = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w400,
    fontFamily: headingFontFamily,
    color: AppColors.textPrimary,
    height: 1.08,
    letterSpacing: -0.8,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    fontFamily: headingFontFamily,
    color: AppColors.textPrimary,
    height: 1.14,
    letterSpacing: -0.4,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    fontFamily: headingFontFamily,
    color: AppColors.textPrimary,
    height: 1.18,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w500,
    fontFamily: bodyFontFamily,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: bodyFontFamily,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: bodyFontFamily,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: bodyFontFamily,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: bodyFontFamily,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: bodyFontFamily,
    color: AppColors.textMuted,
    height: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: bodyFontFamily,
    color: AppColors.textInverse,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: bodyFontFamily,
    color: AppColors.textInverse,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: bodyFontFamily,
    color: AppColors.textSecondary,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: bodyFontFamily,
    color: AppColors.textMuted,
    height: 1.2,
    letterSpacing: 0.6,
  );

  static const TextStyle inverse = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: bodyFontFamily,
    color: AppColors.textInverse,
    height: 1.5,
  );
}
