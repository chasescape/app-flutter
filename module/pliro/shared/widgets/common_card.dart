import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';

/// Full-screen dreamy background inspired by the reference image.
class DreamBackground extends StatelessWidget {
  final Widget child;
  final bool includeSafeArea;

  const DreamBackground({
    super.key,
    required this.child,
    this.includeSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = includeSafeArea ? SafeArea(child: child) : child;

    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _DreamBandsPainter())),
        Positioned.fill(child: content),
      ],
    );
  }
}

class _DreamBandsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topBand = Path()
      ..moveTo(0, size.height * 0.06)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.00,
        size.width * 0.64,
        size.height * 0.12,
        size.width,
        size.height * 0.03,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    final topPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x66D7FBF6),
          Color(0x33E8FFF2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.18));

    canvas.drawPath(topBand, topPaint);

    final blushBand = Path()
      ..moveTo(0, size.height * 0.42)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.33,
        size.width * 0.54,
        size.height * 0.46,
        size.width,
        size.height * 0.36,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final blushPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x00FFE3F8),
          Color(0x80FFE3F8),
          Color(0x44E8E2FF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.30, size.width, size.height));

    canvas.drawPath(blushBand, blushPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DreamScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool includeSafeArea;

  const DreamScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.includeSafeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dreamCream,
      appBar: appBar,
      body: DreamBackground(
        includeSafeArea: includeSafeArea,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Soft glass card. The legacy name is kept so existing pages can migrate
/// without changing controller code.
class NeonCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const NeonCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge);
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withOpacity(0.72),
          width: 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: card,
      ),
    );
  }
}

class DreamChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback? onTap;

  const DreamChip({
    super.key,
    required this.label,
    this.selected = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.roseDeep;
    final foreground = selected ? AppColors.textInverse : baseColor;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingSM,
          ),
          decoration: BoxDecoration(
            color: selected
                ? baseColor
                : Color.alphaBlend(
                    baseColor.withOpacity(0.10),
                    AppColors.surface.withOpacity(0.72),
                  ),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(
              color: selected
                  ? baseColor.withOpacity(0.20)
                  : baseColor.withOpacity(0.22),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.captionMedium.copyWith(
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class DreamImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final IconData placeholderIcon;
  final double? iconSize;

  const DreamImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.image_outlined,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = path;
    if (imagePath == null || imagePath.trim().isEmpty) {
      return DreamImagePlaceholder(
        icon: placeholderIcon,
        iconSize: iconSize,
      );
    }

    if (_isNetworkPath(imagePath)) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => DreamImagePlaceholder(
          icon: Icons.broken_image_outlined,
          iconSize: iconSize,
        ),
      );
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => DreamImagePlaceholder(
          icon: Icons.broken_image_outlined,
          iconSize: iconSize,
        ),
      );
    }

    return Image.file(
      File(imagePath),
      fit: fit,
      errorBuilder: (context, error, stackTrace) => DreamImagePlaceholder(
        icon: Icons.broken_image_outlined,
        iconSize: iconSize,
      ),
    );
  }

  bool _isNetworkPath(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}

class DreamImagePlaceholder extends StatelessWidget {
  final IconData icon;
  final double? iconSize;

  const DreamImagePlaceholder({
    super.key,
    this.icon = Icons.image_outlined,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceMint,
            AppColors.blushMist.withOpacity(0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize ?? 38,
          color: AppColors.roseDeep.withOpacity(0.44),
        ),
      ),
    );
  }
}

/// Image card with restrained text so the image remains the focus.
class ImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const ImageCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DreamImage(path: imageUrl),
                  if (actions != null)
                    Positioned(
                      top: AppTheme.spacingSM,
                      right: AppTheme.spacingSM,
                      child: Row(children: actions!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            title,
            style: AppTextStyles.bodySemiBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTextStyles.small,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
