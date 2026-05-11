import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryMain = Color(0xFF221A24);
  static const Color primaryLight = Color(0xFF3A2A3E);
  static const Color primaryDark = Color(0xFF140F16);
  static const Color primaryContrastText = Color(0xFFFFFFFF);

  static const Color secondaryMain = Color(0xFFE46CC8);
  static const Color secondaryLight = Color(0xFFF4B0E6);
  static const Color secondaryDark = Color(0xFFC84EAB);

  static const Color accentMain = Color(0xFFF3C4FF);
  static const Color accentLight = Color(0xFFFFE0F4);
  static const Color accentDark = Color(0xFFD5A5F0);

  static const Color peach = Color(0xFFFFE5D8);
  static const Color butter = Color(0xFFFFF2D5);
  static const Color mint = Color(0xFFDDF3EC);

  static const Color success = Color(0xFF41A971);
  static const Color warning = Color(0xFFF2A44F);
  static const Color error = Color(0xFFD95B6A);
  static const Color info = Color(0xFF5BA6E6);

  static const Color bgPrimary = Color(0xFFFFFAF5);
  static const Color bgSecondary = Color(0xFFF9EDF8);
  static const Color bgTertiary = Color(0xFFEADAF4);
  static const Color bgOverlay = Color(0xE6FFF8FC);

  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFFF4FA);
  static const Color surfaceMuted = Color(0xFFF6ECF5);
  static const Color lineSoft = Color(0x33B275B1);

  static const Color textPrimary = Color(0xFF221A24);
  static const Color textSecondary = Color(0xFF6E6170);
  static const Color textDisabled = Color(0xFFAA9BAD);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0B7F2),
      Color(0xFFFFFBF6),
      Color(0xFFF3C3F3),
    ],
  );

  static const Gradient spotlightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7D1FA),
      Color(0xFFFFFBF4),
      Color(0xFFFFE7D6),
    ],
  );

  static const Gradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFF6FB),
    ],
  );

  static const Gradient candyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF29DDD),
      Color(0xFFDFA7FF),
    ],
  );

  static const Gradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF241B27),
      Color(0xFF18121A),
    ],
  );

  static const Gradient imageScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x14000000),
      Color(0xB3000000),
    ],
  );
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.12,
    letterSpacing: -0.6,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.18,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle small = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
    height: 1.2,
    letterSpacing: 0.1,
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
}

class AppBorderRadius {
  AppBorderRadius._();

  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 30;
  static const double xxl = 38;
  static const double full = 999;

  static const BorderRadius allSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius allMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius allLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius allXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius allXxl = BorderRadius.all(Radius.circular(xxl));
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x140B0410),
      offset: Offset(0, 10),
      blurRadius: 24,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1F40263F),
      offset: Offset(0, 16),
      blurRadius: 36,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x221C0E1B),
      offset: Offset(0, 22),
      blurRadius: 54,
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x29F093D8),
      offset: Offset(0, 18),
      blurRadius: 48,
    ),
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: const ColorScheme.light(
        primary: AppColors.secondaryMain,
        secondary: AppColors.accentDark,
        surface: AppColors.surfacePrimary,
        error: AppColors.error,
        onPrimary: AppColors.textInverse,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textInverse,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfacePrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lineSoft,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryMain,
          foregroundColor: AppColors.textInverse,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allMd),
          padding: AppSpacing.horizontalMd + AppSpacing.verticalSm,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          textStyle: AppTextStyles.body,
          padding: AppSpacing.horizontalMd + AppSpacing.verticalSm,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.lineSoft),
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allMd),
          padding: AppSpacing.horizontalMd + AppSpacing.verticalSm,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfacePrimary.withOpacity(0.82),
        hintStyle: AppTextStyles.caption,
        contentPadding: AppSpacing.allMd,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMd,
          borderSide: const BorderSide(color: AppColors.lineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMd,
          borderSide: const BorderSide(color: AppColors.lineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMd,
          borderSide:
              const BorderSide(color: AppColors.secondaryMain, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryMain.withOpacity(0.94),
        contentTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.textInverse),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allMd),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryMain,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveEaseIn = Curves.easeInCubic;
  static const Curve curveEaseInOut = Curves.easeInOutCubic;
}
