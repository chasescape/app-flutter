import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryMain = Color(0xFF17131D);
  static const Color primaryLight = Color(0xFF2B2437);
  static const Color primaryDark = Color(0xFF0E0A13);
  static const Color primaryContrastText = Color(0xFFFFFFFF);

  static const Color secondaryMain = Color(0xFF5B63FF);
  static const Color secondaryLight = Color(0xFFB9BCFF);
  static const Color secondaryDark = Color(0xFF434BCC);

  static const Color accentMain = Color(0xFFF5A7D3);
  static const Color accentLight = Color(0xFFFFD7EC);
  static const Color accentDark = Color(0xFFE087B9);

  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF4A83A);
  static const Color error = Color(0xFFE65E76);
  static const Color info = Color(0xFF5196FF);

  static const Color backgroundPrimary = Color(0xFFFFFBF8);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color backgroundTertiary = Color(0xFFF9F1F7);
  static const Color backgroundAccent = Color(0xFFFFE8F4);
  static const Color backgroundOverlay = Color(0x66FFF7FB);

  static const Color textPrimary = Color(0xFF241A2A);
  static const Color textSecondary = Color(0xFF74677B);
  static const Color textTertiary = Color(0xFFB7A9B7);
  static const Color textDisabled = Color(0xFFC7BBC7);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color borderStrong = Color(0xFF2C2540);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardMuted = Color(0xFFF8F3F8);
  static const Color cardBorder = Color(0xFFEEDFEA);
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE9DAE5);
  static const Color inputFocusedBorder = Color(0xFF5B63FF);
  static const Color buttonPrimary = Color(0xFF15101D);
  static const Color buttonSecondary = Color(0xFFFFFFFF);
  static const Color buttonDisabled = Color(0xFFE4D9E3);
  static const Color stickerDark = Color(0xFF1A1820);
  static const Color stickerText = Color(0xFFFFFFFF);
  static const Color photoOverlay = Color(0x400D0715);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFD4EA), Color(0xFFF5E7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFDCDE5), Color(0xFFF3B6E0), Color(0xFFFBE8F4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFFFF5F8), Color(0xFFF9F2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE9ECFF), Color(0xFFFFE6F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
