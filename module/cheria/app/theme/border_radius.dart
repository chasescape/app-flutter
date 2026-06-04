import 'package:flutter/painting.dart';

/// App Border Radius - Design System
/// Consistent corner radius system
class AppBorderRadius {
  AppBorderRadius._();

  // Scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  // Specific Use Cases
  static const double buttonRadius = md;
  static const double cardRadius = lg;
  static const double inputRadius = md;
  static const double dialogRadius = lg;
  static const double chipRadius = sm;
  static const double fabRadius = xl;
  static const double imageRadius = md;

  // Border Radius Objects
  static const BorderRadius allXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius allSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius allMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius allLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius allXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius allFull = BorderRadius.all(Radius.circular(full));
}
