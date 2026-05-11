import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';
import 'app_border_radius.dart';
import 'app_shadows.dart';

/// App Theme - Daily Happiness Design System
/// Based on Erin Flink's modern social design expertise
class AppTheme {
  AppTheme._();

  // Animation Duration
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // Animation Curve
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryMain,
        secondary: AppColors.secondaryMain,
        tertiary: AppColors.accentMain,
        surface: AppColors.bgPrimary,
        error: AppColors.error,
        onPrimary: AppColors.primaryContrast,
        onSecondary: AppColors.textInverse,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textInverse,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.bgPrimary,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.h3Style,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: AppBorderRadius.shapeLG,
        color: AppColors.cardBg,
        margin: AppSpacing.paddingCard,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          padding: AppSpacing.paddingMD,
          shape: AppBorderRadius.stadiumBorder,
          textStyle: AppTextStyles.buttonStyle,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          side: const BorderSide(color: AppColors.primaryMain),
          padding: AppSpacing.paddingMD,
          shape: AppBorderRadius.stadiumBorder,
          textStyle: AppTextStyles.buttonSecondaryStyle,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          padding: AppSpacing.paddingSM,
          textStyle: AppTextStyles.captionMediumStyle,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBg,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.borderRadiusMD,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.borderRadiusMD,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.borderRadiusMD,
          borderSide: const BorderSide(color: AppColors.inputFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.borderRadiusMD,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: AppSpacing.paddingMD,
        hintStyle: AppTextStyles.bodySecondaryStyle,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryMain,
        foregroundColor: AppColors.textInverse,
        elevation: 4,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: AppColors.bgPrimary,
        selectedItemColor: AppColors.primaryMain,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1Style,
        displayMedium: AppTextStyles.h2Style,
        displaySmall: AppTextStyles.h3Style,
        bodyLarge: AppTextStyles.bodyStyle,
        bodyMedium: AppTextStyles.bodyMediumStyle,
        bodySmall: AppTextStyles.captionStyle,
        labelLarge: AppTextStyles.buttonStyle,
        labelMedium: AppTextStyles.captionMediumStyle,
        labelSmall: AppTextStyles.smallStyle,
      ),
    );
  }
}
