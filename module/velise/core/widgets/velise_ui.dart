import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_border_radius.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

class VeliseBackground extends StatelessWidget {
  const VeliseBackground({
    super.key,
    required this.child,
    this.showLaunchBackdrop = true,
  });

  final Widget child;
  final bool showLaunchBackdrop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.nightfallGradient,
            ),
          ),
        ),
        if (showLaunchBackdrop)
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Image.asset(
                  AppAssets.launchBackdrop,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _VeliseWavePainter(),
            ),
          ),
        ),
        Positioned(
          top: -90,
          left: -30,
          right: -30,
          child: IgnorePointer(
            child: Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Color(0x88FF9AE3),
                    Color(0x55A43EFF),
                    Color(0x00090312),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class VeliseScaffold extends StatelessWidget {
  const VeliseScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = true,
    this.showLaunchBackdrop = true,
    this.bottomNavigationBar,
  });

  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool showLaunchBackdrop;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: VeliseBackground(
        showLaunchBackdrop: showLaunchBackdrop,
        child: body,
      ),
    );
  }
}

class VeliseSurfaceCard extends StatelessWidget {
  const VeliseSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.light = false,
    this.borderRadius = AppBorderRadius.cardRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool light;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: light ? AppColors.panelGradient : AppColors.glassGradient,
      borderRadius: borderRadius,
      border: Border.all(
        color: light ? AppColors.secondaryDark.withOpacity(0.45) : AppColors.borderPrimary,
      ),
      boxShadow: light ? AppShadows.cardShadow : AppShadows.glowShadow,
    );

    final content = Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: content,
      ),
    );
  }
}

class VelisePill extends StatelessWidget {
  const VelisePill({
    super.key,
    required this.label,
    this.icon,
    this.light = false,
    this.compact = false,
    this.textColor,
  });

  final String label;
  final IconData? icon;
  final bool light;
  final bool compact;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final foreground = textColor ??
        (light ? AppColors.textOnSurfaceMuted : AppColors.textPrimary);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: light ? AppColors.secondaryLight.withOpacity(0.78) : AppColors.surfaceSecondary,
        borderRadius: AppBorderRadius.fullRadius,
        border: Border.all(
          color: light ? AppColors.secondaryDark.withOpacity(0.4) : AppColors.borderPrimary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: (compact ? AppTextStyles.smallStyle : AppTextStyles.captionStyle)
                .copyWith(
              color: foreground,
              fontWeight: AppTextStyles.semibold,
            ),
          ),
        ],
      ),
    );
  }
}

class VeliseActionButton extends StatelessWidget {
  const VeliseActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.light = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final iconColor = light ? AppColors.textOnSurface : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.fullRadius,
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: light ? AppColors.surfacePrimary.withOpacity(0.92) : AppColors.surfaceSecondary,
            borderRadius: AppBorderRadius.fullRadius,
            border: Border.all(
              color: light
                  ? AppColors.secondaryDark.withOpacity(0.45)
                  : AppColors.borderPrimary,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}

class VelisePrimaryButton extends StatelessWidget {
  const VelisePrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.background = AppColors.buttonGradient,
    this.foreground = AppColors.textOnSurface,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final Gradient background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: background,
          borderRadius: AppBorderRadius.fullRadius,
          boxShadow: AppShadows.buttonShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: AppBorderRadius.fullRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(foreground),
                      ),
                    )
                  else ...[
                    if (icon != null) ...[
                      Icon(icon, color: foreground, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.buttonStyle.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!expand) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}

class VeliseSectionHeading extends StatelessWidget {
  const VeliseSectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.light = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final titleColor = light ? AppColors.textOnSurface : AppColors.textPrimary;
    final subtitleColor =
        light ? AppColors.textOnSurfaceMuted : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h3Style.copyWith(
                  color: titleColor,
                  fontWeight: AppTextStyles.semibold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.captionStyle.copyWith(
                    color: subtitleColor,
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

class VeliseAdaptiveImage extends StatelessWidget {
  const VeliseAdaptiveImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.borderRadius = AppBorderRadius.cardRadius,
    this.width,
    this.height,
    this.placeholder,
  });

  final String imagePath;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final double? width;
  final double? height;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final fallback = placeholder ??
        Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: AppColors.lavenderGradient,
          ),
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        );

    Widget image;
    if (_isFilePath(imagePath)) {
      final file = File(imagePath.startsWith('file://') ? imagePath.substring(7) : imagePath);
      image = file.existsSync()
          ? Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => fallback,
            )
          : fallback;
    } else {
      image = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: image,
    );
  }

  bool _isFilePath(String path) {
    return path.startsWith('/') || path.startsWith('file://');
  }
}

class _VeliseWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topLine = Paint()
      ..color = AppColors.primaryLight.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.22),
        width: size.width * 1.22,
        height: size.width * 0.66,
      ),
      0.15,
      2.82,
      false,
      topLine,
    );

    _paintWave(
      canvas,
      size,
      color: const Color(0x332B054A),
      topOffset: size.height * 0.16,
      amplitude: 30,
      height: size.height * 0.15,
    );
    _paintWave(
      canvas,
      size,
      color: const Color(0x334E1386),
      topOffset: size.height * 0.38,
      amplitude: 44,
      height: size.height * 0.18,
    );
    _paintWave(
      canvas,
      size,
      color: const Color(0x338B27FF),
      topOffset: size.height * 0.64,
      amplitude: 38,
      height: size.height * 0.2,
    );
  }

  void _paintWave(
    Canvas canvas,
    Size size, {
    required Color color,
    required double topOffset,
    required double amplitude,
    required double height,
  }) {
    final path = Path()
      ..moveTo(0, topOffset)
      ..cubicTo(
        size.width * 0.16,
        topOffset - amplitude,
        size.width * 0.42,
        topOffset + amplitude,
        size.width * 0.7,
        topOffset + amplitude * 0.2,
      )
      ..cubicTo(
        size.width * 0.84,
        topOffset + amplitude * 0.5,
        size.width * 0.94,
        topOffset - amplitude * 0.6,
        size.width,
        topOffset - amplitude * 0.2,
      )
      ..lineTo(size.width, topOffset + height)
      ..cubicTo(
        size.width * 0.8,
        topOffset + height + amplitude * 0.8,
        size.width * 0.5,
        topOffset + height - amplitude * 0.4,
        0,
        topOffset + height + amplitude * 0.5,
      )
      ..close();

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
