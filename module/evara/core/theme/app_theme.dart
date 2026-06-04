import 'package:flutter/material.dart';

/// App theme configuration for Evara's neon editorial style.
class AppTheme {
  // Brand colors
  static const Color primaryMain = Color(0xFFFF4FA3);
  static const Color primaryLight = Color(0xFFFF7ABB);
  static const Color primaryDark = Color(0xFFB81D6E);
  static const Color primaryContrast = Color(0xFFFFFFFF);

  static const Color secondaryMain = Color(0xFFFF8C5A);
  static const Color secondaryLight = Color(0xFFFFB17D);
  static const Color secondaryDark = Color(0xFFE0602E);

  static const Color accentMain = Color(0xFFFFD76A);
  static const Color accentLight = Color(0xFFFFE79F);
  static const Color accentDark = Color(0xFFE7B33B);

  // Semantic colors
  static const Color success = Color(0xFF45D7A3);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B7A);
  static const Color info = Color(0xFF79C6FF);

  // Background colors
  static const Color bgPrimary = Color(0xFF16021F);
  static const Color bgSecondary = Color(0xFF261034);
  static const Color bgTertiary = Color(0xFF3A1849);
  static const Color bgOverlay = Color(0xB3000000);
  static const Color bgCard = Color(0xCC2A123A);
  static const Color bgCardStrong = Color(0xE6351648);
  static const Color stroke = Color(0x59FFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFFFDF7FF);
  static const Color textSecondary = Color(0xCCF6DDF6);
  static const Color textDisabled = Color(0x809F87AF);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textAccent = Color(0xFFFFD76A);

  // Typography
  static const String fontFamily = 'Inter';
  static const double h1 = 32.0;
  static const double h2 = 24.0;
  static const double h3 = 20.0;
  static const double body = 16.0;
  static const double caption = 14.0;
  static const double small = 12.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Radius
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 999.0;

  // Shadow system
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 28,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x59000000),
      blurRadius: 40,
      offset: Offset(0, 24),
    ),
  ];

  // Animation
  static const Duration durationFast = Duration(milliseconds: 180);
  static const Duration durationNormal = Duration(milliseconds: 280);
  static const Duration durationSlow = Duration(milliseconds: 420);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryMain,
      brightness: Brightness.dark,
      primary: primaryMain,
      secondary: secondaryMain,
      error: error,
      surface: bgPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(
        onPrimary: textInverse,
        onSecondary: textInverse,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bgPrimary,
      canvasColor: bgPrimary,
      splashColor: primaryMain.withValues(alpha: 0.12),
      highlightColor: Colors.transparent,
      dividerColor: Colors.white.withValues(alpha: 0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: h2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMain,
          foregroundColor: textInverse,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
          disabledForegroundColor: textDisabled,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: const TextStyle(
            fontSize: body,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: const TextStyle(
            fontSize: body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: const TextStyle(
            fontSize: caption,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        hintStyle: const TextStyle(
          color: textDisabled,
          fontSize: body,
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryLight, width: 1.4),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryMain,
        foregroundColor: textInverse,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: h1,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: h2,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.15,
        ),
        displaySmall: TextStyle(
          fontSize: h3,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: body,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: caption,
          color: textSecondary,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: small,
          color: textDisabled,
          height: 1.4,
        ),
      ),
    );
  }

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF49A2),
      Color(0xFFFF7A63),
      Color(0xFFFFC05F),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF53216A),
      Color(0xFFB12470),
      Color(0xFFFF9158),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF14021E),
      Color(0xFF240629),
      Color(0xFF110016),
    ],
  );

  static const LinearGradient goldenOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0xBF120014),
    ],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B7A),
      Color(0xFFE64876),
    ],
  );
}
