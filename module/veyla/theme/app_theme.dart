import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2B2E45);
  static const Color primaryLight = Color(0xFF4A4E74);
  static const Color primaryDark = Color(0xFF202338);

  static const Color secondary = Color(0xFFFFDDBA);
  static const Color secondaryLight = Color(0xFFFFF0E0);
  static const Color secondaryDark = Color(0xFFF2C89E);

  static const Color accent = Color(0xFF9F8CFF);
  static const Color accentLight = Color(0xFFE8E1FF);
  static const Color accentDark = Color(0xFF7C69E8);

  static const Color success = Color(0xFF42B883);
  static const Color warning = Color(0xFFFFB454);
  static const Color error = Color(0xFFE85D75);
  static const Color info = Color(0xFF7D95FF);

  static const Color backgroundPrimary = Color(0xFFFCF8F6);
  static const Color backgroundSecondary = Color(0xFFF7F0FF);
  static const Color backgroundTertiary = Color(0xFFFCEFD9);
  static const Color backgroundOverlay = Color(0x66FFFFFF);

  static const Color textPrimary = Color(0xFF2A2D40);
  static const Color textSecondary = Color(0xFF7E7B93);
  static const Color textDisabled = Color(0xFFC4C1D4);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9F5FF);
  static const Color stroke = Color(0xFFEAE4F4);
  static const Color shadow = Color(0x14A390D3);
}

class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF7F1),
      Color(0xFFFCF8F7),
      Color(0xFFF6F1FF),
    ],
  );

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF0EDFF),
      Color(0xFFFFF4E7),
      Color(0xFFFFE1D6),
    ],
  );

  static const LinearGradient candy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9F8CFF),
      Color(0xFFC2B6FF),
    ],
  );

  static const LinearGradient softCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF9F4FF),
    ],
  );
}

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
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
  static const double small = 10;
  static const double medium = 18;
  static const double large = 28;
  static const double xlarge = 36;
}

class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 8),
      blurRadius: 20,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: AppColors.shadow,
      offset: Offset(0, 14),
      blurRadius: 30,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x22A68CF0),
      offset: Offset(0, 18),
      blurRadius: 42,
    ),
  ];
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textInverse,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: AppTextStyles.body.copyWith(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.stroke),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        hintStyle: AppTextStyles.caption,
      ),
      dividerColor: AppColors.stroke,
      fontFamily: 'Inter',
    );
  }
}
