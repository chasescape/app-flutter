import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tanie/tanie/theme/app_border_radius.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_shadows.dart';
import 'package:tanie/tanie/theme/app_spacing.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';

class AppBackdrop extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppBackdrop({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundAccent,
            AppColors.backgroundPrimary,
            AppColors.backgroundPrimary,
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -72,
            left: -20,
            child: _GlowBlob(
              size: 220,
              colors: [Color(0xFFF9C3E3), Color(0x00F9C3E3)],
            ),
          ),
          const Positioned(
            top: 80,
            right: -36,
            child: _GlowBlob(
              size: 180,
              colors: [Color(0xFFD8DAFF), Color(0x00D8DAFF)],
            ),
          ),
          const Positioned(
            bottom: 140,
            left: -44,
            child: _GlowBlob(
              size: 160,
              colors: [Color(0xFFFFE2BF), Color(0x00FFE2BF)],
            ),
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
}

class AppSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const AppSectionCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding ?? AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.cardBackground : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppBorderRadius.huge),
        border: Border.all(
          color: AppColors.cardBorder,
        ),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppBorderRadius.huge),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class AppStickerChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppStickerChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = backgroundColor ?? AppColors.stickerDark;
    final textColor = foregroundColor ?? AppColors.stickerText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(
          color: AppColors.white,
          width: 2,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class AppMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const AppMetaChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardMuted,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppAdaptiveImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  const AppAdaptiveImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }

  Widget _buildImage() {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _fallback(isLoading: true);
        },
      );
    }

    if (imagePath.startsWith('/')) {
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback({bool isLoading = false}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.cardMuted,
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.secondaryMain),
              ),
            )
          : const Icon(
              Icons.image_outlined,
              size: 34,
              color: AppColors.textTertiary,
            ),
    );
  }
}

class AppPhotoCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final String? badge;
  final String? secondaryBadge;
  final bool overlayTitle;
  final VoidCallback? onTap;

  const AppPhotoCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.badge,
    this.secondaryBadge,
    this.overlayTitle = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 0.82,
                child: AppAdaptiveImage(
                  imagePath: imagePath,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.photoOverlay,
                      ],
                    ),
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: AppStickerChip(label: badge!),
                ),
              if (secondaryBadge != null)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: AppStickerChip(
                    label: secondaryBadge!,
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              if (overlayTitle)
                Positioned(
                  left: 12,
                  right: secondaryBadge == null ? 12 : 86,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.full,
                      ),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (!overlayTitle)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AppIconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppIconCircle({
    super.key,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(AppBorderRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
            boxShadow: AppShadows.soft,
          ),
          child: Icon(
            icon,
            size: 20,
            color: foregroundColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const AppSectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.h1),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowBlob({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
