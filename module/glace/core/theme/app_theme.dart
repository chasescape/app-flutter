import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6D56F6);
  static const Color secondary = Color(0xFFF676BD);
  static const Color tertiary = Color(0xFF93B3FF);
  static const Color accent = Colors.white;
  static const Color accentSoft = Color(0xFFFFF5FB);
  static const Color accentPeach = Color(0xFFFFDDD5);

  static const Color success = Color(0xFF35C58A);
  static const Color warning = Color(0xFFFFAA67);
  static const Color error = Color(0xFFFF6B8B);
  static const Color info = Color(0xFF73B9FF);

  static const Color textPrimary = Color(0xFF2E2343);
  static const Color textSecondary = Color(0xFF7E7398);
  static const Color textTertiary = Color(0xFFADA2C4);
  static const Color textDisabled = Color(0xFFD5CEE3);
  static const Color textInverse = Colors.white;

  static const Color cardBg = Color(0xF7FFFFFF);
  static const Color cardBorder = Color(0x8FFFFFFF);
  static const Color cardBorderStrong = Color(0xD9FFFFFF);
  static const Color stickerBorder = Color(0x33FFFFFF);

  static const Color surface = Color(0xF7FFFFFF);
  static const Color surfaceStrong = Color(0xFFFFFFFF);
  static const Color surfaceWarm = Color(0xFFFDF7FC);
  static const Color surfaceHighlight = Color(0xFFF8EEFF);
  static const Color surfaceTint = Color(0xFFF0E7FF);
  static const Color dividerWarm = Color(0x1A563D98);
  static const Color overlay = Color(0x6B1E153A);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double xxl = 36;
  static const double full = 9999;
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
          surface: AppColors.surfaceStrong,
          error: AppColors.error,
          onPrimary: AppColors.textInverse,
          onSecondary: AppColors.textInverse,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceStrong,
          elevation: 0,
          shadowColor: const Color(0x22A969E7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceStrong,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          titleTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          contentTextStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.72),
            disabledForegroundColor: AppColors.primary.withValues(alpha: 0.58),
            shadowColor: const Color(0x33A060E8),
            elevation: 10,
            minimumSize: const Size.fromHeight(56),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.58),
              width: 1.2,
            ),
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.82),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.86),
              width: 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.86),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerWarm,
          thickness: 1,
        ),
      );

  static LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF93D1),
          Color(0xFFF7D7E2),
          Color(0xFFD4C4FF),
          Color(0xFF99B8FF),
        ],
        stops: [0.02, 0.42, 0.76, 1.0],
      );

  static LinearGradient get mistGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.04),
          Colors.white.withValues(alpha: 0.12),
        ],
      );

  static LinearGradient get glassGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.44),
          Colors.white.withValues(alpha: 0.20),
        ],
      );

  static LinearGradient get imageFadeGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x00000000),
          Color(0x09000000),
          Color(0x421F153B),
          Color(0x8A1F153B),
        ],
        stops: [0.0, 0.45, 0.76, 1.0],
      );

  static BoxDecoration get glassCardDecoration => BoxDecoration(
        gradient: glassGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.cardBorderStrong,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26A963E6),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      );

  static BoxDecoration surfaceCardDecoration({
    BorderRadius? borderRadius,
    Color color = AppColors.surface,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1EA35CE4),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x12FFFFFF),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      );
}
