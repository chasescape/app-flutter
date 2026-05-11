import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_border_radius.dart';
import 'app_spacing.dart';
import 'app_shadows.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundPrimary,
        error: AppColors.error,
        onPrimary: AppColors.primaryContrastText,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textInverse,
      ),
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h3,
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allLarge,
        ),
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryContrastText,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge,
          padding: AppSpacing.symmetricMDH,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          padding: AppSpacing.symmetricMDH,
          side: const BorderSide(color: AppColors.goldLine, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundElevated,
        contentPadding: AppSpacing.paddingMD,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMedium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMedium,
          borderSide: const BorderSide(
            color: AppColors.backgroundTertiary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMedium,
          borderSide: const BorderSide(color: AppColors.goldLine, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMedium,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMedium,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDisabled,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryContrastText,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundPrimary,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelMedium,
        unselectedLabelStyle: AppTextStyles.labelMedium,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textDisabled,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicatorColor: AppColors.primary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundElevated,
        selectedColor: AppColors.accent,
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: const BorderSide(color: AppColors.backgroundTertiary),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textInverse,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allMedium,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.backgroundTertiary,
        thickness: 1,
      ),
    );
  }

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.heroGradient,
  );

  static const LinearGradient softHighlightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.softHighlightGradient,
  );

  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      color: AppColors.glassBackground,
      borderRadius: AppBorderRadius.allMedium,
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
      boxShadow: AppShadows.glass,
    );
  }

  static BoxDecoration cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.cardBackground,
      borderRadius: AppBorderRadius.allLarge,
      border: Border.all(
        color: AppColors.backgroundTertiary.withValues(alpha: 0.7),
      ),
      boxShadow: AppShadows.sm,
    );
  }

  static BoxDecoration framedCardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.cardBackground,
      borderRadius: AppBorderRadius.allLarge,
      border: Border.all(
        color: AppColors.accentDark.withValues(alpha: 0.34),
      ),
      boxShadow: AppShadows.sm,
    );
  }
}
