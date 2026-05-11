import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

class PinkDecorBackground extends StatelessWidget {
  final Widget child;

  const PinkDecorBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppTheme.blushGradient,
            ),
          ),
        ),
        const Positioned(
          top: -40,
          left: -30,
          child: _GlowOrb(
            size: 190,
            color: Color(0x66FFD3E7),
          ),
        ),
        const Positioned(
          top: 120,
          right: -20,
          child: _GlowOrb(
            size: 170,
            color: Color(0x52FFB4D5),
          ),
        ),
        const Positioned(
          bottom: 90,
          left: -10,
          child: _GlowOrb(
            size: 160,
            color: Color(0x4DFFE7B9),
          ),
        ),
        const Positioned(
          bottom: -20,
          right: -30,
          child: _GlowOrb(
            size: 180,
            color: Color(0x59FFD4E8),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _BokehPainter(),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class PinkPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final EdgeInsetsGeometry padding;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool safeBottom;

  const PinkPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.padding = const EdgeInsets.fromLTRB(
      AppTheme.spacingMd,
      0,
      AppTheme.spacingMd,
      AppTheme.spacingMd,
    ),
    this.bottomBar,
    this.floatingActionButton,
    this.safeBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: PinkDecorBackground(
        child: SafeArea(
          bottom: safeBottom && bottomBar == null,
          child: Column(
            children: [
              PinkTopBar(
                title: title,
                subtitle: subtitle,
                leading: leading,
                actions: actions,
                centerTitle: centerTitle,
              ),
              Expanded(
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PinkTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  const PinkTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            subtitle!,
            textAlign: centerTitle ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );

    if (centerTitle) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingMd,
          AppTheme.spacingSm,
          AppTheme.spacingMd,
          AppTheme.spacingMd,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 42,
              child: Center(child: titleBlock),
            ),
            SizedBox(
              height: 42,
              child: Row(
                children: [
                  if (leading != null) leading!,
                  const Spacer(),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingSm,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppTheme.spacingSm),
          ],
          Expanded(child: titleBlock),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class PinkBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const PinkBackButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.76),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            AppTheme.shadow(AppTheme.primaryMain, 0.1),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppTheme.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}

class PinkGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;

  const PinkGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacingMd),
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ??
                AppTheme.surfaceColor.withValues(alpha: 0.72),
            borderRadius: radius,
            border: Border.all(
              color: AppTheme.surfaceColor.withValues(alpha: 0.55),
              width: 1,
            ),
            boxShadow: [
              AppTheme.shadow(AppTheme.primaryMain, 0.14),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class PinkSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const PinkSectionTitle({
    super.key,
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
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
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

class PinkPill extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool fullWidth;
  final int maxLines;

  const PinkPill({
    super.key,
    required this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.fullWidth = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppTheme.surfaceColor.withValues(alpha: 0.84);
    final fg = foregroundColor ?? AppTheme.textPrimary;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm + 2,
        vertical: AppTheme.spacingXs + 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: fg.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppTheme.spacingXs),
          ],
          if (fullWidth)
            Expanded(
              child: Text(
                text,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Text(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class PinkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool expanded;

  const PinkPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: AppTheme.primaryMain,
        foregroundColor: AppTheme.textInverse,
        shadowColor: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppTheme.spacingSm),
          ],
          Text(label),
        ],
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class PinkOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;

  const PinkOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppTheme.spacingSm),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class PinkImageFallback extends StatelessWidget {
  final String label;
  final IconData icon;

  const PinkImageFallback({
    super.key,
    this.label = 'Image',
    this.icon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 40, color: AppTheme.textInverse.withValues(alpha: 0.92)),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textInverse,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
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
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _BokehPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final circles = <({Offset offset, double radius, Color color})>[
      (
        offset: Offset(size.width * 0.18, size.height * 0.12),
        radius: 18,
        color: const Color(0x50FFFFFF)
      ),
      (
        offset: Offset(size.width * 0.34, size.height * 0.08),
        radius: 14,
        color: const Color(0x45FFE5F2)
      ),
      (
        offset: Offset(size.width * 0.72, size.height * 0.16),
        radius: 24,
        color: const Color(0x52FFFFFF)
      ),
      (
        offset: Offset(size.width * 0.82, size.height * 0.30),
        radius: 16,
        color: const Color(0x4AFFE6B4)
      ),
      (
        offset: Offset(size.width * 0.22, size.height * 0.36),
        radius: 22,
        color: const Color(0x43FFFFFF)
      ),
      (
        offset: Offset(size.width * 0.64, size.height * 0.48),
        radius: 18,
        color: const Color(0x47FFFFFF)
      ),
      (
        offset: Offset(size.width * 0.16, size.height * 0.64),
        radius: 26,
        color: const Color(0x36FFD4E8)
      ),
      (
        offset: Offset(size.width * 0.78, size.height * 0.72),
        radius: 20,
        color: const Color(0x42FFFFFF)
      ),
      (
        offset: Offset(size.width * 0.40, size.height * 0.82),
        radius: 16,
        color: const Color(0x40FFE1F0)
      ),
    ];

    for (final circle in circles) {
      paint.color = circle.color;
      canvas.drawCircle(circle.offset, circle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
