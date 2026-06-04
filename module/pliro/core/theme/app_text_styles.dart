import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application typography system.
class AppTextStyles {
  AppTextStyles._();

  // ==================== Font Sizes ====================
  static const double fontSizeDisplay = 40.0;
  static const double fontSizeH1 = 32.0;
  static const double fontSizeH2 = 24.0;
  static const double fontSizeH3 = 20.0;
  static const double fontSizeH4 = 18.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeCaption = 14.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeTiny = 10.0;

  // ==================== Font Weights ====================
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // ==================== Line Heights ====================
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.8;

  // ==================== Letter Spacing ====================
  static const double letterSpacingTight = 0.0;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.0;

  static const TextStyle display = TextStyle(
    fontSize: fontSizeDisplay,
    fontWeight: weightBold,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: fontSizeH1,
    fontWeight: weightBold,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: fontSizeH2,
    fontWeight: weightSemiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: fontSizeH3,
    fontWeight: weightSemiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: fontSizeH4,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: weightRegular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySemiBold = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: weightSemiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: weightRegular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionMedium = TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle small = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: weightRegular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle smallMedium = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle tiny = TextStyle(
    fontSize: fontSizeTiny,
    fontWeight: weightRegular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: fontSizeBody,
    fontWeight: weightSemiBold,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
    color: AppColors.textInverse,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textInverse,
  );

  static TextStyle get neonHeading => h1.copyWith(
        color: AppColors.roseDeep,
        shadows: [
          Shadow(
            color: AppColors.rose.withOpacity(0.55),
            blurRadius: 10,
          ),
        ],
      );

  static const TextStyle brandSubtitle = TextStyle(
    fontSize: fontSizeCaption,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
    color: AppColors.textSecondary,
  );

  static const TextStyle value = TextStyle(
    fontSize: fontSizeH3,
    fontWeight: weightBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
    color: AppColors.textPrimary,
  );

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(
      color: style.color?.withOpacity(opacity) ??
          AppColors.textPrimary.withOpacity(opacity),
    );
  }

  static TextStyle withUnderline(TextStyle style, {Color? color}) {
    return style.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: color ?? style.color ?? AppColors.textPrimary,
    );
  }
}
