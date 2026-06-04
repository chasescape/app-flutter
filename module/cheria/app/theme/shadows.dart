import 'package:flutter/painting.dart';

/// App Shadows - Design System
/// Layered shadow system for depth
class AppShadows {
  AppShadows._();

  // Shadow Levels
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 8),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  // Specific Use Cases
  static const List<BoxShadow> card = md;
  static const List<BoxShadow> button = sm;
  static const List<BoxShadow> dialog = lg;
  static const List<BoxShadow> fab = md;

  // Neon Glow Effect (for Jason 'Neon' Chan style)
  static List<BoxShadow> neonGlow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          offset: const Offset(0, 0),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: color.withOpacity(0.2),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];
}
