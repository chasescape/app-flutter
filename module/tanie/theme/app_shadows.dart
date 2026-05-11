import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x10000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 10),
      blurRadius: 24,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x19000000),
      offset: Offset(0, 18),
      blurRadius: 40,
    ),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x120A0910),
      offset: Offset(0, 8),
      blurRadius: 18,
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x120B0712),
      offset: Offset(0, 12),
      blurRadius: 32,
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x1F101019),
      offset: Offset(0, 8),
      blurRadius: 20,
    ),
  ];

  static const List<BoxShadow> input = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x26F5A7D3),
      offset: Offset(0, 10),
      blurRadius: 24,
    ),
  ];
}
