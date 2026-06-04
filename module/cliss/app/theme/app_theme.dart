import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryMain = Color(0xFF2A252A);
  static const Color primaryLight = Color(0xFF4B434B);
  static const Color primaryDark = Color(0xFF171417);
  static const Color primaryContrastText = Color(0xFFFFFFFF);

  static const Color secondaryMain = Color(0xFFF2B8F4);
  static const Color secondaryLight = Color(0xFFF9D8FA);
  static const Color secondaryDark = Color(0xFFD88BE0);

  static const Color accentMain = Color(0xFFA7F3E8);
  static const Color accentLight = Color(0xFFD9FBF6);
  static const Color accentDark = Color(0xFF62CFC1);

  static const Color semanticSuccess = Color(0xFF52B788);
  static const Color semanticWarning = Color(0xFFF4A261);
  static const Color semanticError = Color(0xFFEA6D8A);
  static const Color semanticInfo = Color(0xFF7DA9F8);

  static const Color backgroundPrimary = Color(0xFFFFFBF7);
  static const Color backgroundSecondary = Color(0xFFFFFDFB);
  static const Color backgroundTertiary = Color(0xFFF6F0F4);
  static const Color backgroundOverlay = Color(0x662A252A);

  static const Color surfaceGlass = Color(0xD9FFFFFF);
  static const Color surfaceSoft = Color(0xFFFDF4FB);
  static const Color surfaceMint = Color(0xFFEFFCF8);
  static const Color borderSoft = Color(0xFFF2DCEB);
  static const Color divider = Color(0xFFEBDDE6);

  static const Color textPrimary = Color(0xFF261F25);
  static const Color textSecondary = Color(0xFF6F6370);
  static const Color textTertiary = Color(0xFF9E8FA1);
  static const Color textDisabled = Color(0xFFD2C7D1);
  static const Color textInverse = Color(0xFFFFFFFF);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient appBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFDF6),
      Color(0xFFFFF8FB),
    ],
  );

  static const LinearGradient heroWash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xB8CFFFF2),
      Color(0x80F7C9F6),
    ],
  );

  static const LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x05000000),
      Color(0x28000000),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF2B252B),
      Color(0xFF3C333B),
    ],
  );

  static const LinearGradient softCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF9FFFFFF),
      Color(0xF7FFF7FC),
    ],
  );

  static const RadialGradient mintGlow = RadialGradient(
    center: Alignment(-0.5, -0.8),
    radius: 1.2,
    colors: [
      Color(0x66B7FFF0),
      Color(0x00B7FFF0),
    ],
  );

  static const RadialGradient pinkGlow = RadialGradient(
    center: Alignment(0.75, 0.4),
    radius: 1.1,
    colors: [
      Color(0x7AF8B8EE),
      Color(0x00F8B8EE),
    ],
  );
}

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  static const TextStyle display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.08,
    fontFamily: fontFamily,
    letterSpacing: -0.7,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    fontFamily: fontFamily,
    letterSpacing: -0.45,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
    fontFamily: fontFamily,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    fontFamily: fontFamily,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyEmphasis = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    fontFamily: fontFamily,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    fontFamily: fontFamily,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    fontFamily: fontFamily,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFamily: fontFamily,
    letterSpacing: 0.15,
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  AppBorderRadius._();

  static const double small = 14.0;
  static const double medium = 20.0;
  static const double large = 28.0;
  static const double xlarge = 36.0;

  static const Radius radiusSmall = Radius.circular(small);
  static const Radius radiusMedium = Radius.circular(medium);
  static const Radius radiusLarge = Radius.circular(large);
  static const Radius radiusXlarge = Radius.circular(xlarge);

  static const BorderRadius allSmall = BorderRadius.all(radiusSmall);
  static const BorderRadius allMedium = BorderRadius.all(radiusMedium);
  static const BorderRadius allLarge = BorderRadius.all(radiusLarge);
  static const BorderRadius allXlarge = BorderRadius.all(radiusXlarge);
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x12000000),
      offset: Offset(0, 10),
      blurRadius: 24,
      spreadRadius: -12,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x16000000),
      offset: Offset(0, 18),
      blurRadius: 40,
      spreadRadius: -18,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1D000000),
      offset: Offset(0, 24),
      blurRadius: 56,
      spreadRadius: -20,
    ),
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryMain,
        secondary: AppColors.secondaryMain,
        surface: AppColors.backgroundSecondary,
        error: AppColors.semanticError,
        onPrimary: AppColors.primaryContrastText,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textInverse,
      ),
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.h3.copyWith(
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceGlass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allLarge,
          side: const BorderSide(color: AppColors.borderSoft),
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryMain,
          foregroundColor: AppColors.textInverse,
          disabledBackgroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.textInverse,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.allLarge,
          ),
          textStyle: AppTextStyles.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          textStyle: AppTextStyles.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          side: const BorderSide(color: AppColors.borderSoft),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.allLarge,
          ),
          textStyle: AppTextStyles.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceGlass,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMedium,
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMedium,
          borderSide: const BorderSide(color: AppColors.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.allMedium,
          borderSide: const BorderSide(color: AppColors.secondaryDark),
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryMain,
        unselectedItemColor: AppColors.textTertiary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryMain,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: AppColors.textInverse,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allMedium,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: AppColors.secondaryDark,
        inactiveTrackColor: AppColors.borderSoft,
        thumbColor: AppColors.primaryMain,
        overlayColor: AppColors.secondaryMain.withOpacity(0.18),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceGlass,
        selectedColor: AppColors.primaryMain,
        secondarySelectedColor: AppColors.primaryMain,
        labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.textInverse,
        ),
        side: const BorderSide(color: AppColors.borderSoft),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allMedium,
        ),
      ),
    );
  }
}
