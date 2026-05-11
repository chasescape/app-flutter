import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Text Styles - Design System
/// Built around a minimal editorial hierarchy for photo-first screens.
class AppTextStyles {
  AppTextStyles._();

  static const double display = 42.0;
  static const double h1 = 34.0;
  static const double h2 = 28.0;
  static const double h3 = 22.0;
  static const double body = 16.0;
  static const double caption = 14.0;
  static const double small = 12.0;
  static const double micro = 11.0;

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const double tight = 1.08;
  static const double normal = 1.38;
  static const double relaxed = 1.6;

  static const TextStyle displayStyle = TextStyle(
    fontSize: display,
    fontWeight: bold,
    height: tight,
    letterSpacing: -1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle accentStyle = TextStyle(
    fontSize: 30,
    fontWeight: semibold,
    fontStyle: FontStyle.italic,
    height: tight,
    color: AppColors.textPrimary,
  );

  static const TextStyle eyebrowStyle = TextStyle(
    fontSize: micro,
    fontWeight: semibold,
    height: normal,
    letterSpacing: 2.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle h1Style = TextStyle(
    fontSize: h1,
    fontWeight: bold,
    height: tight,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2Style = TextStyle(
    fontSize: h2,
    fontWeight: semibold,
    height: tight,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3Style = TextStyle(
    fontSize: h3,
    fontWeight: medium,
    height: normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: body,
    fontWeight: regular,
    height: normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: caption,
    fontWeight: regular,
    height: normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle smallStyle = TextStyle(
    fontSize: small,
    fontWeight: regular,
    height: normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: body,
    fontWeight: semibold,
    height: normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonSmallStyle = TextStyle(
    fontSize: caption,
    fontWeight: medium,
    height: normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle surfaceTitleStyle = TextStyle(
    fontSize: h2,
    fontWeight: semibold,
    height: tight,
    letterSpacing: -0.4,
    color: AppColors.textOnSurface,
  );

  static const TextStyle surfaceBodyStyle = TextStyle(
    fontSize: body,
    fontWeight: regular,
    height: relaxed,
    color: AppColors.textOnSurfaceMuted,
  );

  static const TextStyle surfaceMetaStyle = TextStyle(
    fontSize: caption,
    fontWeight: medium,
    height: normal,
    color: AppColors.textOnSurfaceSoft,
  );
}
