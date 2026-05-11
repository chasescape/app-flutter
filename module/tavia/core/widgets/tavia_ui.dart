import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tavia/gen_a/A.dart';

import '../../shared/constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TaviaBackground extends StatelessWidget {
  final Widget child;

  const TaviaBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.sunsetGradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned(
              top: -120,
              left: -110,
              child: _GlowOrb(
                size: 260,
                colors: [Color(0x55FFFFFF), Color(0x00FFFFFF)],
              ),
            ),
            const Positioned(
              right: -90,
              top: 160,
              child: _GlowOrb(
                size: 240,
                colors: [Color(0x3DFFDF72), Color(0x00FFDF72)],
              ),
            ),
            const Positioned(
              left: -90,
              bottom: -110,
              child: _CornerGlow(),
            ),
            const Positioned(
              right: -120,
              bottom: 140,
              child: _GlowOrb(
                size: 300,
                colors: [Color(0x26FFFFFF), Color(0x00FFFFFF)],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class TaviaPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;

  const TaviaPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.spacingLg),
    this.borderRadius = const BorderRadius.all(Radius.circular(30)),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.surfaceStrong.withValues(alpha: 0.74),
            borderRadius: borderRadius,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(AppColors.black, opacity: 0.12),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class TaviaIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? backgroundColor;

  const TaviaIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 20,
            color: color ?? AppColors.white,
          ),
        ),
      ),
    );
  }
}

class TaviaPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  const TaviaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.creamButtonGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(AppColors.black, opacity: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppConstants.spacingSm),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class TaviaCreateFab extends StatefulWidget {
  final VoidCallback? onTap;

  const TaviaCreateFab({
    super.key,
    this.onTap,
  });

  @override
  State<TaviaCreateFab> createState() => _TaviaCreateFabState();
}

class _TaviaCreateFabState extends State<TaviaCreateFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _float = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Transform.scale(
                scale: _pulse.value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.creamButtonGradient,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor(
                          AppColors.black,
                          opacity: 0.18,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                      BoxShadow(
                        color: AppColors.primaryMain.withValues(alpha: 0.18),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                      onTap: widget.onTap,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingMd),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMain,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 34,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TaviaTag extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const TaviaTag({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? AppColors.white.withValues(alpha: 0.95)
        : AppColors.white.withValues(alpha: 0.24);
    final foreground = selected ? AppColors.primaryMain : AppColors.white;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: 10,
          ),
          child: Text(
            label,
            style: AppTextStyles.captionMedium.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class TaviaSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const TaviaSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h1.copyWith(
            color: AppColors.white,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            subtitle!,
            style: AppTextStyles.body.copyWith(
              color: AppColors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ],
    );
  }
}

class TaviaMedia extends StatelessWidget {
  final String? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const TaviaMedia({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (source == null || source!.isEmpty) {
      child = _fallback();
    } else if (source!.startsWith('http')) {
      child = Image.network(
        source!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (source!.startsWith('assets/')) {
      final cacheWidth =
          (width != null && width!.isFinite) ? width!.round() * 3 : null;
      final cacheHeight =
          (height != null && height!.isFinite) ? height!.round() * 3 : null;
      final imageProvider = ResizeImage(
        AssetImage(source!),
        width: cacheWidth,
        height: cacheHeight,
      );
      child = Image(
        image: imageProvider,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      child = Image.file(
        File(source!),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
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
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: AppColors.candyGlowGradient,
          ),
          child: const Center(
            child: Icon(
              Icons.photo_library_outlined,
              size: 42,
              color: AppColors.white,
            ),
          ),
        );
  }
}

class TaviaLogoLockup extends StatelessWidget {
  final double size;
  final Color textColor;

  const TaviaLogoLockup({
    super.key,
    this.size = 108,
    this.textColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = ResizeImage(
      AssetImage(A.assets_tavia_TaviaLogo),
      width: (size * 3).round(),
      height: (size * 3).round(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(AppColors.black, opacity: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: EdgeInsets.all(size * 0.04),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.24),
            child: Image(
              image: imageProvider,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.white,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_outlined,
                  size: size * 0.34,
                  color: AppColors.primaryMain,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'Tavia',
          style: AppTextStyles.h1.copyWith(
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowOrb({
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

class _CornerGlow extends StatelessWidget {
  const _CornerGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 320,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(120),
          gradient: const LinearGradient(
            colors: [
              Color(0x4DFF8E68),
              Color(0x66FF4FA1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
