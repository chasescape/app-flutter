import 'dart:io';

import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../models/novel.dart';
import '../../../gen_a/A.dart';

class SunnyPage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showTopDecoration;

  const SunnyPage({
    super.key,
    required this.child,
    this.padding,
    this.showTopDecoration = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(AppColors.backgroundSecondary),
            Color(AppColors.secondaryDark),
            Color(AppColors.backgroundPrimary),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (showTopDecoration)
            const Positioned(
              top: -58,
              left: -48,
              child: _SoftCircle(
                size: 172,
                color: Color(AppColors.textInverse),
                opacity: 0.18,
              ),
            ),
          const Positioned(
            top: 116,
            right: -50,
            child: _SoftCircle(
              size: 134,
              color: Color(AppColors.accentLight),
              opacity: 0.2,
            ),
          ),
          const Positioned(
            bottom: 120,
            left: -62,
            child: _SoftCircle(
              size: 148,
              color: Color(AppColors.textInverse),
              opacity: 0.2,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.md),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class SunnyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? borderRadius;

  const SunnyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? const Color(AppColors.cardBackground),
        borderRadius: borderRadius ?? AppBorderRadius.allLG,
        border: Border.all(
          color: const Color(AppColors.cardElevated),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            offset: Offset(0, 10),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Color(0x33E94A18),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class CheriaLogoMark extends StatelessWidget {
  final double size;
  final bool withShadow;

  const CheriaLogoMark({
    super.key,
    this.size = 72,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        color: const Color(AppColors.textInverse),
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(
          color: const Color(AppColors.textInverse),
          width: size * 0.04,
        ),
        boxShadow: withShadow
            ? const [
                BoxShadow(
                  color: Color(0x30000000),
                  offset: Offset(0, 8),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: Image.asset(
          A.assets_cheria_logo,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class NovelCoverArt extends StatelessWidget {
  final Novel novel;
  final double? width;
  final double? height;
  final bool compact;

  const NovelCoverArt({
    super.key,
    required this.novel,
    this.width,
    this.height,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _CoverPalette.fromGenre(novel.genre);
    final trimmedTitle = novel.title.trim();
    final titleInitial =
        trimmedTitle.isEmpty ? '?' : trimmedTitle.substring(0, 1).toUpperCase();

    return SizedBox(
      width: width,
      height: height,
      child: AspectRatio(
        aspectRatio: compact ? 0.82 : 0.72,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius:
                compact ? AppBorderRadius.allMD : AppBorderRadius.allLG,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(compact ? 0.16 : 0.24),
                offset: Offset(0, compact ? 8 : 16),
                blurRadius: compact ? 14 : 24,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                compact ? AppBorderRadius.allMD : AppBorderRadius.allLG,
            child: _UploadedCoverImage(
              coverImagePath: novel.coverImagePath,
              fallback: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: palette.colors,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: compact ? 9 : 16,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: compact ? 10 : 18,
                    right: compact ? -16 : -26,
                    child: _CoverBubble(
                      size: compact ? 64 : 118,
                      color: Colors.white.withOpacity(0.28),
                    ),
                  ),
                  Positioned(
                    bottom: compact ? -20 : -30,
                    left: compact ? -18 : -24,
                    child: _CoverBubble(
                      size: compact ? 76 : 128,
                      color: palette.accent.withOpacity(0.28),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(
                          compact ? AppSpacing.sm : AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: compact ? 42 : 78,
                            height: compact ? 42 : 78,
                            decoration: BoxDecoration(
                              color: const Color(AppColors.textInverse),
                              borderRadius: AppBorderRadius.allFull,
                              border: Border.all(
                                color: const Color(AppColors.textPrimary),
                                width: compact ? 2 : 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  offset: const Offset(0, 8),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                titleInitial,
                                style: TextStyle(
                                  color: palette.ink,
                                  fontSize: compact ? 22 : 38,
                                  fontWeight: AppTypography.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: compact ? AppSpacing.xs : AppSpacing.sm),
                          Icon(
                            _genreIcon(novel.genre),
                            color: const Color(AppColors.textInverse),
                            size: compact ? 22 : 34,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: compact ? AppSpacing.xs : AppSpacing.sm,
                    right: compact ? AppSpacing.xs : AppSpacing.sm,
                    bottom: compact ? AppSpacing.xs : AppSpacing.sm,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
                        vertical: compact ? 4 : AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.textInverse),
                        borderRadius: AppBorderRadius.allFull,
                        border: Border.all(
                          color: const Color(AppColors.textPrimary),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        novel.genre.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.getSmallTextStyle(
                          palette.ink,
                        ).copyWith(
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static IconData _genreIcon(NovelGenre genre) {
    switch (genre) {
      case NovelGenre.fantasy:
        return Icons.auto_awesome;
      case NovelGenre.romance:
        return Icons.favorite;
      case NovelGenre.scifi:
        return Icons.rocket_launch;
      case NovelGenre.mystery:
        return Icons.travel_explore;
      case NovelGenre.horror:
        return Icons.nights_stay;
      case NovelGenre.thriller:
        return Icons.flash_on;
      case NovelGenre.literary:
        return Icons.local_library;
      case NovelGenre.historical:
        return Icons.account_balance;
      case NovelGenre.other:
        return Icons.menu_book;
    }
  }
}

class _UploadedCoverImage extends StatelessWidget {
  final String? coverImagePath;
  final Widget fallback;

  const _UploadedCoverImage({
    required this.coverImagePath,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final path = coverImagePath;
    if (path == null || path.isEmpty) {
      return fallback;
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _SoftCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}

class _CoverBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _CoverBubble({
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
        color: color,
      ),
    );
  }
}

class _CoverPalette {
  final List<Color> colors;
  final Color accent;
  final Color ink;

  const _CoverPalette({
    required this.colors,
    required this.accent,
    required this.ink,
  });

  factory _CoverPalette.fromGenre(NovelGenre genre) {
    switch (genre) {
      case NovelGenre.fantasy:
        return const _CoverPalette(
          colors: [Color(0xFFFF5A1F), Color(0xFFFFC400)],
          accent: Color(0xFFFF3D6E),
          ink: Color(0xFF2A1406),
        );
      case NovelGenre.romance:
        return const _CoverPalette(
          colors: [Color(0xFFFF3D6E), Color(0xFFFFB1C8)],
          accent: Color(0xFFFFFF00),
          ink: Color(0xFF49111F),
        );
      case NovelGenre.scifi:
        return const _CoverPalette(
          colors: [Color(0xFF2F80ED), Color(0xFF66E0FF)],
          accent: Color(0xFFFFFF00),
          ink: Color(0xFF071C3B),
        );
      case NovelGenre.mystery:
        return const _CoverPalette(
          colors: [Color(0xFF7B3FFF), Color(0xFFFF7A12)],
          accent: Color(0xFFFFFF00),
          ink: Color(0xFF24103C),
        );
      case NovelGenre.horror:
        return const _CoverPalette(
          colors: [Color(0xFF2A1406), Color(0xFFFF3D4E)],
          accent: Color(0xFFFFBE00),
          ink: Color(0xFF240B08),
        );
      case NovelGenre.thriller:
        return const _CoverPalette(
          colors: [Color(0xFFFF8D00), Color(0xFFFF3D4E)],
          accent: Color(0xFF1E130B),
          ink: Color(0xFF4A1800),
        );
      case NovelGenre.literary:
        return const _CoverPalette(
          colors: [Color(0xFF20B66F), Color(0xFFFFF1B8)],
          accent: Color(0xFFFF5A1F),
          ink: Color(0xFF0F4D2E),
        );
      case NovelGenre.historical:
        return const _CoverPalette(
          colors: [Color(0xFFFFBE00), Color(0xFFFF7A12)],
          accent: Color(0xFFFFFFFF),
          ink: Color(0xFF5B2B00),
        );
      case NovelGenre.other:
        return const _CoverPalette(
          colors: [Color(0xFFFF7A12), Color(0xFFFFFF00)],
          accent: Color(0xFFFF3D6E),
          ink: Color(0xFF2A1406),
        );
    }
  }
}
