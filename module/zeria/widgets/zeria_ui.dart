import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zeria/gen_a/A.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_dimensions.dart';
import 'package:zeria/zeria/constants/app_strings.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';

class ZeriaScreen extends StatelessWidget {
  const ZeriaScreen({
    super.key,
    required this.child,
    this.extendBody = false,
  });

  final Widget child;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: extendBody,
      body: ZeriaBackground(child: child),
    );
  }
}

class ZeriaBackground extends StatelessWidget {
  const ZeriaBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.purpleGradient,
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -120,
            left: -80,
            child: _GlowBlob(
              size: 280,
              color: Color(0x99FFFFFF),
            ),
          ),
          const Positioned(
            top: 40,
            right: -70,
            child: _GlowBlob(
              size: 260,
              color: Color(0x99FF72B3),
            ),
          ),
          const Positioned(
            bottom: -180,
            left: -70,
            child: _GlowBlob(
              size: 360,
              color: Color(0xAAFF2E8D),
            ),
          ),
          const Positioned(
            bottom: 120,
            right: -60,
            child: _GlowBlob(
              size: 220,
              color: Color(0x99FFD4E2),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.backgroundVeil,
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class ZeriaHeader extends StatelessWidget {
  const ZeriaHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.eyebrow.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.brandInk,
                ),
              ),
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}

class ZeriaIconButton extends StatelessWidget {
  const ZeriaIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: AppDimensions.shadowSmall,
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.brandInk,
          ),
        ),
      ),
    );
  }
}

class ZeriaSurfaceCard extends StatelessWidget {
  const ZeriaSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.lg),
    this.radius = 28,
    this.color = AppColors.glassBackground,
    this.borderColor = AppColors.glassBorder,
    this.boxShadow = AppDimensions.shadowMedium,
    this.gradient,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final List<BoxShadow> boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          margin: margin,
          decoration: BoxDecoration(
            color: gradient == null ? color : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
            boxShadow: boxShadow,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

class ZeriaButton extends StatelessWidget {
  const ZeriaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.isExpanded = true,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final bool isExpanded;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground =
        backgroundColor ?? (isSecondary ? AppColors.surfaceTint : Colors.white);
    final resolvedForeground = foregroundColor ??
        (isSecondary ? AppColors.brandHotPink : AppColors.brandHotPink);
    final resolvedBorder =
        borderColor ?? (isSecondary ? Colors.transparent : Colors.white);

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        child: Ink(
          height: 58,
          decoration: BoxDecoration(
            color: resolvedBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(
              color: resolvedBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.brandHotPink),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: resolvedForeground,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.button.copyWith(
                          color: resolvedForeground,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class ZeriaPill extends StatelessWidget {
  const ZeriaPill({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = const Color(0xCCFFFFFF),
    this.foregroundColor = AppColors.brandInk,
    this.maxWidth,
    this.fullWidth = false,
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double? maxWidth;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      label,
      style: AppTextStyles.small.copyWith(color: foregroundColor),
      softWrap: true,
      textAlign: TextAlign.center,
    );

    final constrainedText = maxWidth == null
        ? textWidget
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: textWidget,
          );

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 14, color: foregroundColor),
          constrainedText,
        ],
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: pill);
    }

    if (maxWidth == null) return pill;
    return IntrinsicWidth(child: pill);
  }
}

class ZeriaSectionTitle extends StatelessWidget {
  const ZeriaSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.h3Inverse.copyWith(
        color: AppColors.textInverse,
      ),
    );
  }
}

class ZeriaDialogActions extends StatelessWidget {
  const ZeriaDialogActions({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    this.confirmBackgroundColor,
    this.confirmForegroundColor,
    this.cancelBackgroundColor,
    this.cancelForegroundColor,
  });

  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final String confirmLabel;
  final Color? confirmBackgroundColor;
  final Color? confirmForegroundColor;
  final Color? cancelBackgroundColor;
  final Color? cancelForegroundColor;

  @override
  Widget build(BuildContext context) {
    final resolvedCancelBackground =
        cancelBackgroundColor ?? AppColors.surfaceTint;
    final resolvedCancelForeground =
        cancelForegroundColor ?? AppColors.brandHotPink;

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  backgroundColor: resolvedCancelBackground,
                  foregroundColor: resolvedCancelForeground,
                  side: const BorderSide(color: AppColors.glassBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  textStyle: AppTextStyles.buttonSmall.copyWith(
                    color: resolvedCancelForeground,
                  ),
                ),
                child: Text(cancelLabel),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  backgroundColor:
                      confirmBackgroundColor ?? AppColors.primaryMain,
                  foregroundColor:
                      confirmForegroundColor ?? AppColors.textInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  textStyle: AppTextStyles.buttonSmall,
                ),
                child: Text(confirmLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ZeriaBrandMark extends StatelessWidget {
  const ZeriaBrandMark({
    super.key,
    this.size = 68,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          A.assets_zeria_logo,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.brandInk,
                borderRadius: BorderRadius.circular(size * 0.28),
              ),
              child: Icon(
                Icons.image_not_supported_rounded,
                color: Colors.white.withValues(alpha: 0.88),
                size: size * 0.42,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ZeriaBrandLockup extends StatelessWidget {
  const ZeriaBrandLockup({
    super.key,
    this.size = 72,
    this.showCaption = true,
  });

  final double size;
  final bool showCaption;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ZeriaBrandMark(size: size),
        const SizedBox(height: 14),
        Text(
          AppStrings.appName,
          style: AppTextStyles.brand.copyWith(
            color: AppColors.brandInk,
          ),
        ),
        if (showCaption) ...[
          const SizedBox(height: 8),
          Text(
            'Soft visuals, image-first inspiration.',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class ZeriaAdaptiveImage extends StatelessWidget {
  const ZeriaAdaptiveImage({
    super.key,
    this.path,
    this.assetPath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.placeholderIcon = Icons.image_rounded,
  });

  final String? path;
  final String? assetPath;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final source = (path != null && path!.trim().isNotEmpty)
        ? path!.trim()
        : (assetPath ?? '').trim();

    Widget child;
    if (source.startsWith('http://') || source.startsWith('https://')) {
      child = Image.network(
        source,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (source.startsWith('assets/')) {
      child = Image.asset(
        source,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (source.isNotEmpty) {
      child = Image.file(
        File(source),
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      child = _fallback();
    }

    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }

  Widget _fallback() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppColors.accentGradient,
      ),
      child: Center(
        child: Icon(
          placeholderIcon,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ZeriaEmptyState extends StatelessWidget {
  const ZeriaEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.action,
  });

  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ZeriaSurfaceCard(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ZeriaBrandMark(size: 76),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
