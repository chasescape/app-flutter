import 'package:flutter/material.dart';

/// App Theme Configuration - soft pastel glass style.
class AppTheme {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF36CFC0);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color accentRed = Color(0xFFFF6FAE);

  // Pastel Accent Colors
  static const Color accentPeach = Color(0xFFFFB68B);
  static const Color accentLemon = Color(0xFFFFD96A);
  static const Color accentMint = Color(0xFF8CF0C7);
  static const Color accentSky = Color(0xFFAED8FF);
  static const Color accentLavender = Color(0xFFC8C5FF);

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFE2E9);
  static const Color backgroundSecondary = Color(0xFFFFFBFE);
  static const Color backgroundTertiary = Color(0xFFFFF1BC);
  static const Color surfaceGlass = Color(0xDFFFFFFF);
  static const Color surfaceSoft = Color(0xFFFFF7FB);
  static const Color outlineSoft = Color(0x66FFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF352737);
  static const Color textSecondary = Color(0xFF806A78);
  static const Color textDisabled = Color(0xFFBCAAB5);
  static const Color textInverse = Color(0xFF352737);

  // Semantic Colors
  static const Color focusRing = Color(0xFFFF6FAE);
  static const Color hoverOverlay = Color(0x14FF6FAE);
  static const Color success = Color(0xFF42CFA7);
  static const Color warning = Color(0xFFFFB547);
  static const Color error = Color(0xFFE85D78);
  static const Color info = Color(0xFF5E9BFF);

  // Font Family
  static const String fontFamily = 'Inter';

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: accentRed,
        surface: backgroundSecondary,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundPrimary,
      cardColor: backgroundSecondary,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentRed,
          foregroundColor: primaryWhite,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceGlass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: accentRed,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryWhite.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: primaryWhite.withValues(alpha: 0.72)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: primaryWhite.withValues(alpha: 0.72)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: accentRed, width: 1.4),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: primaryGreen,
        secondary: accentRed,
      ),
      scaffoldBackgroundColor: const Color(0xFF241A29),
      cardColor: const Color(0xFF332638),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryWhite,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: primaryWhite,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static const LinearGradient candyGradient = LinearGradient(
    colors: [
      Color(0xFFFF8CB8),
      Color(0xFFFFC9A7),
      Color(0xFFFFE785),
      Color(0xFFCFF7D4),
      Color(0xFFC7D8FF),
    ],
    stops: [0, 0.28, 0.55, 0.78, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softSurfaceGradient = LinearGradient(
    colors: [
      Color(0xF5FFFFFF),
      Color(0xDBFFFFFF),
      Color(0xF2FFF6FB),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [
      accentRed,
      accentPeach,
      accentLemon,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient mintButtonGradient = LinearGradient(
    colors: [
      primaryGreen,
      accentMint,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Text Styles
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  // Spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: accentRed.withValues(alpha: 0.12),
          blurRadius: 30,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.72),
          blurRadius: 10,
          offset: const Offset(-4, -4),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: accentRed.withValues(alpha: 0.22),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get imageShadow => [
        BoxShadow(
          color: const Color(0xFFBE668A).withValues(alpha: 0.18),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ];
}
