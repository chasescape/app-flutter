import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class NeniaBackdrop extends StatelessWidget {
  final Widget child;

  const NeniaBackdrop({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        children: [
          const Positioned(
            top: -100,
            left: -70,
            child: _GlowOrb(size: 230, color: Color(0x66F7ACF7)),
          ),
          const Positioned(
            top: 56,
            right: -32,
            child: _DiamondCluster(
              width: 160,
              height: 120,
              tileSize: 16,
              color: Colors.white,
              opacity: 0.7,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class NeniaSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const NeniaSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 28,
    this.gradient,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.cardGradient,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: AppColors.lineSoft),
        boxShadow: boxShadow ?? AppShadows.sm,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class NeniaPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? label;
  final Widget? trailing;

  const NeniaPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(
                  label!.toUpperCase(),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.secondaryDark,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(title, style: AppTextStyles.h2),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 16),
          trailing!,
        ],
      ],
    );
  }
}

class NeniaInlineHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  const NeniaInlineHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeniaCircleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h2),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(height: 1.35),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class NeniaPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData trailingIcon;
  final bool expanded;

  const NeniaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon = Icons.arrow_forward_rounded,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppBorderRadius.allMd,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: AppBorderRadius.allMd,
            boxShadow: onPressed == null ? null : AppShadows.md,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.button,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryMain,
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(trailingIcon, size: 18, color: AppColors.textInverse),
              ),
            ],
          ),
        ),
      ),
    );

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child:
          expanded ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

class NeniaSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const NeniaSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: AppColors.lineSoft),
        backgroundColor: AppColors.surfacePrimary.withOpacity(0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class NeniaCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const NeniaCircleButton({
    super.key,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surfacePrimary.withOpacity(0.84),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.lineSoft),
            boxShadow: AppShadows.sm,
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class NeniaTagChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? background;

  const NeniaTagChip({
    super.key,
    required this.label,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? AppColors.surfacePrimary.withOpacity(0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lineSoft),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          color: color ?? AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class NeniaInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const NeniaInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.allMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.spotlightGradient,
                  borderRadius: AppBorderRadius.allMd,
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryMain),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.small),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class NeniaAdaptiveImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;

  const NeniaAdaptiveImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (path.startsWith('http')) {
      image = Image.network(
        path,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    } else if (path.startsWith('assets/')) {
      image = Image.asset(
        path,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    } else {
      image = Image.file(
        File(path),
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined,
            color: AppColors.textSecondary, size: 32),
      ),
    );
  }
}

class NeniaPhotoCard extends StatelessWidget {
  final Widget image;
  final String title;
  final String? subtitle;
  final String? label;
  final VoidCallback? onTap;
  final double? height;

  const NeniaPhotoCard({
    super.key,
    required this.image,
    required this.title,
    this.subtitle,
    this.label,
    this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.allLg,
        boxShadow: AppShadows.md,
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.allLg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            DecoratedBox(
                decoration:
                    const BoxDecoration(gradient: AppColors.imageScrim)),
            if (label != null)
              Positioned(
                top: 14,
                left: 14,
                child: NeniaTagChip(
                  label: label!,
                  background: AppColors.surfacePrimary.withOpacity(0.88),
                ),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style:
                        AppTextStyles.h3.copyWith(color: AppColors.textInverse),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textInverse.withOpacity(0.88)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.allLg,
        child: card,
      ),
    );
  }
}

class NeniaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const NeniaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.22),
      child: Padding(
        padding: AppSpacing.allLg,
        child: NeniaSurface(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  gradient: AppColors.spotlightGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: AppColors.primaryMain),
              ),
              const SizedBox(height: 18),
              Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message,
                  style: AppTextStyles.caption, textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                NeniaPrimaryButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.18),
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiamondCluster extends StatelessWidget {
  final double width;
  final double height;
  final double tileSize;
  final Color color;
  final double opacity;

  const _DiamondCluster({
    required this.width,
    required this.height,
    required this.tileSize,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final columns = (width / tileSize).floor();
    final rows = (height / tileSize).floor();

    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(columns * rows, (index) {
              final row = index ~/ columns;
              final column = index % columns;
              final distance =
                  ((row + column) / (columns + rows)).clamp(0, 1).toDouble();
              return Container(
                width: tileSize - 4,
                height: tileSize - 4,
                decoration: BoxDecoration(
                  color: color.withOpacity(opacity * (1 - distance * 0.6)),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
