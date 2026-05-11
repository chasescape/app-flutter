import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Shadows - Daily Happiness Design System
/// Based on Erin Flink's modern social design expertise
class AppShadows {
  AppShadows._();

  // Shadow Levels
  static const List<BoxShadow> shadowSM = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> shadowMD = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> shadowLG = [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(0, 8),
      blurRadius: 32,
    ),
  ];

  // Card Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Button Shadow
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Floating Shadow
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}
