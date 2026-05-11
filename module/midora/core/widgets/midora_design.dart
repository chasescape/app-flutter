import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../gen_a/A.dart';
import '../theme/app_border_radius.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class MidoraGlassCard extends StatelessWidget {
  const MidoraGlassCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.paddingMd,
    this.margin,
    this.borderRadius = AppBorderRadius.borderRadiusXl,
    this.blur = 18,
    this.gradient,
    this.borderColor,
    this.shadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final double blur;
  final Gradient? gradient;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0x4AFFFFFF),
                      Color(0x227F5CA8),
                    ],
                  ),
              border: Border.all(
                color: borderColor ?? AppColors.glassBorderStrong,
              ),
              boxShadow: shadow ?? AppColors.shadowMd,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class MidoraCircleButton extends StatelessWidget {
  const MidoraCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return MidoraGlassCard(
      padding: EdgeInsets.zero,
      blur: 12,
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.textInverse),
        ),
      ),
    );
  }
}

class MidoraPrimaryButton extends StatelessWidget {
  const MidoraPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.borderRadiusFull,
        gradient: enabled ? AppColors.buttonGradient : AppColors.mutedGradient,
        boxShadow: AppColors.glowMd,
      ),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 18,
          ),
          shape: AppBorderRadius.shapeXl,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primaryDark,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class MidoraSecondaryButton extends StatelessWidget {
  const MidoraSecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return MidoraGlassCard(
      padding: EdgeInsets.zero,
      blur: 14,
      borderRadius: AppBorderRadius.borderRadiusFull,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textInverse,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 16,
          ),
          shape: AppBorderRadius.shapeXl,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(label, style: AppTextStyles.buttonSmall),
          ],
        ),
      ),
    );
  }
}

class MidoraPill extends StatelessWidget {
  const MidoraPill({
    super.key,
    required this.label,
    this.icon,
    this.foregroundColor = AppColors.textInverse,
    this.backgroundColor = AppColors.glassMedium,
    this.borderColor = AppColors.glassBorderStrong,
  });

  final String label;
  final IconData? icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorderRadius.borderRadiusFull,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foregroundColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.smallMedium.copyWith(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}

class MidoraSectionTitle extends StatelessWidget {
  const MidoraSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

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
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class MidoraMascotBadge extends StatelessWidget {
  const MidoraMascotBadge({
    super.key,
    this.size = 54,
    this.showGlow = true,
  });

  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final earHeight = size * 0.24;
    final innerSize = size * 0.72;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: size * 0.18,
            top: 0,
            child: _MidoraEar(
              size: Size(size * 0.18, earHeight),
              color: AppColors.secondaryMain.withOpacity(0.9),
            ),
          ),
          Positioned(
            right: size * 0.18,
            top: 0,
            child: Transform.flip(
              flipX: true,
              child: _MidoraEar(
                size: Size(size * 0.18, earHeight),
                color: AppColors.secondaryMain.withOpacity(0.9),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(innerSize * 0.34),
                gradient: AppColors.primaryGradient,
                boxShadow: showGlow ? AppColors.glowMd : null,
              ),
              padding: EdgeInsets.all(size * 0.08),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(innerSize * 0.28),
                child: Image.asset(
                  A.assets_midora_MidoraLogo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: size * 0.2,
            child: Icon(
              Icons.auto_awesome,
              size: size * 0.18,
              color: AppColors.secondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class MidoraTopBar extends StatelessWidget {
  const MidoraTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        ...trailing,
      ],
    );
  }
}

class MidoraInfoRow extends StatelessWidget {
  const MidoraInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: AppTextStyles.smallMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MidoraEar extends StatelessWidget {
  const _MidoraEar({
    required this.size,
    required this.color,
  });

  final Size size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _MidoraEarPainter(color),
    );
  }
}

class _MidoraEarPainter extends CustomPainter {
  _MidoraEarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height)
      ..quadraticBezierTo(
          size.width * 0.52, size.height * 0.1, size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MidoraEarPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
