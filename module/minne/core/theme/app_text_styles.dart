import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Text Styles - Daily Happiness Design System
/// Based on Erin Flink's modern social design expertise
class AppTextStyles {
  AppTextStyles._();

  // Font Family
  static const String fontFamily = 'Inter';

  // Font Sizes
  static const double h1 = 32.0;
  static const double h2 = 24.0;
  static const double h3 = 20.0;
  static const double body = 16.0;
  static const double caption = 14.0;
  static const double small = 12.0;

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Heading Styles
  static const TextStyle h1Style = TextStyle(
    fontSize: h1,
    fontWeight: bold,
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2Style = TextStyle(
    fontSize: h2,
    fontWeight: semibold,
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h3Style = TextStyle(
    fontSize: h3,
    fontWeight: semibold,
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Body Styles
  static const TextStyle bodyStyle = TextStyle(
    fontSize: body,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMediumStyle = TextStyle(
    fontSize: body,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySecondaryStyle = TextStyle(
    fontSize: body,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Caption Styles
  static const TextStyle captionStyle = TextStyle(
    fontSize: caption,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle captionMediumStyle = TextStyle(
    fontSize: caption,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Small Styles
  static const TextStyle smallStyle = TextStyle(
    fontSize: small,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Button Styles
  static const TextStyle buttonStyle = TextStyle(
    fontSize: body,
    fontWeight: semibold,
    fontFamily: fontFamily,
    color: AppColors.textInverse,
    height: 1.2,
  );

  static const TextStyle buttonSecondaryStyle = TextStyle(
    fontSize: body,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.primaryMain,
    height: 1.2,
  );

  // Inverse Styles
  static const TextStyle h1Inverse = TextStyle(
    fontSize: h1,
    fontWeight: bold,
    fontFamily: fontFamily,
    color: AppColors.textInverse,
    height: 1.2,
  );

  static const TextStyle bodyInverse = TextStyle(
    fontSize: body,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: AppColors.textInverse,
    height: 1.5,
  );
}
