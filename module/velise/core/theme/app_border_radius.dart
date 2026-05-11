import 'package:flutter/material.dart';

/// App Border Radius - Design System
/// Soft rounded radii matching the launch and screenshot references.
class AppBorderRadius {
  AppBorderRadius._();

  static const double small = 14.0;
  static const double medium = 20.0;
  static const double large = 28.0;
  static const double xlarge = 36.0;
  static const double full = 999.0;

  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(large));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xlarge));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));

  static const BorderRadius cardRadius = lgRadius;
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(large),
  );
}
