import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFF7F4F8);
  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFFEDE7F1);
  static const Color primaryContrast = Color(0xFF161019);

  static const Color secondary = Color(0xFFFFC7B8);
  static const Color secondaryLight = Color(0xFFFFDED4);
  static const Color secondaryDark = Color(0xFFE7A796);

  static const Color accent = Color(0xFFAEDFF2);
  static const Color accentLight = Color(0xFFF6D9E1);
  static const Color accentDark = Color(0xFF8FA8D6);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static const Color backgroundPrimary = Color(0xFFF7F4F8);
  static const Color backgroundSecondary = Color(0xFFEFF9FF);
  static const Color backgroundTertiary = Color(0xFFFFEFF4);
  static const Color backgroundOverlay = Color(0xCCFFFFFF);

  static const Color textPrimary = Color(0xFF161019);
  static const Color textSecondary = Color(0xFF675F71);
  static const Color textDisabled = Color(0xFF9E96A6);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color cardBackground = Color(0xF8FFFFFF);
  static const Color divider = Color(0x1A161019);
  static const Color shadow = Color(0x14000000);
  static const Color buttonPrimary = Color(0xFF170A14);
}

class AppFontSizes {
  static const double h1 = 34.0;
  static const double h2 = 26.0;
  static const double h3 = 20.0;
  static const double body = 16.0;
  static const double caption = 14.0;
  static const double small = 12.0;
}

class AppFontWeights {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w700;
  static const FontWeight bold = FontWeight.w800;
}

class AppLineHeights {
  static const double tight = 1.15;
  static const double normal = 1.45;
  static const double relaxed = 1.75;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class AppBorderRadius {
  static const double sm = 10.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double full = 999.0;
}

class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x12091317),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14091317),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x16091317),
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x40FFC7B8),
      blurRadius: 28,
      spreadRadius: 0,
    ),
  ];
}

class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

class AppGradients {
  static const LinearGradient mist = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8F2F8),
      Color(0xFFE8F6FF),
      Color(0xFFFFF1F1),
      Color(0xFFDDFBFF),
    ],
    stops: [0.0, 0.34, 0.7, 1.0],
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.secondary,
        secondary: AppColors.accentDark,
        surface: AppColors.cardBackground,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textInverse,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textInverse,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppFontSizes.h3,
          fontWeight: AppFontWeights.semibold,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSizes.body,
            fontWeight: AppFontWeights.semibold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        hintStyle: const TextStyle(
          color: AppColors.textDisabled,
          fontSize: AppFontSizes.body,
        ),
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppBackground({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.mist,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -60,
            left: -40,
            child: _orb(const Color(0x99BCEEFF), 180),
          ),
          Positioned(
            top: 120,
            right: -50,
            child: _orb(const Color(0x88FFD8E4), 220),
          ),
          Positioned(
            bottom: -70,
            left: 24,
            child: _orb(const Color(0x77D5F7FF), 200),
          ),
          SafeArea(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const AppGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppBorderRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.md,
      ),
      child: child,
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;

  const AppSectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppFontSizes.small,
            fontWeight: AppFontWeights.semibold,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppFontSizes.h2,
            fontWeight: AppFontWeights.bold,
            height: AppLineHeights.tight,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSizes.caption,
              height: AppLineHeights.normal,
            ),
          ),
        ],
      ],
    );
  }
}

class AppCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AppCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppBorderRadius.full),
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          border: Border.all(color: AppColors.divider),
          boxShadow: AppShadows.sm,
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}
