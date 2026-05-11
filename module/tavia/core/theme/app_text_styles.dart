import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type styles tuned for a soft, rounded, candy-like UI.
class AppTextStyles {
  AppTextStyles._();

  static const double fontSizeH1 = 34.0;
  static const double fontSizeH2 = 26.0;
  static const double fontSizeH3 = 20.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeCaption = 14.0;
  static const double fontSizeSmall = 12.0;

  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w800;

  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;

  static const TextStyle h1 = TextStyle(
    fontSize: fontSizeH1,
    fontWeight: fontWeightBold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: fontSizeH2,
    fontWeight: fontWeightSemibold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: fontSizeH3,
    fontWeight: fontWeightSemibold,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: fontWeightRegular,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: fontWeightSemibold,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: fontWeightRegular,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionMedium = TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle small = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: fontWeightRegular,
    height: lineHeightNormal,
    color: AppColors.textDisabled,
  );

  static const TextStyle button = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: fontWeightSemibold,
    height: lineHeightNormal,
    color: AppColors.primaryContrastText,
    letterSpacing: -0.1,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
    color: AppColors.primaryContrastText,
  );

  static const TextStyle label = TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
