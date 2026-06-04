import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Application theme configuration.
class AppTheme {
  AppTheme._();

  // ==================== Border Radius ====================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusPill = 999.0;

  // ==================== Spacing ====================
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ==================== Shadows ====================
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.roseDeep.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.70),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get dialogShadow => [
        BoxShadow(
          color: AppColors.ink.withOpacity(0.12),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get neonShadow => glowShadow;

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: AppColors.rose.withOpacity(0.30),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.mint.withOpacity(0.22),
          blurRadius: 32,
          offset: const Offset(0, 18),
        ),
      ];

  static List<BoxShadow> get innerShadow => [
        BoxShadow(
          color: AppColors.ink.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  // ==================== Legacy Color Accessors ====================
  @Deprecated('Use AppColors.primaryDark instead')
  static const Color primaryDark = AppColors.primaryDark;

  @Deprecated('Use AppColors.secondaryPink instead')
  static const Color secondaryPink = AppColors.secondaryPink;

  @Deprecated('Use AppColors.accentPink instead')
  static const Color accentPink = AppColors.accentPink;

  @Deprecated('Use AppColors.successGreen instead')
  static const Color successGreen = AppColors.successGreen;

  @Deprecated('Use AppColors.warningOrange instead')
  static const Color warningOrange = AppColors.warningOrange;

  @Deprecated('Use AppColors.errorRed instead')
  static const Color errorRed = AppColors.errorRed;

  @Deprecated('Use AppColors.infoBlue instead')
  static const Color infoBlue = AppColors.infoBlue;

  @Deprecated('Use AppColors.textPrimary instead')
  static const Color textPrimary = AppColors.textPrimary;

  @Deprecated('Use AppColors.textSecondary instead')
  static const Color textSecondary = AppColors.textSecondary;

  @Deprecated('Use AppColors.textDisabled instead')
  static const Color textDisabled = AppColors.textDisabled;

  // ==================== Legacy Font Size Accessors ====================
  @Deprecated('Use AppTextStyles.fontSizeH1 instead')
  static const double fontSizeH1 = AppTextStyles.fontSizeH1;

  @Deprecated('Use AppTextStyles.fontSizeH2 instead')
  static const double fontSizeH2 = AppTextStyles.fontSizeH2;

  @Deprecated('Use AppTextStyles.fontSizeH3 instead')
  static const double fontSizeH3 = AppTextStyles.fontSizeH3;

  @Deprecated('Use AppTextStyles.fontSizeBody instead')
  static const double fontSizeBody = AppTextStyles.fontSizeBody;

  @Deprecated('Use AppTextStyles.fontSizeCaption instead')
  static const double fontSizeCaption = AppTextStyles.fontSizeCaption;

  @Deprecated('Use AppTextStyles.fontSizeSmall instead')
  static const double fontSizeSmall = AppTextStyles.fontSizeSmall;

  static ThemeData get lightTheme => _buildTheme();

  /// Kept pastel as well because the app previously forced dark mode.
  static ThemeData get darkTheme => _buildTheme();

  static ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.roseDeep,
      brightness: Brightness.light,
      primary: AppColors.roseDeep,
      secondary: AppColors.mint,
      tertiary: AppColors.lilac,
      surface: AppColors.surface,
      error: AppColors.errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.roseDeep,
      scaffoldBackgroundColor: AppColors.dreamCream,
      colorScheme: colorScheme,
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.h3,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.roseDeep,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.roseDeep,
          side: BorderSide(color: AppColors.roseDeep.withOpacity(0.55)),
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLG,
            vertical: spacingMD,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.roseDeep,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.roseDeep,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMD,
            vertical: spacingSM,
          ),
          textStyle: AppTextStyles.bodyMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface.withOpacity(0.82),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMD,
          vertical: spacingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: AppColors.rose.withOpacity(0.26)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: BorderSide(color: AppColors.rose.withOpacity(0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: AppColors.roseDeep, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.textDisabled,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface.withOpacity(0.82),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: BorderSide(color: AppColors.rose.withOpacity(0.20)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.roseDeep,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXLarge),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.roseDeep,
        foregroundColor: AppColors.textInverse,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.inkMuted.withOpacity(0.18),
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.roseDeep,
        linearTrackColor: AppColors.blushMist,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.caption.copyWith(
          color: AppColors.textInverse,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }
}
