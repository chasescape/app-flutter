import 'package:flutter/material.dart';

/// App Shadows - Design System
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> smShadow = [
    BoxShadow(
      color: Color(0x22000000),
      offset: Offset(0, 8),
      blurRadius: 18,
    ),
  ];

  static const List<BoxShadow> mdShadow = [
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(0, 12),
      blurRadius: 28,
    ),
  ];

  static const List<BoxShadow> lgShadow = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 20),
      blurRadius: 44,
    ),
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0x339C44FF),
      offset: Offset(0, 0),
      blurRadius: 42,
      spreadRadius: 2,
    ),
  ];

  static const List<BoxShadow> cardShadow = mdShadow;
  static const List<BoxShadow> buttonShadow = smShadow;
}
