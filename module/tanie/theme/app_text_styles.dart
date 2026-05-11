import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  static const double fontSizeH1 = 32.0;
  static const double fontSizeH2 = 24.0;
  static const double fontSizeH3 = 20.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeCaption = 14.0;
  static const double fontSizeSmall = 12.0;

  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightBlack = FontWeight.w800;

  static const double lineHeightTight = 1.15;
  static const double lineHeightNormal = 1.45;
  static const double lineHeightRelaxed = 1.7;

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeH1,
    fontWeight: fontWeightBlack,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeH2,
    fontWeight: fontWeightBold,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeH3,
    fontWeight: fontWeightSemibold,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBody,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBody,
    fontWeight: fontWeightRegular,
    height: lineHeightRelaxed,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeCaption,
    fontWeight: fontWeightRegular,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
    color: AppColors.textTertiary,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBody,
    fontWeight: fontWeightBold,
    height: lineHeightNormal,
    letterSpacing: 0.2,
    color: AppColors.primaryContrastText,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBody,
    fontWeight: fontWeightSemibold,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );
}
