import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../gen_a/A.dart';
import '../core/theme/app_theme.dart';
import '../models/perfume_record.dart';

class GlaceScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;

  const GlaceScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.safeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Stack(
      children: [
        const Positioned.fill(child: GlaceBackdrop()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: content,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ],
    );
  }
}

class GlaceBackdrop extends StatelessWidget {
  const GlaceBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(gradient: AppTheme.mistGradient),
          ),
          const _BlurBubble(
            alignment: Alignment.topLeft,
            width: 280,
            height: 280,
            color: Color(0x55FF84CC),
            blur: 58,
            offset: Offset(-58, -34),
          ),
          const _BlurBubble(
            alignment: Alignment.topRight,
            width: 260,
            height: 260,
            color: Color(0x40FFFFFF),
            blur: 70,
            offset: Offset(44, 10),
          ),
          const _BlurBubble(
            alignment: Alignment.center,
            width: 210,
            height: 210,
            color: Color(0x35FFD6E8),
            blur: 52,
            offset: Offset(-20, 14),
          ),
          const _BlurBubble(
            alignment: Alignment.bottomLeft,
            width: 240,
            height: 240,
            color: Color(0x449EAEFF),
            blur: 62,
            offset: Offset(-80, 80),
          ),
          const _BlurBubble(
            alignment: Alignment.bottomRight,
            width: 250,
            height: 250,
            color: Color(0x32FF96CD),
            blur: 56,
            offset: Offset(80, 96),
          ),
          const _SoftHalo(
              alignment: Alignment.centerLeft, size: 164, dx: -72, dy: 24),
          const _SoftHalo(
              alignment: Alignment.bottomRight, size: 184, dx: 36, dy: -120),
          const _SoftHalo(
            alignment: Alignment.topCenter,
            size: 120,
            dx: 0,
            dy: 80,
          ),
          const _Sparkle(top: 96, right: 66, size: 18),
          const _Sparkle(top: 248, left: 52, size: 14),
          const _Sparkle(bottom: 168, right: 74, size: 16),
          const _Sparkle(bottom: 92, left: 44, size: 12),
        ],
      ),
    );
  }
}

class _BlurBubble extends StatelessWidget {
  final Alignment alignment;
  final double width;
  final double height;
  final Color color;
  final double blur;
  final Offset offset;

  const _BlurBubble({
    required this.alignment,
    required this.width,
    required this.height,
    required this.color,
    required this.blur,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftHalo extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final double dx;
  final double dy;

  const _SoftHalo({
    required this.alignment,
    required this.size,
    required this.dx,
    required this.dy,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;

  const _Sparkle({
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.94),
                blurRadius: size * 1.2,
                spreadRadius: size * 0.2,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: size,
            color: Colors.white.withValues(alpha: 0.98),
          ),
        ),
      ),
    );
  }
}

class GlaceGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GlaceGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    final body = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration:
              AppTheme.glassCardDecoration.copyWith(borderRadius: radius),
          child: child,
        ),
      ),
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: body,
      ),
    );
  }
}

class GlaceSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? color;
  final double? width;
  final double? height;

  const GlaceSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    final body = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: AppTheme.surfaceCardDecoration(
            borderRadius: radius,
            color: color ?? AppColors.surface,
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: body,
      ),
    );
  }
}

class GlaceLogoBadge extends StatelessWidget {
  final double size;

  const GlaceLogoBadge({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.96),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30B45BEA),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: Image.asset(A.assets_glace_logo, fit: BoxFit.cover),
      ),
    );
  }
}

class GlaceHeroImage extends StatelessWidget {
  final String? imagePath;
  final double height;
  final BorderRadius borderRadius;
  final Widget? overlay;
  final bool showGradientOverlay;
  final bool useAssetBlend;

  const GlaceHeroImage({
    super.key,
    this.imagePath,
    required this.height,
    required this.borderRadius,
    this.overlay,
    this.showGradientOverlay = true,
    this.useAssetBlend = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalImage = imagePath != null && imagePath!.isNotEmpty;
    final localFile = hasLocalImage ? File(imagePath!) : null;
    final canUseFile = localFile != null && localFile.existsSync();

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (canUseFile)
              Image.file(
                localFile,
                fit: BoxFit.cover,
              )
            else
              const _GlaceImageFallback(),
            if (canUseFile && useAssetBlend)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.02),
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            if (!canUseFile)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.white.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
            if (showGradientOverlay)
              DecoratedBox(
                decoration: BoxDecoration(gradient: AppTheme.imageFadeGradient),
              ),
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }
}

class _GlaceImageFallback extends StatelessWidget {
  const _GlaceImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.72),
            AppColors.surfaceWarm,
            AppColors.surfaceTint.withValues(alpha: 0.92),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -18,
            right: -10,
            child: _FallbackOrb(
              size: 110,
              color: AppColors.secondary.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -26,
            child: _FallbackOrb(
              size: 140,
              color: AppColors.tertiary.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            top: 28,
            left: 26,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.90),
                ),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _FallbackOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class GlaceSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color color;
  final double titleSize;

  const GlaceSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.color = Colors.white,
    this.titleSize = 28,
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
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  height: 1.03,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: color,
                  shadows: const [
                    Shadow(
                      color: Color(0x2A402459),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: color.withValues(alpha: 0.86),
                  ),
                ),
              ],
            ],
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

class GlaceTag extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool useDarkText;

  const GlaceTag({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.useDarkText = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = useDarkText ? AppColors.textPrimary : AppColors.primary;
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: selected
              ? Colors.white.withValues(alpha: 0.96)
              : Colors.white.withValues(alpha: 0.58),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.textPrimary : fg,
        ),
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}

class GlaceMetricCard extends StatelessWidget {
  final String eyebrow;
  final String value;
  final String caption;
  final bool light;

  const GlaceMetricCard({
    super.key,
    required this.eyebrow,
    required this.value,
    required this.caption,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlaceSurfaceCard(
      color: light ? Colors.white.withValues(alpha: 0.74) : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              height: 1.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class GlaceImageCard extends StatelessWidget {
  final PerfumeRecord record;
  final VoidCallback? onTap;
  final bool dense;
  final Object? heroTag;

  const GlaceImageCard({
    super.key,
    required this.record,
    this.onTap,
    this.dense = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GlaceGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: heroTag == null
                ? _buildImage()
                : Hero(tag: heroTag!, child: _buildImage()),
          ),
          if (!dense) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.perfumeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${record.createdAt.month}/${record.createdAt.day}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage() {
    return GlaceHeroImage(
      imagePath: record.photoPath,
      height: double.infinity,
      borderRadius: BorderRadius.circular(24),
      overlay: Positioned(
        left: 12,
        right: 12,
        bottom: 12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (record.scentFamily.trim().isNotEmpty &&
                record.scentFamily.trim().toLowerCase() != 'unsorted')
              _ImageBadge(label: record.scentFamily),
          ],
        ),
      ),
    );
  }
}

class GlaceChipPill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const GlaceChipPill({
    super.key,
    this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white.withValues(alpha: 0.90);
    final fg = foregroundColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.84),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  final String label;

  const _ImageBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
