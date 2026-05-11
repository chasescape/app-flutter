import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_border.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class DreamyBackground extends StatelessWidget {
  const DreamyBackground({
    super.key,
    required this.child,
    this.showFloor = true,
  });

  final Widget child;
  final bool showFloor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -60,
            left: -20,
            right: -20,
            child: _GlowOrb(
              height: 260,
              colors: [Color(0x44FF5FAE), Color(0x11FFFFFF)],
            ),
          ),
          const Positioned(
            top: 170,
            right: -30,
            child: _BlurCircle(
              color: AppColors.backgroundTertiary,
              size: 180,
            ),
          ),
          const Positioned(
            bottom: 180,
            left: -30,
            child: _BlurCircle(
              color: AppColors.softBlue,
              size: 160,
            ),
          ),
          const Positioned(
            bottom: 60,
            right: -30,
            child: _BlurCircle(
              color: AppColors.softPink,
              size: 200,
            ),
          ),
          if (showFloor)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 190,
              child: IgnorePointer(child: _DreamFloor()),
            ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class DreamyPageScaffold extends StatelessWidget {
  const DreamyPageScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.showFloor = true,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final bool showFloor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: DreamyBackground(
        showFloor: showFloor,
        child: child,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class DreamyTopBar extends StatelessWidget {
  const DreamyTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.dark = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color foreground = dark ? AppColors.textDark : AppColors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: DreamyIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack!,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h1.copyWith(
                    fontSize: 26,
                    color: foreground,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: foreground.withOpacity(0.62),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class DreamyCenteredHeader extends StatelessWidget {
  const DreamyCenteredHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.horizontalPadding = AppSpacing.md,
    this.titleSize = 24,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double horizontalPadding;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        AppSpacing.md,
        horizontalPadding,
        AppSpacing.md,
      ),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: DreamyIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack!,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(
                  fontSize: titleSize,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (trailing != null)
              Align(
                alignment: Alignment.centerRight,
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}

class DreamyGlassCard extends StatelessWidget {
  const DreamyGlassCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.allMD,
    this.margin,
    this.radius = AppBorder.radiusLarge,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xF7FFFFFF),
            Color(0xECFFF8FC),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.cardStroke),
        boxShadow: AppShadows.shadowMD,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class DreamyImageCard extends StatelessWidget {
  const DreamyImageCard({
    super.key,
    required this.child,
    this.height,
    this.radius = AppBorder.radiusXLarge,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double? height;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.cardStroke),
        boxShadow: AppShadows.shadowLG,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class DreamyPrimaryButton extends StatelessWidget {
  const DreamyPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 58,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget button = SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.darkButtonGradient,
          borderRadius: AppBorder.borderRadiusFull,
          boxShadow: [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppBorder.borderRadiusFull,
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.white, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTypography.button.copyWith(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!expanded) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}

class DreamySecondaryButton extends StatelessWidget {
  const DreamySecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDark,
        backgroundColor: AppColors.white.withOpacity(0.82),
        side: const BorderSide(color: AppColors.cardStroke),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorder.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

class DreamyChip extends StatelessWidget {
  const DreamyChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentMain
              : AppColors.white.withOpacity(0.72),
          borderRadius: AppBorder.borderRadiusFull,
          border: Border.all(
            color: selected ? AppColors.accentMain : AppColors.cardStroke,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? AppColors.white : AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class DreamySectionLabel extends StatelessWidget {
  const DreamySectionLabel({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h3.copyWith(
            fontSize: 22,
            color: AppColors.textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: AppTypography.caption.copyWith(
              color: AppColors.textGrey,
            ),
          ),
        ],
      ],
    );
  }
}

class DreamyIconButton extends StatelessWidget {
  const DreamyIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: AppColors.textDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class DreamyEmptyState extends StatelessWidget {
  const DreamyEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXL,
        child: DreamyGlassCard(
          radius: AppBorder.radiusXLarge,
          padding: AppSpacing.allXL,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(icon, size: 38, color: AppColors.accentMain),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTypography.h3.copyWith(color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: AppTypography.body.copyWith(color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DreamyStatPill extends StatelessWidget {
  const DreamyStatPill({
    super.key,
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.85),
        borderRadius: AppBorder.borderRadiusFull,
        border: Border.all(color: AppColors.cardStroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textGrey),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTypography.small.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DreamyImageFallback extends StatelessWidget {
  const DreamyImageFallback({
    super.key,
    this.label = 'Preview',
    this.icon = Icons.auto_awesome_rounded,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD9EC),
            Color(0xFFFFF7D0),
            Color(0xFFDFF4FF),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 34, color: AppColors.accentMain),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _DreamFloor extends StatelessWidget {
  const _DreamFloor();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DreamFloorPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DreamFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x33FFB8D8),
          Color(0x66F79DD0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, fill);

    final Paint linePaint = Paint()
      ..color = const Color(0x55FFFFFF)
      ..strokeWidth = 1.2;

    final double horizonY = 12;
    final double centerX = size.width / 2;
    for (int i = -6; i <= 6; i++) {
      final double baseX = centerX + (i * size.width / 7);
      canvas.drawLine(
        Offset(baseX, size.height),
        Offset(centerX + (i * 10), horizonY),
        linePaint,
      );
    }
    for (int i = 0; i < 8; i++) {
      final double t = i / 7;
      final double y = lerpDouble(horizonY + 6, size.height, t * t)!;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.height,
    required this.colors,
  });

  final double height;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.65),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
