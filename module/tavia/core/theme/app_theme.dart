import 'package:flutter/material.dart';

import '../../shared/constants/app_constants.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// App theme centered around the splash screen's candy gradient palette.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryMain,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primaryMain,
      onPrimary: AppColors.white,
      secondary: AppColors.secondaryMain,
      onSecondary: AppColors.white,
      tertiary: AppColors.accentMain,
      onTertiary: AppColors.textPrimary,
      surface: AppColors.scaffoldBase,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceTint,
      outline: AppColors.outline,
      error: AppColors.semanticError,
      onError: AppColors.white,
      shadow: AppColors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.scaffoldBase,
      canvasColor: AppColors.scaffoldBase,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleLarge: AppTextStyles.h3,
        titleMedium: AppTextStyles.bodyMedium,
        titleSmall: AppTextStyles.captionMedium,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.buttonSmall,
        labelSmall: AppTextStyles.small,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: AppConstants.iconSizeMd,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppConstants.iconSizeMd,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceStrong.withValues(alpha: 0.74),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.primaryMain,
          backgroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.white.withValues(alpha: 0.4),
          minimumSize: const Size(0, AppConstants.buttonHeightLg),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingMd,
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primaryMain,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.outline),
          minimumSize: const Size(0, AppConstants.buttonHeightLg),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingMd,
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTextStyles.buttonSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceStrong.withValues(alpha: 0.6),
        disabledColor: AppColors.surfaceTint,
        selectedColor: AppColors.primaryMain,
        secondarySelectedColor: AppColors.primaryMain,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingXs,
        ),
        labelStyle: AppTextStyles.captionMedium,
        secondaryLabelStyle: AppTextStyles.captionMedium.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceStrong.withValues(alpha: 0.72),
        contentPadding: const EdgeInsets.all(AppConstants.spacingMd),
        hintStyle: AppTextStyles.caption,
        labelStyle: AppTextStyles.label,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: AppColors.primaryMain,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: AppColors.semanticError,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryMain,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
