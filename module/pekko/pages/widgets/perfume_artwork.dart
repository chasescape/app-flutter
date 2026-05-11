import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/perfume_record.dart';

/// Decorative perfume artwork used across cards and detail pages.
class PerfumeArtwork extends StatelessWidget {
  final String title;
  final String subtitle;
  final PerfumeNote note;
  final double height;
  final bool dark;
  final bool showNoteChip;
  final String? imagePath;

  const PerfumeArtwork({
    super.key,
    required this.title,
    required this.subtitle,
    required this.note,
    this.height = 220,
    this.dark = false,
    this.showNoteChip = true,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    final textColor =
        hasImage || dark ? AppColors.textInverse : AppColors.textPrimary;
    final subColor = hasImage || dark
        ? AppColors.textInverse.withValues(alpha: 0.82)
        : AppColors.textSecondary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.allLarge,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
                  Color(0xFF6A5A89),
                  Color(0xFF8574A7),
                  Color(0xFFAFA3D2),
                ]
              : [
                  AppColors.backgroundElevated,
                  AppColors.backgroundSecondary,
                  _accentFor(note).withValues(alpha: 0.24),
                ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (hasImage) ...[
            Positioned.fill(
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _DefaultArtworkBackground(note: note);
                },
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.16),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            const Positioned.fill(child: _DefaultArtworkBackground()),
            Positioned(
              top: -28,
              right: -18,
              child: _GlowOrb(
                size: height * 0.48,
                color: _accentFor(note).withValues(alpha: dark ? 0.18 : 0.12),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -18,
              child: _GlowOrb(
                size: height * 0.36,
                color: AppColors.accent.withValues(alpha: dark ? 0.14 : 0.12),
              ),
            ),
          ],
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showNoteChip)
                    _NoteChip(
                      label: note.displayName.toUpperCase(),
                      dark: hasImage || dark,
                    ),
                  const Spacer(),
                  Text(
                    subtitle.toUpperCase(),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: subColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h1.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!hasImage)
            Positioned(
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: _BottleIllustration(
                title: title,
                subtitle: subtitle,
                dark: dark,
              ),
            ),
        ],
      ),
    );
  }

  Color _accentFor(PerfumeNote note) {
    switch (note) {
      case PerfumeNote.floral:
        return const Color(0xFFDCCFF1);
      case PerfumeNote.woody:
        return const Color(0xFFB7A7CF);
      case PerfumeNote.oriental:
        return const Color(0xFFA58EC8);
      case PerfumeNote.citrus:
        return const Color(0xFFD6C9F0);
      case PerfumeNote.fresh:
        return const Color(0xFFC9D7F2);
      case PerfumeNote.gourmand:
        return const Color(0xFFD7C3E8);
      case PerfumeNote.green:
        return const Color(0xFFC4D4D8);
      case PerfumeNote.spicy:
        return const Color(0xFFCCABCC);
    }
  }
}

class _DefaultArtworkBackground extends StatelessWidget {
  final PerfumeNote? note;

  const _DefaultArtworkBackground({this.note});

  @override
  Widget build(BuildContext context) {
    final baseAccent = switch (note) {
      PerfumeNote.floral => const Color(0xFFDCCFF1),
      PerfumeNote.woody => const Color(0xFFB7A7CF),
      PerfumeNote.oriental => const Color(0xFFA58EC8),
      PerfumeNote.citrus => const Color(0xFFD6C9F0),
      PerfumeNote.fresh => const Color(0xFFC9D7F2),
      PerfumeNote.gourmand => const Color(0xFFD7C3E8),
      PerfumeNote.green => const Color(0xFFC4D4D8),
      PerfumeNote.spicy => const Color(0xFFCCABCC),
      null => AppColors.accent,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundElevated,
            AppColors.backgroundSecondary,
            baseAccent.withValues(alpha: 0.24),
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
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: color.a * 0.35),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteChip extends StatelessWidget {
  final String label;
  final bool dark;

  const _NoteChip({
    required this.label,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.18)
            : AppColors.backgroundElevated.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.16)
              : AppColors.accentDark.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: dark ? AppColors.textInverse : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _BottleIllustration extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool dark;

  const _BottleIllustration({
    required this.title,
    required this.subtitle,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor =
        dark ? AppColors.backgroundElevated : AppColors.cardBackground;
    final capColor =
        dark ? AppColors.primaryContrastText : AppColors.primaryDark;

    return SizedBox(
      width: 118,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 2,
            child: Container(
              width: 88,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppShadows.sm,
              ),
            ),
          ),
          Container(
            width: 102,
            height: 138,
            decoration: BoxDecoration(
              color: const Color(0xD9F9F4FF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
              ),
              boxShadow: AppShadows.md,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 9,
                  left: 18,
                  right: 18,
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: capColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppShadows.sm,
                    ),
                  ),
                ),
                Positioned(
                  top: 34,
                  left: 14,
                  right: 14,
                  bottom: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: labelColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subtitle.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _splitTitle(title),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _splitTitle(String value) {
    if (value.length <= 12) return value.toUpperCase();
    final parts = value.split(' ');
    if (parts.length < 2) return value.toUpperCase();
    final middle = (parts.length / 2).ceil();
    return '${parts.take(middle).join(' ').toUpperCase()}\n${parts.skip(middle).join(' ').toUpperCase()}';
  }
}

class PerfumeStemDecoration extends StatelessWidget {
  final double height;
  final Color color;

  const PerfumeStemDecoration({
    super.key,
    this.height = 160,
    this.color = AppColors.secondaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: height,
      child: CustomPaint(
        painter: _StemPainter(color),
      ),
    );
  }
}

class _StemPainter extends CustomPainter {
  final Color color;

  _StemPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stemPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final petalPaint = Paint()
      ..color = color.withValues(alpha: 0.24)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.45, size.height)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.62,
        size.width * 0.36,
        size.height * 0.18,
      );
    canvas.drawPath(path, stemPaint);

    for (final value in [0.26, 0.38, 0.52, 0.68]) {
      final offset = Offset(
        size.width * (0.26 + math.sin(value * math.pi) * 0.18),
        size.height * value,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: offset,
          width: 28,
          height: 18,
        ),
        petalPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width - offset.dx, offset.dy - 6),
          width: 24,
          height: 16,
        ),
        petalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
