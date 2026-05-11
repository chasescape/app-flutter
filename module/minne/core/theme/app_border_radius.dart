import 'package:flutter/material.dart';

/// App Border Radius - Daily Happiness Design System
/// Based on Erin Flink's modern social design expertise
class AppBorderRadius {
  AppBorderRadius._();

  // Radius Values
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  // BorderRadius Objects
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(full));

  // Common Shapes
  static const RoundedRectangleBorder shapeSM = RoundedRectangleBorder(borderRadius: borderRadiusSM);
  static const RoundedRectangleBorder shapeMD = RoundedRectangleBorder(borderRadius: borderRadiusMD);
  static const RoundedRectangleBorder shapeLG = RoundedRectangleBorder(borderRadius: borderRadiusLG);
  static const RoundedRectangleBorder shapeXL = RoundedRectangleBorder(borderRadius: borderRadiusXL);
  static const RoundedRectangleBorder shapeXXL = RoundedRectangleBorder(borderRadius: borderRadiusXXL);

  // Stadium Shape (for buttons)
  static const StadiumBorder stadiumBorder = StadiumBorder();
}
