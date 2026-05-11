import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Color(0x140D0610),
      offset: Offset(0, 6),
      blurRadius: 18,
    ),
  ];

  static const List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Color(0x1F25111F),
      offset: Offset(0, 14),
      blurRadius: 32,
      spreadRadius: -10,
    ),
  ];

  static const List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Color(0x261D0E18),
      offset: Offset(0, 20),
      blurRadius: 50,
      spreadRadius: -14,
    ),
  ];

  static const List<BoxShadow> shadowNeon = [
    BoxShadow(
      color: Color(0x40F55CA8),
      offset: Offset(0, 0),
      blurRadius: 26,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> shadowWithColor(Color color, {double opacity = 0.15}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: const Offset(0, 14),
        blurRadius: 30,
        spreadRadius: -10,
      ),
    ];
  }
}
