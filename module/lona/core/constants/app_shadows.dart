import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -6,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 36,
      offset: Offset(0, 14),
      spreadRadius: -10,
    ),
  ];

  static List<BoxShadow> neon(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.16),
        blurRadius: 32,
        offset: const Offset(0, 14),
        spreadRadius: -10,
      ),
    ];
  }

  static List<BoxShadow> neonGlowStrong(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.18),
        blurRadius: 48,
        offset: const Offset(0, 18),
        spreadRadius: -12,
      ),
    ];
  }

  static List<BoxShadow> neonBorder(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.12),
        blurRadius: 18,
        offset: const Offset(0, 10),
        spreadRadius: -8,
      ),
    ];
  }

  static const List<BoxShadow> cardElevation = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 28,
      offset: Offset(0, 14),
      spreadRadius: -10,
    ),
  ];
}
