import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';
import 'app_border_radius.dart';

/// App Theme - Design System
/// Deep violet, launch-inspired theme with warm editorial surfaces.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryMain,
        secondary: AppColors.secondaryMain,
        tertiary: AppColors.accentMain,
        surface: AppColors.backgroundSecondary,
        error: AppColors.error,
        onPrimary: AppColors.primaryContrast,
        onSecondary: AppColors.textOnSurface,
        onTertiary: AppColors.textOnSurface,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textInverse,
      ),
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2Style,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfacePrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.cardRadius,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryMain,
          foregroundColor: AppColors.textOnSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.buttonStyle,
          padding: AppSpacing.mdHorizontal + AppSpacing.smVertical,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.buttonStyle,
          padding: AppSpacing.mdHorizontal + AppSpacing.smVertical,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.buttonStyle,
          padding: AppSpacing.mdHorizontal + AppSpacing.smVertical,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSecondary,
        contentPadding: AppSpacing.mdAll,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.mdRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.mdRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyStyle.copyWith(
          color: AppColors.textDisabled,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.sheetRadius,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.lgRadius,
        ),
        titleTextStyle: AppTextStyles.surfaceTitleStyle,
        contentTextStyle: AppTextStyles.surfaceBodyStyle,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfacePrimary,
        contentTextStyle: AppTextStyles.surfaceBodyStyle,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdRadius,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderPrimary,
        thickness: 0.8,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryLight,
        selectionColor: Color(0x559C44FF),
        selectionHandleColor: AppColors.primaryMain,
      ),
      extensions: const <ThemeExtension<dynamic>>[],
    );
  }
}
