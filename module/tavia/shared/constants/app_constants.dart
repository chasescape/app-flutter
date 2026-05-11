import 'package:flutter/material.dart';

/// App Constants - Design System Values
/// Mina Laurent Design Style
class AppConstants {
  AppConstants._();

  // Spacing System (base unit: 8)
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Shadows
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 8),
      blurRadius: 32,
    ),
  ];

  // Animation Duration
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // Animation Curve
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;

  // Screen Padding
  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 16.0;

  // Card Elevation
  static const double cardElevation = 0.0;

  // Button Height
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Icon Size
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;

  // Avatar Size
  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 48.0;
  static const double avatarSizeLg = 64.0;
  static const double avatarSizeXl = 96.0;

  // Image Aspect Ratio
  static const double imageAspectRatioSquare = 1.0;
  static const double imageAspectRatioPortrait = 3.0 / 4.0;
  static const double imageAspectRatioLandscape = 16.0 / 9.0;

  // Grid
  static const int gridCrossAxisCountSm = 2;
  static const int gridCrossAxisCountMd = 3;
  static const double gridSpacing = 12.0;
  static const double gridRunSpacing = 12.0;

  // List
  static const double listItemHeight = 72.0;
  static const double listPadding = 8.0;
}
