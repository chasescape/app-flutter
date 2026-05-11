import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_border.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryMain,
        secondary: AppColors.secondaryMain,
        tertiary: AppColors.accentMain,
        surface: AppColors.backgroundSurface,
        error: AppColors.error,
        onPrimary: AppColors.primaryContrastText,
        onSecondary: AppColors.textInverse,
        onSurface: AppColors.textDark,
        onError: AppColors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundPrimary,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h2,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),

      // Card
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorder.borderRadiusLG,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentMain,
          foregroundColor: AppColors.white,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorder.borderRadiusFull,
          ),
          elevation: 0,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentMain,
          textStyle: AppTypography.button,
          padding: AppSpacing.horizontalMD + AppSpacing.verticalSM,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorder.borderRadiusFull,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentMain,
          textStyle: AppTypography.button,
          padding: AppSpacing.horizontalMD + AppSpacing.verticalSM,
          side: const BorderSide(color: AppColors.cardStroke, width: 1),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorder.borderRadiusFull,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white.withOpacity(0.9),
        contentPadding: AppSpacing.allMD,
        border: OutlineInputBorder(
          borderRadius: AppBorder.borderRadiusLG,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorder.borderRadiusLG,
          borderSide: const BorderSide(color: AppColors.cardStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorder.borderRadiusLG,
          borderSide:
              const BorderSide(color: AppColors.primaryMain, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorder.borderRadiusLG,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryMain,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.accentMain,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.textSecondary,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textDark,
        size: 24,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.caption,
        labelSmall: AppTypography.small,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryMain,
        secondary: AppColors.secondaryMain,
        tertiary: AppColors.accentMain,
        surface: Color(0xFF1A1A1A),
        error: AppColors.error,
        onPrimary: AppColors.primaryContrastText,
        onSecondary: AppColors.textInverse,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          fontFamily: AppTypography.fontFamily,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorder.borderRadiusLG,
        ),
      ),
    );
  }
}
