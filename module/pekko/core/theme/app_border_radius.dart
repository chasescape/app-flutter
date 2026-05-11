import 'package:flutter/material.dart';

/// App border radius system
class AppBorderRadius {
  AppBorderRadius._();

  static const double small = 12.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xlarge = 32.0;

  // BorderRadius objects
  static const BorderRadius allSmall = BorderRadius.all(Radius.circular(small));
  static const BorderRadius allMedium =
      BorderRadius.all(Radius.circular(medium));
  static const BorderRadius allLarge =
      BorderRadius.all(Radius.circular(large));
  static const BorderRadius allXLarge =
      BorderRadius.all(Radius.circular(xlarge));

  // Border radius for specific corners
  static const BorderRadius onlyTopMedium = BorderRadius.only(
    topLeft: Radius.circular(medium),
    topRight: Radius.circular(medium),
  );

  static const BorderRadius onlyBottomMedium = BorderRadius.only(
    bottomLeft: Radius.circular(medium),
    bottomRight: Radius.circular(medium),
  );
}
