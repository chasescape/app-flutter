import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  static const List<double> scale = [4, 8, 12, 16, 20, 24, 32, 40, 48, 64];

  static List<BoxShadow> get shadowSm => [
        const BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
      ];

  static List<BoxShadow> get shadowMd => [
        const BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
      ];

  static List<BoxShadow> get shadowLg => [
        const BoxShadow(color: Color(0x29000000), blurRadius: 32, offset: Offset(0, 8)),
      ];

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
}
