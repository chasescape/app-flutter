import 'package:flutter/material.dart';

class AppBorder {
  AppBorder._();

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXLarge));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // Border Widths
  static const double borderThin = 1.0;
  static const double borderMedium = 2.0;
  static const double borderThick = 3.0;

  // Border Styles
  static Border borderThinGrey = Border.all(
    width: borderThin,
    color: const Color(0xFFE0E0E0),
  );

  static Border borderMediumPrimary = Border.all(
    width: borderMedium,
    color: const Color(0xFFE63946),
  );
}
