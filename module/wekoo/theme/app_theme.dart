import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Primary - brighter sakura pink with more saturation
  static const Color primaryMain = Color(0xFFF08FA8);
  static const Color primaryLight = Color(0xFFF7C3D0);
  static const Color primaryDark = Color(0xFFD96A89);
  static const Color primaryContrastText = Color(0xFFFFFFFF);

  // Secondary - airy sakura cream
  static const Color secondaryMain = Color(0xFFFCE3EA);
  static const Color secondaryLight = Color(0xFFFFEFF4);
  static const Color secondaryDark = Color(0xFFF5C4D1);

  // Accent - deeper rose mauve for stronger contrast
  static const Color accentMain = Color(0xFF7E485A);
  static const Color accentLight = Color(0xFFA86479);
  static const Color accentDark = Color(0xFF613545);

  static const Color semanticSuccess = Color(0xFF79A96B);
  static const Color semanticWarning = Color(0xFFF0B24B);
  static const Color semanticError = Color(0xFFE66C6C);
  static const Color semanticInfo = Color(0xFFF3A1B4);

  // Creamy pink surfaces
  static const Color bgPrimary = Color(0xFFFFFCFC);
  static const Color bgSecondary = Color(0xFFFDF0F4);
  static const Color bgTertiary = Color(0xFFF7DCE5);
  static const Color bgOverlay = Color(0x80000000);

  // Text with stronger warm contrast
  static const Color textPrimary = Color(0xFF3E2831);
  static const Color textSecondary = Color(0xFF86626E);
  static const Color textDisabled = Color(0xFFD3AEB9);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color creamBackground = Color(0xFFFFFAFB);
  static const Color parchmentSurface = Color(0xFFFFFFFF);
  static const Color glassHighlight = Color(0xCCFFFFFF);
  static const Color waveBlue = Color(0xFFF3AFC0);
  static const Color waveMint = Color(0xFFF9D7E0);
  static const Color deepOcean = Color(0xFF7E485A);

  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusXLarge = 32;

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  static const List<BoxShadow> shadows = [
    BoxShadow(color: Color(0x0A3E2831), offset: Offset(0, 2), blurRadius: 6),
    BoxShadow(color: Color(0x103E2831), offset: Offset(0, 8), blurRadius: 18),
  ];

  static const List<BoxShadow> shadowsElevated = [
    BoxShadow(color: Color(0x103E2831), offset: Offset(0, 6), blurRadius: 16),
    BoxShadow(color: Color(0x143E2831), offset: Offset(0, 12), blurRadius: 28),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryMain,
        secondary: secondaryMain,
        tertiary: accentMain,
        surface: parchmentSurface,
        error: semanticError,
        onPrimary: primaryContrastText,
        onSecondary: textPrimary,
        onTertiary: textPrimary,
        onSurface: textPrimary,
        onError: textInverse,
      ),
      scaffoldBackgroundColor: creamBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        color: parchmentSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMain,
          foregroundColor: primaryContrastText,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryMain,
          padding: EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryMain,
          side: BorderSide(color: primaryMain),
          padding: EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFFFF2F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: primaryMain, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: semanticError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: semanticError, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        hintStyle: TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: parchmentSurface,
        selectedItemColor: primaryMain,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryMain,
        foregroundColor: primaryContrastText,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: bgTertiary,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textDisabled,
        ),
      ),
    );
  }

  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: bgPrimary,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: shadows,
    );
  }

  static BoxDecoration get elevatedCardDecoration {
    return BoxDecoration(
      color: bgPrimary,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: shadowsElevated,
    );
  }

  static BoxDecoration get primaryCardDecoration {
    return BoxDecoration(
      color: primaryMain,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: shadowsElevated,
    );
  }

  static BoxDecoration get secondaryCardDecoration {
    return BoxDecoration(
      color: parchmentSurface,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: shadows,
    );
  }

  static LinearGradient get appBackgroundGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFFAFB),
        Color(0xFFFFF1F5),
        Color(0xFFFFFCFD),
      ],
    );
  }

  static LinearGradient get aquaPrimaryGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF7C2D0),
        Color(0xFFF08FA8),
        Color(0xFFD96A89),
      ],
    );
  }

  static LinearGradient get cardGlowGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFFFF7FA),
      ],
    );
  }
}
