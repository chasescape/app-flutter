import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';
import 'border_radius.dart';
import 'shadows.dart';

// Export all theme classes for easy access
export 'colors.dart';
export 'typography.dart';
export 'spacing.dart';
export 'border_radius.dart';
export 'shadows.dart';

/// Main App Theme - Design System
/// Unifies all design tokens into ThemeData
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Nunito',

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: Color(AppColors.primaryMain),
        secondary: Color(AppColors.secondaryMain),
        tertiary: Color(AppColors.accentMain),
        surface: Color(AppColors.backgroundPrimary),
        error: Color(AppColors.error),
        onPrimary: Color(AppColors.textInverse),
        onSecondary: Color(AppColors.textPrimary),
        onSurface: Color(AppColors.textPrimary),
        onError: Color(AppColors.textInverse),
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(AppColors.backgroundPrimary),

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppColors.backgroundPrimary),
        foregroundColor: Color(AppColors.textPrimary),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppTypography.h3,
          fontWeight: AppTypography.semibold,
          color: Color(AppColors.textPrimary),
        ),
      ),

      // Card
      cardTheme: CardTheme(
        color: const Color(AppColors.cardBackground),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allLG,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.buttonPrimary),
          foregroundColor: const Color(AppColors.textInverse),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.allMD,
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: AppTypography.body,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(AppColors.primaryMain),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.allMD,
          ),
          textStyle: const TextStyle(
            fontSize: AppTypography.body,
            fontWeight: AppTypography.medium,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppColors.primaryMain),
          side: const BorderSide(
            color: Color(AppColors.primaryMain),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.allMD,
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: AppTypography.body,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(AppColors.cardElevated),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMD,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMD,
          borderSide: const BorderSide(
            color: Color(AppColors.divider),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMD,
          borderSide: const BorderSide(
            color: Color(AppColors.primaryMain),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMD,
          borderSide: const BorderSide(
            color: Color(AppColors.error),
            width: 1.5,
          ),
        ),
        hintStyle: const TextStyle(
          color: Color(AppColors.textSecondary),
          fontSize: AppTypography.body,
        ),
        labelStyle: const TextStyle(
          color: Color(AppColors.textSecondary),
          fontSize: AppTypography.caption,
        ),
        prefixIconColor: const Color(AppColors.textSecondary),
        suffixIconColor: const Color(AppColors.primaryMain),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(AppColors.buttonPrimary),
        foregroundColor: Color(AppColors.textInverse),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allLG,
        ),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: const Color(AppColors.cardBackground),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allLG,
        ),
        titleTextStyle: AppTypography.h3Style.copyWith(
          color: const Color(AppColors.textPrimary),
          fontWeight: AppTypography.bold,
        ),
        contentTextStyle: AppTypography.bodyStyle.copyWith(
          color: const Color(AppColors.textSecondary),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(AppColors.navBackground),
        selectedItemColor: Color(AppColors.navActive),
        unselectedItemColor: Color(AppColors.navInactive),
        selectedLabelStyle: TextStyle(
          fontSize: AppTypography.small,
          fontWeight: AppTypography.medium,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppTypography.small,
          fontWeight: AppTypography.regular,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(AppColors.divider),
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: Color(AppColors.textPrimary),
        size: 24,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTypography.h1Style,
        displayMedium: AppTypography.h2Style,
        displaySmall: AppTypography.h3Style,
        bodyLarge: AppTypography.bodyStyle,
        bodyMedium: AppTypography.captionStyle,
        bodySmall: AppTypography.smallStyle,
      ).apply(
        bodyColor: const Color(AppColors.textPrimary),
        displayColor: const Color(AppColors.textPrimary),
      ),
    );
  }

  static const Color primaryColor = Color(AppColors.primaryMain);
  static const Color secondaryColor = Color(AppColors.secondaryMain);
  static const Color accentColor = Color(AppColors.accentMain);
  static const Color backgroundColor = Color(AppColors.backgroundPrimary);
  static const Color cardColor = Color(AppColors.cardBackground);
  static const Color textPrimaryColor = Color(AppColors.textPrimary);
  static const Color textSecondaryColor = Color(AppColors.textSecondary);
}
