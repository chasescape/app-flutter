import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF7A7A);
  static const Color primaryLight = Color(0xFFFFB18B);
  static const Color primaryDark = Color(0xFFF45F82);
  static const Color primaryContrast = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFF2D8FF);
  static const Color secondaryLight = Color(0xFFF8EEFF);
  static const Color secondaryDark = Color(0xFFD1A9F8);

  static const Color accent = Color(0xFFFF6895);
  static const Color accentLight = Color(0xFFFFA8C5);
  static const Color accentDark = Color(0xFFDE4A79);

  static const Color success = Color(0xFF3AA76D);
  static const Color warning = Color(0xFFF29A4A);
  static const Color error = Color(0xFFE45E6A);
  static const Color info = Color(0xFF7C7BF3);

  static const Color backgroundPrimary = Color(0xFFFFF5F1);
  static const Color backgroundSecondary = Color(0xFFFFFBFF);
  static const Color backgroundTertiary = Color(0xFFF8E9FF);
  static const Color backgroundOverlay = Color(0xCCFFFFFF);

  static const Color textPrimary = Color(0xFF171218);
  static const Color textSecondary = Color(0xFF756C78);
  static const Color textDisabled = Color(0xFFB0A7B3);
  static const Color textInverse = Color(0xFF171218);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFFF1F5);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color strokeSoft = Color(0xFFF2DEE7);
  static const Color ink = Color(0xFF111111);
}

class AppGradients {
  static const LinearGradient page = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF4F3),
      Color(0xFFFFF7EE),
      Color(0xFFF9F3FF),
    ],
  );

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD5E1),
      Color(0xFFFFEDDA),
      Color(0xFFF0DBFF),
    ],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.secondaryDark,
    ],
  );

  static const LinearGradient darkButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF131313),
      Color(0xFF26212B),
    ],
  );
}

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}

class AppBorderRadius {
  static const double small = 10.0;
  static const double medium = 18.0;
  static const double large = 26.0;
  static const double xlarge = 34.0;
  static const double full = 999.0;
}

class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x12000000),
      offset: Offset(0, 8),
      blurRadius: 18,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x16000000),
      offset: Offset(0, 14),
      blurRadius: 32,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1C000000),
      offset: Offset(0, 24),
      blurRadius: 48,
    ),
  ];
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h3,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.primaryContrast,
          disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 16,
          ),
          textStyle: AppTextStyles.body.copyWith(
            color: AppColors.primaryContrast,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          textStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.strokeSoft),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          backgroundColor: AppColors.surface.withValues(alpha: 0.66),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 16,
          ),
          textStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.88),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: const BorderSide(color: AppColors.strokeSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTextStyles.caption.copyWith(
          color: AppColors.textDisabled,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceElevated.withValues(alpha: 0.94),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          side: const BorderSide(color: AppColors.strokeSoft),
        ),
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.body,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: AppColors.primaryContrast,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
      ),
    );
  }
}
