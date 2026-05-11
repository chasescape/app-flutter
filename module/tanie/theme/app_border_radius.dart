import 'package:flutter/material.dart';

/// App Border Radius - Cyberpunk Design System
class AppBorderRadius {
  AppBorderRadius._();

  static const double small = 4.0;
  static const double medium = 6.0;
  static const double large = 8.0;
  static const double xlarge = 12.0;
  static const double xxlarge = 16.0;
  static const double xxxlarge = 20.0;
  static const double huge = 24.0;
  static const double full = 9999.0;

  // Aliases for compatibility
  static const double xl = xlarge;
  static const double xxl = xxlarge;
  static const double xxxl = xxxlarge;

  // Border Radius Objects
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumRadius = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(large));
  static const BorderRadius xlargeRadius = BorderRadius.all(Radius.circular(xlarge));
  static const BorderRadius xxlargeRadius = BorderRadius.all(Radius.circular(xxlarge));
  static const BorderRadius xxxlargeRadius = BorderRadius.all(Radius.circular(xxxlarge));
  static const BorderRadius hugeRadius = BorderRadius.all(Radius.circular(huge));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));

  // Common Shapes
  static const ShapeBorder cardShape = RoundedRectangleBorder(
    borderRadius: xxlargeRadius,
  );

  static const ShapeBorder buttonShape = RoundedRectangleBorder(
    borderRadius: largeRadius,
  );

  static const ShapeBorder inputShape = RoundedRectangleBorder(
    borderRadius: mediumRadius,
  );
}
