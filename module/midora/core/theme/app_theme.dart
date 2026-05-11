import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';
import 'app_border_radius.dart';

/// App Theme Configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryMain,
        secondary: AppColors.secondaryMain,
        tertiary: AppColors.accentMain,
        surface: AppColors.backgroundSecondary,
        error: AppColors.error,
        onPrimary: AppColors.primaryContrastText,
        onSecondary: AppColors.textInverse,
        onTertiary: AppColors.textInverse,
        onError: AppColors.textInverse,
        onSurface: AppColors.textPrimary,
      ),
      splashColor: Colors.white.withOpacity(0.08),
      highlightColor: Colors.white.withOpacity(0.04),

      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundPrimary,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.glassMedium,
        elevation: 0,
        shape: AppBorderRadius.shapeLg,
        margin: AppSpacing.paddingHorizontalMd,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          textStyle: AppTextStyles.button,
          padding: AppSymmMetrics.paddingHorizontalMd +
              AppSymmMetrics.paddingVerticalLg,
          shape: AppBorderRadius.shapeXl,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          textStyle: AppTextStyles.button,
          padding: AppSymmMetrics.paddingHorizontalMd +
              AppSymmMetrics.paddingVerticalLg,
          shape: AppBorderRadius.shapeXl,
          side:
              const BorderSide(color: AppColors.glassBorderStrong, width: 1.4),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          textStyle: AppTextStyles.button,
          padding: AppSymmMetrics.paddingHorizontalMd +
              AppSymmMetrics.paddingVerticalSm,
          shape: AppBorderRadius.shapeMd,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: AppSymmMetrics.paddingHorizontalMd +
            AppSymmMetrics.paddingVerticalSm,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.borderRadiusLg,
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.borderRadiusLg,
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.borderRadiusLg,
          borderSide:
              const BorderSide(color: AppColors.primaryLight, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.borderRadiusLg,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.borderRadiusLg,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDisabled),
        labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryMain,
        foregroundColor: AppColors.primaryContrastText,
        elevation: 4,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryMain,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: AppTextStyles.smallMedium,
        unselectedLabelStyle: AppTextStyles.small,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.backgroundSecondary,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),

      // Font Family
      fontFamily: AppTextStyles.fontFamily,
    );
  }
}

// Extension for EdgeInsets addition
extension AppSymmMetrics on EdgeInsets {
  static const EdgeInsets paddingVerticalSm =
      EdgeInsets.symmetric(vertical: AppSpacing.sm);
  static const EdgeInsets paddingVerticalLg =
      EdgeInsets.symmetric(vertical: AppSpacing.lg);
  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: AppSpacing.md);
}
