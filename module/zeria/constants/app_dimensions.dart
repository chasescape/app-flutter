import 'package:flutter/material.dart';

// App Dimensions - Vera 'Plum' Qian Design System
class AppDimensions {
  // Spacing Scale (base unit: 8)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Border Radius
  static const double radiusNone = 0;
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;
  static const double radiusFull = 9999;

  // Icon Sizes
  static const double iconSmall = 16;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;

  // Stroke Widths
  static const double strokeThin = 1;
  static const double strokeNormal = 2;
  static const double strokeThick = 3;

  // Elevations (Shadows)
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x1E000000),
      offset: Offset(0, 8),
      blurRadius: 32,
    ),
  ];

  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets horizontalPadding =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: md);

  // Card Padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  // Button Padding
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: xl, vertical: md);

  // Input Padding
  static const EdgeInsets inputPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
}
