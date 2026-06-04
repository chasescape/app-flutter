import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../gen_a/A.dart';
import '../theme/app_theme.dart';

class GlidoPageBackground extends StatelessWidget {
  final Widget child;
  final bool topSafeArea;
  final bool bottomSafeArea;
  final EdgeInsetsGeometry padding;

  const GlidoPageBackground({
    super.key,
    required this.child,
    this.topSafeArea = false,
    this.bottomSafeArea = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: GlidoBackground()),
        Positioned.fill(
          child: SafeArea(
            top: topSafeArea,
            bottom: bottomSafeArea,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class GlidoBackground extends StatelessWidget {
  const GlidoBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.pageGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -56,
            left: -32,
            right: -32,
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x52FFF57F),
                    Color(0x30FFF1B8),
                    Color(0x00FFFDF7),
                  ],
                ),
              ),
            ),
          ),
          _GlowOrb(
            alignment: Alignment.topLeft,
            size: 260,
            color: AppTheme.primaryMain,
            opacity: 0.34,
            offset: Offset(-40, -10),
          ),
          _GlowOrb(
            alignment: Alignment.topCenter,
            size: 220,
            color: AppTheme.primaryLight,
            opacity: 0.26,
            offset: Offset(0, -58),
          ),
          _GlowOrb(
            alignment: Alignment.topRight,
            size: 240,
            color: AppTheme.accentMain,
            opacity: 0.28,
            offset: Offset(50, -20),
          ),
          _GlowOrb(
            alignment: Alignment.centerLeft,
            size: 320,
            color: AppTheme.primaryMain,
            opacity: 0.22,
            offset: Offset(-120, 30),
          ),
          _GlowOrb(
            alignment: Alignment.bottomRight,
            size: 300,
            color: AppTheme.secondaryMain,
            opacity: 0.3,
            offset: Offset(70, 90),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;
  final double opacity;
  final Offset offset;

  const _GlowOrb({
    required this.alignment,
    required this.size,
    required this.color,
    required this.opacity,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: opacity),
                blurRadius: size * 0.64,
                spreadRadius: size * 0.08,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlidoSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  const GlidoSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacingMd),
    this.borderRadius,
    this.gradient,
    this.color,
    this.border,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge);
    return ClipRRect(
      borderRadius: radius,
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.78),
            gradient: gradient,
            borderRadius: radius,
            border: border ??
                Border.all(
                  color: AppTheme.ink.withValues(alpha: 0.06),
                ),
            boxShadow: boxShadow ?? AppTheme.softShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlidoOutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final TextAlign textAlign;

  const GlidoOutlinedText(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight = FontWeight.w800,
    this.fillColor = Colors.white,
    this.strokeColor = AppTheme.ink,
    this.strokeWidth = 6,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.8,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: baseStyle.copyWith(color: fillColor),
        ),
      ],
    );
  }
}

class GlidoBrandLockup extends StatelessWidget {
  final double badgeSize;
  final bool showName;
  final String name;
  final String subtitle;

  const GlidoBrandLockup({
    super.key,
    this.badgeSize = 112,
    this.showName = true,
    this.name = 'Glido',
    this.subtitle = 'Photo stories with glow and focus',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(badgeSize * 0.28),
            boxShadow: AppTheme.glowShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(badgeSize * 0.28),
            child: Image.asset(
              A.assets_glido_logo,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (showName) ...[
          const SizedBox(height: AppTheme.spacingLg),
          GlidoOutlinedText(
            name,
            fontSize: badgeSize * 0.34,
            strokeWidth: badgeSize * 0.06,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ],
    );
  }
}

class GlidoPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Gradient? gradient;
  final Color? color;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;

  const GlidoPill({
    super.key,
    required this.label,
    this.icon,
    this.gradient,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTheme.spacingMd,
      vertical: AppTheme.spacingSm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? AppTheme.textPrimary;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? Colors.white.withValues(alpha: 0.82))
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(
          color: AppTheme.ink.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppTheme.spacingXs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class GlidoSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const GlidoSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class GlidoRecordImage extends StatelessWidget {
  final String? imagePath;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String placeholderLabel;
  final IconData placeholderIcon;
  final String? heroTag;
  final double? height;

  const GlidoRecordImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderLabel = 'No image yet',
    this.placeholderIcon = Icons.photo_outlined,
    this.heroTag,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge);
    final image = Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF6AF),
            Color(0xFFFFFCEF),
            Color(0xFFE8FF92),
          ],
        ),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: imagePath != null && imagePath!.isNotEmpty
            ? _buildResolvedImage()
            : _buildPlaceholder(context),
      ),
    );

    if (heroTag == null) {
      return image;
    }

    return Hero(tag: heroTag!, child: image);
  }

  Widget _buildResolvedImage() {
    final path = imagePath!;
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }

    return Image.file(
      File(path),
      fit: fit,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            placeholderIcon,
            size: 38,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            placeholderLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

String glidoRecordHeroTag(String id) => 'glido-record-$id';
