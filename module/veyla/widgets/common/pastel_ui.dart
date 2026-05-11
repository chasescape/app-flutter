import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PastelScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const PastelScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundPrimary,
      floatingActionButton: floatingActionButton,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            const Positioned.fill(child: SizedBox()),
            const _GlowOrb(top: -80, left: -40, size: 220, color: Color(0x40F4DCC8)),
            const _GlowOrb(top: 120, right: -50, size: 220, color: Color(0x40E8DFFF)),
            const _GlowOrb(bottom: -70, left: 30, size: 240, color: Color(0x40FFE8DE)),
            SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(top: appBar == null ? 0 : kToolbarHeight - 40),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppBorderRadius.large,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.softCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.stroke),
        boxShadow: AppShadows.sm,
      ),
      child: child,
    );
  }
}

class HeroImageCard extends StatelessWidget {
  final double height;
  final BorderRadius? borderRadius;
  final Widget? overlay;
  final String? label;
  final IconData? icon;

  const HeroImageCard({
    super.key,
    required this.height,
    this.borderRadius,
    this.overlay,
    this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppBorderRadius.xlarge);
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: AppGradients.hero,
        border: Border.all(color: AppColors.stroke),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xEEFFFFFF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon ?? Icons.auto_awesome, size: 16, color: AppColors.accentDark),
                  if (label != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      label!,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Center(
            child: overlay ??
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppGradients.candy,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppShadows.sm,
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 54,
                    color: AppColors.textInverse,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;

  const SectionHeader({
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
          style: AppTextStyles.small.copyWith(
            color: AppColors.accentDark,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h1,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;
  final Color color;

  const _GlowOrb({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
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
            color: color,
          ),
        ),
      ),
    );
  }
}
