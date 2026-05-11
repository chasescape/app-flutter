import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/utils/app_assets.dart';

class BilraBackdrop extends StatelessWidget {
  const BilraBackdrop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundPrimary,
            Color(0xFFFFF6FA),
            Color(0xFFFFF8F5),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -80,
            left: -36,
            child: _GlowOrb(
              color: AppColors.glowPink,
              size: 220,
            ),
          ),
          const Positioned(
            top: 54,
            right: -48,
            child: _GlowOrb(
              color: AppColors.glowPeach,
              size: 190,
            ),
          ),
          const Positioned(
            bottom: -28,
            left: 24,
            child: _GlowOrb(
              color: AppColors.glowLavender,
              size: 240,
            ),
          ),
          const Positioned(
            bottom: 140,
            right: -24,
            child: _GlowOrb(
              color: AppColors.glowPink,
              size: 160,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class BilraGlassCard extends StatelessWidget {
  const BilraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppBorderRadius.large,
    this.color,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppColors.backgroundOverlay,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: AppColors.outlineSoft),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class BilraTopBar extends StatelessWidget {
  const BilraTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(subtitle!, style: AppTextStyles.small),
                  ),
                Text(title, style: AppTextStyles.h2),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class BilraPrimaryButton extends StatelessWidget {
  const BilraPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: onTap == null
          ? AppColors.primaryMain.withValues(alpha: 0.35)
          : AppColors.primaryMain,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                  ),
                )
              else if (icon != null) ...[
                Icon(icon, color: AppColors.textInverse, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class BilraIconChipButton extends StatelessWidget {
  const BilraIconChipButton({
    super.key,
    required this.icon,
    this.onTap,
    this.label,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final isIconOnly = label == null;
    final borderRadius = BorderRadius.circular(isIconOnly ? 999 : 20);

    return Material(
      color: AppColors.backgroundOverlay,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: SizedBox(
          width: isIconOnly ? 42 : null,
          height: 42,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isIconOnly ? 0 : AppSpacing.md,
              vertical: isIconOnly ? 0 : AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: AppColors.primaryMain),
                if (label != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    label!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryMain,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BilraPill extends StatelessWidget {
  const BilraPill({
    super.key,
    required this.label,
    this.color = AppColors.surfaceSecondary,
    this.foregroundColor = AppColors.primaryMain,
  });

  final String label;
  final Color color;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class BilraImageFrame extends StatelessWidget {
  const BilraImageFrame({
    super.key,
    required this.imagePath,
    this.fallbackIndex = 0,
    this.preferIndexedGalleryForBundledAssets = false,
    this.borderRadius = AppBorderRadius.large,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  });

  final String imagePath;
  final int fallbackIndex;
  final bool preferIndexedGalleryForBundledAssets;
  final double borderRadius;
  final BoxFit fit;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final resolved = AppAssets.resolveDisplayImage(
      imagePath,
      fallbackIndex: fallbackIndex,
      preferIndexedGalleryForBundledAssets:
          preferIndexedGalleryForBundledAssets,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: width,
        child: AppAssets.isFilePath(resolved)
            ? Image.file(
                File(resolved),
                fit: fit,
                errorBuilder: (_, __, ___) => const _ImageFallback(),
              )
            : Image.asset(
                resolved,
                fit: fit,
                errorBuilder: (_, __, ___) => const _ImageFallback(),
              ),
      ),
    );
  }
}

class BilraEmptyState extends StatelessWidget {
  const BilraEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.action,
    this.alignment = Alignment.center,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget? action;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: BilraGlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, size: 34, color: AppColors.primaryMain),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceSecondary,
            AppColors.surfaceTertiary,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 34,
        color: AppColors.textSecondary,
      ),
    );
  }
}
