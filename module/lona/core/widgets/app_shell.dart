import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_border_radius.dart';
import '../constants/app_colors.dart';
import '../constants/app_shadows.dart';
import '../constants/app_text_styles.dart';

class AppBackdrop extends StatelessWidget {
  final Widget child;

  const AppBackdrop({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.backdrop),
      child: Stack(
        children: [
          Positioned(
            top: -180,
            left: -60,
            right: -60,
            child: IgnorePointer(
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: 180,
                      spreadRadius: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            right: -28,
            child: IgnorePointer(
              child: CustomPaint(
                size: const Size(220, 220),
                painter: _BackdropArcPainter(),
              ),
            ),
          ),
          const Positioned(
            top: 90,
            right: 18,
            child: IgnorePointer(
              child: _BackdropPlayfulCluster(),
            ),
          ),
          Positioned(
            top: 140,
            left: -30,
            right: -30,
            bottom: 0,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SpecklePainter(),
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.darkVignette),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? borderColor;
  final Gradient? gradient;

  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.borderColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppBorderRadius.xxl);
    final body = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: margin,
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: gradient ?? AppGradients.surface,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? AppColors.outlineSoft,
            ),
            boxShadow: AppShadows.cardElevation,
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null && onLongPress == null) {
      return body;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: radius,
        child: body,
      ),
    );
  }
}

class AppRoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const AppRoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(AppBorderRadius.full),
      onTap: onTap,
      child: Icon(
        icon,
        size: 20,
        color: iconColor ?? AppColors.textPrimary,
      ),
    );
  }
}

class AppTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBack) ...[
          AppRoundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: Get.back,
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: AppTextStyles.eyebrow,
                ),
                const SizedBox(height: 6),
              ],
              Text(title, style: AppTextStyles.h2),
            ],
          ),
        ),
        if (actions != null) ...[
          const SizedBox(width: AppSpacing.sm),
          ...actions!,
        ],
      ],
    );
  }
}

class AppTag extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const AppTag({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final background = color ?? Colors.white.withValues(alpha: 0.72);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(
          color: AppColors.outlineSoft,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(
          color: textColor ?? AppColors.primaryMain,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AppMetricPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const AppMetricPill({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: BorderRadius.circular(AppBorderRadius.full),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: AppGradients.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.textOnDark),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.small),
              Text(
                value,
                style: AppTextStyles.metric.copyWith(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackdropArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final rect = Rect.fromLTWH(
      size.width * -0.05,
      size.height * -0.35,
      size.width * 1.05,
      size.height * 1.18,
    );

    canvas.drawArc(rect, -1.0, 1.16, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BackdropPlayfulCluster extends StatelessWidget {
  const _BackdropPlayfulCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 12,
            right: 8,
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x66FFF7EE),
                    Color(0x18FFFFFF),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.16),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 36,
            right: 74,
            child: Transform.rotate(
              angle: -0.34,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x5CFFFFFF),
                      Color(0x1AFFFFFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.26),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 108,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x9EFFE1BC),
                    Color(0x3CFFFFFF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x80FFD08F).withValues(alpha: 0.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 56,
            right: 28,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 180; i++) {
      final random = math.Random(i * 131);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.5 + random.nextDouble() * 1.2;
      final alpha = 0.08 + random.nextDouble() * 0.18;

      dotPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, dotPaint);

      if (i % 7 == 0) {
        linePaint
          ..color = Colors.white.withValues(alpha: alpha * 0.75)
          ..strokeWidth = 0.8;
        final dx = (random.nextDouble() * 6) - 3;
        final dy = (random.nextDouble() * 2) - 1;
        canvas.drawLine(
          Offset(x, y),
          Offset(x + dx, y + dy),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AppSectionTitle({
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
              Text(title, style: AppTextStyles.h3),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AppEmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const AppEmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              shape: BoxShape.circle,
              boxShadow: AppShadows.neon(AppColors.secondaryMain),
            ),
            child: Icon(icon, color: AppColors.textOnDark, size: 28),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
