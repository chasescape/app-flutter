import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // Font Family
  static const String fontFamily = 'Inter';

  // Font Sizes
  static const double fontSizeH1 = 32.0;
  static const double fontSizeH2 = 24.0;
  static const double fontSizeH3 = 20.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeCaption = 14.0;
  static const double fontSizeSmall = 12.0;

  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.8;

  // Text Styles
  static const TextStyle h1 = TextStyle(
    fontSize: fontSizeH1,
    fontWeight: fontWeightBold,
    height: lineHeightTight,
    fontFamily: fontFamily,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: fontSizeH2,
    fontWeight: fontWeightSemiBold,
    height: lineHeightNormal,
    fontFamily: fontFamily,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: fontSizeH3,
    fontWeight: fontWeightSemiBold,
    height: lineHeightNormal,
    fontFamily: fontFamily,
  );

  static const TextStyle body = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: fontWeightRegular,
    height: lineHeightNormal,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: fontWeightMedium,
    height: lineHeightNormal,
    fontFamily: fontFamily,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: fontWeightRegular,
    height: lineHeightNormal,
    fontFamily: fontFamily,
  );

  static const TextStyle small = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: fontWeightRegular,
    height: lineHeightNormal,
    fontFamily: fontFamily,
  );

  static const TextStyle button = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: fontWeightSemiBold,
    height: lineHeightNormal,
    fontFamily: fontFamily,
  );

  // Helper methods for colored text styles
  static TextStyle primary(Color color) => body.copyWith(color: color);
  static TextStyle secondary(Color color) => caption.copyWith(color: color);
}
