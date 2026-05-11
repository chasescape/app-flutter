import 'dart:ui';
import 'package:flutter/painting.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primaryMain = Color(0xFF1A0A2E);
  static const Color primaryLight = Color(0xFF1A0A2E);
  static const Color primaryDark = Color(0xFF1A0A2E);

  // Secondary
  static const Color secondaryMain = Color(0xFFC850C0);
  static const Color secondaryLight = Color(0xFFC850C0);
  static const Color secondaryDark = Color(0xFFC850C0);

  // Accent
  static const Color accentMain = Color(0xFFFF6EC7);
  static const Color accentLight = Color(0xFFFF6EC7);
  static const Color accentDark = Color(0xFFFF6EC7);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Background
  static const Color backgroundPrimary = Color(0xFF1A0A2E);
  static const Color backgroundSecondary = Color(0xFFC850C0);
  static const Color backgroundTertiary = Color(0xFFFF6EC7);
  static const Color backgroundOverlay = Color(0x1AFFFFFF);

  // Card backgrounds
  static const Color cardBg = Color(0x1AFFFFFF);
  static const Color cardBorder = Color(0x33FFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF666666);
  static const Color textInverse = Color(0xFF000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A0A2E), Color(0xFF2D1B69)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFC850C0), Color(0xFFFF6EC7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFFC850C0), Color(0xFFFF6EC7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient coinCardGradient = LinearGradient(
    colors: [Color(0xFFFF8AE4), Color(0xFFD700F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neon glow
  static const Color neonGlow = Color(0xFFC850C0);
}
