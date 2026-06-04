import 'package:flutter/material.dart';

/// App Typography - Design System
/// Rounded, friendly typography system
class AppTypography {
  AppTypography._();

  // Font Family
  static const String fontFamily =
      'Nunito, -apple-system, BlinkMacSystemFont, sans-serif';
  static const String fontFamilySecondary = 'Nunito';
  static const String fontFamilyCode = 'monospace';

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

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.8;

  // Text Styles
  static const TextStyle h1Style = TextStyle(
    fontSize: h1,
    fontWeight: bold,
    letterSpacing: 0,
    height: lineHeightTight,
  );

  static const TextStyle h2Style = TextStyle(
    fontSize: h2,
    fontWeight: semibold,
    letterSpacing: 0,
    height: lineHeightTight,
  );

  static const TextStyle h3Style = TextStyle(
    fontSize: h3,
    fontWeight: semibold,
    height: lineHeightNormal,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: body,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: caption,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  static const TextStyle smallStyle = TextStyle(
    fontSize: small,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  // Themed Text Styles
  static TextStyle getH1TextStyle(Color color) =>
      h1Style.copyWith(color: color);
  static TextStyle getH2TextStyle(Color color) =>
      h2Style.copyWith(color: color);
  static TextStyle getH3TextStyle(Color color) =>
      h3Style.copyWith(color: color);
  static TextStyle getBodyTextStyle(Color color) =>
      bodyStyle.copyWith(color: color);
  static TextStyle getCaptionTextStyle(Color color) =>
      captionStyle.copyWith(color: color);
  static TextStyle getSmallTextStyle(Color color) =>
      smallStyle.copyWith(color: color);
}
