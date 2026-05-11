import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryMain = Color(0xFF24162D);
  static const Color primaryLight = Color(0xFF3D254C);
  static const Color primaryDark = Color(0xFF140B19);
  static const Color primaryContrastText = Color(0xFFFFFFFF);

  static const Color secondaryMain = Color(0xFFF3A7C9);
  static const Color secondaryLight = Color(0xFFFFD6E7);
  static const Color secondaryDark = Color(0xFFD878A5);

  static const Color accentMain = Color(0xFFD8C5FF);
  static const Color accentLight = Color(0xFFEFE5FF);
  static const Color accentDark = Color(0xFFB39AF2);

  static const Color semanticSuccess = Color(0xFF4D927B);
  static const Color semanticWarning = Color(0xFFD79C3A);
  static const Color semanticError = Color(0xFFD26473);
  static const Color semanticInfo = Color(0xFF6A91D8);

  static const Color backgroundPrimary = Color(0xFFFFFAF8);
  static const Color backgroundSecondary = Color(0xFFFFEFF5);
  static const Color backgroundTertiary = Color(0xFFF3EBFF);
  static const Color backgroundOverlay = Color(0xD9FFFFFF);

  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFDF4F7);
  static const Color surfaceTertiary = Color(0xFFF6F0FF);

  static const Color outlineSoft = Color(0xFFEBDDE5);
  static const Color outlineStrong = Color(0xFFD8C3D0);
  static const Color shadowMain = Color(0x1F6F4B60);

  static const Color textPrimary = Color(0xFF29182F);
  static const Color textSecondary = Color(0xFF786975);
  static const Color textDisabled = Color(0xFFB8ABB5);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color glowPink = Color(0xFFFFC9DA);
  static const Color glowPeach = Color(0xFFFFE0CB);
  static const Color glowLavender = Color(0xFFE5D5FF);
}

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.8,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.6,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.35,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppBorderRadius {
  static const double small = 12;
  static const double medium = 18;
  static const double large = 26;
  static const double xlarge = 34;
  static const double full = 999;
}

class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: AppColors.shadowMain,
      offset: Offset(0, 10),
      blurRadius: 24,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: AppColors.shadowMain,
      offset: Offset(0, 16),
      blurRadius: 36,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: AppColors.shadowMain,
      offset: Offset(0, 22),
      blurRadius: 48,
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryMain,
        secondary: AppColors.secondaryMain,
        surface: AppColors.surfacePrimary,
        error: AppColors.semanticError,
        onPrimary: AppColors.textInverse,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textInverse,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfacePrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryMain,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: AppTextStyles.body.copyWith(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          side: const BorderSide(color: AppColors.outlineStrong),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundOverlay,
        hintStyle: AppTextStyles.caption,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.outlineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.primaryMain),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.semanticError),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfacePrimary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryMain,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.small,
        unselectedLabelStyle: AppTextStyles.small,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineSoft,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 22,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineMedium: AppTextStyles.h2,
        titleLarge: AppTextStyles.h3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.caption,
        bodySmall: AppTextStyles.small,
      ),
    );
  }
}
