import 'package:flutter/material.dart';
import 'package:tanie/tanie/theme/app_border_radius.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_shadows.dart';
import 'package:tanie/tanie/theme/app_spacing.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showNeonBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.showNeonBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        showNeonBorder ? AppColors.secondaryMain : AppColors.cardBorder;

    final card = Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.huge),
        border: Border.all(color: borderColor, width: showNeonBorder ? 1.5 : 1),
        boxShadow: showNeonBorder ? AppShadows.glow : AppShadows.card,
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppBorderRadius.huge),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class AppImageCard extends StatelessWidget {
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final double? height;

  const AppImageCard({
    super.key,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAdaptiveImage(
            imagePath: imageUrl,
            width: double.infinity,
            height: height ?? 180,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppBorderRadius.huge),
            ),
          ),
          if (title != null || subtitle != null)
            Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: trailing,
            ),
        ],
      ),
    );
  }
}

class AppStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          if (icon != null)
            Icon(
              icon,
              color: iconColor ?? AppColors.secondaryMain,
              size: 28,
            ),
          if (icon != null) const SizedBox(height: 10),
          Text(value, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
