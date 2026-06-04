import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryMain = Color(0xFFFFEC3D);
  static const Color primaryLight = Color(0xFFFFF8B5);
  static const Color primaryDark = Color(0xFFFFC729);
  static const Color primaryContrast = Color(0xFF161208);

  static const Color secondaryMain = Color(0xFFD7FF5B);
  static const Color secondaryLight = Color(0xFFEEFFAA);
  static const Color secondaryDark = Color(0xFF9DCC1E);

  static const Color accentMain = Color(0xFFFFC8E1);
  static const Color accentLight = Color(0xFFFFE9F4);
  static const Color accentDark = Color(0xFFF1A2C8);

  static const Color success = Color(0xFF3FB86A);
  static const Color warning = Color(0xFFF3A300);
  static const Color error = Color(0xFFE24E4E);
  static const Color info = Color(0xFF4A9DFF);

  static const Color ink = Color(0xFF161208);
  static const Color bgPrimary = Color(0xFFFFFBF2);
  static const Color bgSecondary = Color(0xFFFFF4D0);
  static const Color bgTertiary = Color(0xFFF8E9AF);
  static const Color bgOverlay = Color(0x8A161208);

  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF615948);
  static const Color textDisabled = Color(0xFFB8B094);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const double radiusSmall = 10.0;
  static const double radiusMedium = 18.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFBF3),
      Color(0xFFFFF8EC),
      Color(0xFFFFFDF7),
    ],
    stops: [0.0, 0.48, 1.0],
  );

  static const LinearGradient highlightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF57F),
      Color(0xFFFFE82D),
      Color(0xFFFFF094),
    ],
  );

  static const LinearGradient limeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8FF8D),
      Color(0xFFD8FF5B),
    ],
  );

  static const LinearGradient blushGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF1F7),
      Color(0xFFFFD9EA),
    ],
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: ink.withValues(alpha: 0.07),
          blurRadius: 24,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: primaryMain.withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primaryMain.withValues(alpha: 0.28),
          blurRadius: 36,
          spreadRadius: 1,
          offset: const Offset(0, 12),
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryMain,
        secondary: secondaryMain,
        tertiary: accentMain,
        surface: bgPrimary,
        error: error,
        onPrimary: primaryContrast,
        onSecondary: primaryContrast,
        onTertiary: primaryContrast,
        onSurface: textPrimary,
        onError: primaryContrast,
      ),
      scaffoldBackgroundColor: bgPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white.withValues(alpha: 0.82),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(
            color: ink.withValues(alpha: 0.06),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMain,
          foregroundColor: primaryContrast,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
            side: BorderSide(color: ink.withValues(alpha: 0.08)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(
            color: ink.withValues(alpha: 0.14),
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.78),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: textDisabled,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(
            color: ink.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(
            color: ink.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: error, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.76),
        disabledColor: bgSecondary,
        selectedColor: primaryMain,
        secondarySelectedColor: primaryMain,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingSm,
          vertical: spacingXs,
        ),
        side: BorderSide(color: ink.withValues(alpha: 0.08)),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: textPrimary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: ink.withValues(alpha: 0.08),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.45,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.45,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.normal,
          height: 1.35,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
    );
  }
}
