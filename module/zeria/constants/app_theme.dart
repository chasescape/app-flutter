import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

// App Theme - shared surface treatment for the redesign
class AppTheme {
  static ThemeData get lightTheme {
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentMain,
        onPrimary: AppColors.textInverse,
        secondary: AppColors.secondaryMain,
        onSecondary: AppColors.textInverse,
        tertiary: AppColors.brandOrange,
        onTertiary: AppColors.textPrimary,
        surface: AppColors.surfaceStrong,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textInverse,
      ),
      scaffoldBackgroundColor: AppColors.bgPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: AppTextStyles.h3,
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceStrong,
        elevation: 0,
        shape: roundedShape,
        shadowColor: AppColors.glassShadow,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceStrong,
        shape: roundedShape,
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.body,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryMain,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          padding: AppDimensions.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          minimumSize: const Size(double.infinity, 56),
          padding: AppDimensions.buttonPadding,
          side: const BorderSide(color: AppColors.glassBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          textStyle:
              AppTextStyles.button.copyWith(color: AppColors.primaryMain),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandHotPink,
          textStyle:
              AppTextStyles.bodyBold.copyWith(color: AppColors.brandHotPink),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassBackground,
        contentPadding: AppDimensions.inputPadding,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          borderSide:
              const BorderSide(color: AppColors.brandHotPink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassBackground,
        selectedColor: AppColors.brandHotPink,
        side: const BorderSide(color: AppColors.glassBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        labelStyle: AppTextStyles.small,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x22FFFFFF),
        thickness: 1,
        space: 1,
      ),
      fontFamily: AppTextStyles.fontFamily,
    );
  }

  static ThemeData get darkTheme => lightTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.primaryDark,
      );
}
