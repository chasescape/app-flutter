import 'package:flutter/material.dart';

/// App Border Radius System - Design Tokens
class AppBorderRadius {
  AppBorderRadius._();

  // Radius Values
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  // BorderRadius
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(full));

  // RoundedRectangleBorder
  static const RoundedRectangleBorder shapeSm = RoundedRectangleBorder(borderRadius: borderRadiusSm);
  static const RoundedRectangleBorder shapeMd = RoundedRectangleBorder(borderRadius: borderRadiusMd);
  static const RoundedRectangleBorder shapeLg = RoundedRectangleBorder(borderRadius: borderRadiusLg);
  static const RoundedRectangleBorder shapeXl = RoundedRectangleBorder(borderRadius: borderRadiusXl);
}
