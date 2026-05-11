import 'package:flutter/material.dart';

/// App shadow system
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x102C2340),
      offset: Offset(0, 8),
      blurRadius: 18,
      spreadRadius: -10,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x142C2340),
      offset: Offset(0, 14),
      blurRadius: 26,
      spreadRadius: -14,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x182C2340),
      offset: Offset(0, 20),
      blurRadius: 34,
      spreadRadius: -16,
    ),
  ];

  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x102C2340),
      offset: Offset(0, 10),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> inner = [
    BoxShadow(
      color: Color(0x122C2340),
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 1,
    ),
  ];
}
