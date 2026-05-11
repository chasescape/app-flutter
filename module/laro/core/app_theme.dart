import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryMain = Color(0xFFFF4FA3);
  static const Color primaryLight = Color(0xFFFF8BC8);
  static const Color primaryDark = Color(0xFFE83C8B);

  static const Color secondaryMain = Color(0xFFFFC7E1);
  static const Color secondaryLight = Color(0xFFFFE6F2);
  static const Color secondaryDark = Color(0xFFF5A9CB);

  static const Color accentMain = Color(0xFFFFD954);
  static const Color accentLight = Color(0xFFFFE891);
  static const Color accentDark = Color(0xFFF1BA2A);

  static const Color success = Color(0xFF31B67A);
  static const Color warning = Color(0xFFFFA53D);
  static const Color error = Color(0xFFE96583);
  static const Color info = Color(0xFF6D8BFF);

  static const Color backgroundPrimary = Color(0xFFFFF7FB);
  static const Color backgroundSecondary = Color(0xFFFFEAF4);
  static const Color backgroundTertiary = Color(0xFFFCD4E6);
  static const Color backgroundOverlay = Color(0xF7FFFFFF);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFF6DCE8);

  static const Color textPrimary = Color(0xFF271520);
  static const Color textSecondary = Color(0xFF755469);
  static const Color textDisabled = Color(0xFFB091A3);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 28.0;
  static const double radiusXLarge = 36.0;

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD9EC),
      Color(0xFFFFA9D1),
      Color(0xFFFF7FB8),
    ],
  );

  static const LinearGradient blushGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF4FA),
      Color(0xFFFFE3F0),
      Color(0xFFFFD4E8),
    ],
  );

  static BoxShadow shadow([Color color = primaryMain, double opacity = 0.16]) {
    return BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 28,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryMain,
      secondary: secondaryMain,
      tertiary: accentMain,
      surface: surfaceColor,
      error: error,
      onPrimary: textInverse,
      onSecondary: textPrimary,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMain,
          foregroundColor: textInverse,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: textPrimary.withValues(alpha: 0.12)),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge),
          ),
          backgroundColor: surfaceColor.withValues(alpha: 0.75),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor.withValues(alpha: 0.88),
        hintStyle: const TextStyle(
          color: textDisabled,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: textPrimary.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: textPrimary.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide:
              BorderSide(color: primaryMain.withValues(alpha: 0.5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: textInverse),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: textPrimary.withValues(alpha: 0.08),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.05,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          height: 1.1,
        ),
        displaySmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.12,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textDisabled,
          height: 1.4,
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
