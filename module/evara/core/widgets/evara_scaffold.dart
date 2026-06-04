import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EvaraScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeTop;
  final bool safeBottom;

  const EvaraScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeTop = true,
    this.safeBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget body = child;
    if (safeTop || safeBottom) {
      body = SafeArea(
        top: safeTop,
        bottom: safeBottom,
        child: child,
      );
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: appBar != null,
      backgroundColor: Colors.transparent,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _EvaraBackground(),
          body,
        ],
      ),
    );
  }
}

class EvaraGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double blur;
  final Color? color;
  final List<BoxShadow>? boxShadow;

  const EvaraGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.blur = 18,
    this.color,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppTheme.radiusLg);

    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: color ?? AppTheme.bgCard,
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
            boxShadow: boxShadow ?? AppTheme.shadowMd,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return content;
  }
}

class EvaraSectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const EvaraSectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
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
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textAccent,
                  fontSize: AppTheme.small,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.h2,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.caption,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppTheme.spacingMd),
          trailing!,
        ],
      ],
    );
  }
}

class _EvaraBackground extends StatelessWidget {
  const _EvaraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF16021E),
                  Color(0xFF250520),
                  Color(0xFF120015),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, 0.78),
                  radius: 1.02,
                  colors: [
                    const Color(0x66FF8A4C).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -120,
            top: 140,
            child: _glow(
              size: 260,
              colors: const [
                Color(0x26FF78A8),
                Color(0x00FF78A8),
              ],
            ),
          ),
          Positioned(
            right: -90,
            top: 220,
            child: _glow(
              size: 220,
              colors: const [
                Color(0x1FFFFFFF),
                Color(0x00FFFFFF),
              ],
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.75, -1.0),
                  end: const Alignment(0.8, 0.15),
                  stops: const [0.0, 0.14, 1.0],
                  colors: [
                    Colors.white.withValues(alpha: 0.045),
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.15, 0.05),
                    radius: 1.1,
                    colors: [
                      Colors.white.withValues(alpha: 0.035),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -24,
            top: 0,
            bottom: 0,
            child: Container(
              width: 84,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.04),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -12,
            top: 36,
            bottom: 90,
            child: Container(
              width: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.03),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -180,
            child: _glow(
              size: 420,
              colors: const [
                Color(0x33FF8A55),
                Color(0x00FF8A55),
              ],
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                color: Colors.white.withValues(alpha: 0.015),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow({required double size, required List<Color> colors}) {
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

  Widget _spark({required double size}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.85),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLight.withValues(alpha: 0.9),
              blurRadius: size * 2,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
