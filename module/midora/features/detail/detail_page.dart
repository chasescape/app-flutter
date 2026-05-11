import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/midora_card_view_data.dart';
import '../../core/widgets/midora_design.dart';
import '../../core/widgets/midora_open_background.dart';
import '../../data/models/scene_card.dart';
import '../../models/lyric_card.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.card});

  final Object card;

  @override
  Widget build(BuildContext context) {
    final data = describeMidoraCard(card);
    final SceneCard? sceneCard = card is SceneCard ? card as SceneCard : null;
    final LyricCard? lyricCard = card is LyricCard ? card as LyricCard : null;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MidoraOpenBackground(overlayOpacity: 0.18),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      MidoraCircleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      MidoraCircleButton(
                        icon: Icons.share_rounded,
                        onTap: () async {
                          final shareText = [
                            data.title.trim(),
                            if (data.subtitle.trim().isNotEmpty)
                              data.subtitle.trim(),
                            if (data.tags.isNotEmpty)
                              data.tags
                                  .where((t) => t.trim().isNotEmpty)
                                  .map((t) => '#${t.trim().replaceAll(' ', '')}')
                                  .join(' '),
                          ].where((s) => s.isNotEmpty).join('\n\n');

                          final resolved = _resolveFilePath(data.imagePath);
                          if (resolved != null && File(resolved).existsSync()) {
                            await Share.shareXFiles(
                              [XFile(resolved)],
                              text: shareText,
                              subject: data.title,
                            );
                            return;
                          }

                          await Share.share(
                            shareText,
                            subject: data.title,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailCenteredBlock(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _DetailHero(imagePath: data.imagePath),
                              const SizedBox(height: AppSpacing.md),
                              _DetailSurface(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.title,
                                      style: AppTextStyles.h2.copyWith(
                                        color: _DetailPalette.title,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data.subtitle,
                                      style: AppTextStyles.body.copyWith(
                                        color: _DetailPalette.subtitle,
                                      ),
                                    ),
                                    if (data.tags.isNotEmpty) ...[
                                      const SizedBox(height: AppSpacing.md),
                                      Wrap(
                                        spacing: AppSpacing.sm,
                                        runSpacing: AppSpacing.sm,
                                        children: data.tags
                                            .where((item) =>
                                                item.trim().isNotEmpty)
                                            .map(
                                              (tag) => MidoraPill(
                                                label: tag,
                                                icon:
                                                    Icons.auto_awesome_rounded,
                                                foregroundColor:
                                                    _DetailPalette.pillText,
                                                backgroundColor: _DetailPalette
                                                    .pillBackground,
                                                borderColor:
                                                    _DetailPalette.pillBorder,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                    const SizedBox(height: AppSpacing.lg),
                                    const _DetailSectionTitle(
                                      title: 'Story',
                                      subtitle:
                                          'A quick read to give the image a little more soul.',
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      data.description.isEmpty
                                          ? 'A dreamy Midora moment waiting for more details.'
                                          : data.description,
                                      style: AppTextStyles.body.copyWith(
                                        color: _DetailPalette.body,
                                        height: 1.58,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (sceneCard != null) ...[
                          _DetailCenteredBlock(
                            child: _DetailSurface(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _DetailSectionTitle(
                                    title: 'Scene Notes',
                                    subtitle:
                                        'Core atmosphere cues extracted from the image.',
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _DetailInfoRow(
                                    label: 'Location',
                                    value: sceneCard.sceneCard.location.value,
                                  ),
                                  _DetailInfoRow(
                                    label: 'Time',
                                    value: sceneCard.sceneCard.time.value,
                                  ),
                                  _DetailInfoRow(
                                    label: 'Atmosphere',
                                    value: sceneCard.sceneCard.atmosphere.value,
                                  ),
                                  _DetailInfoRow(
                                    label: 'Subject',
                                    value: sceneCard.sceneCard.subject.value,
                                  ),
                                  _DetailInfoRow(
                                    label: 'Mood',
                                    value: sceneCard.sceneCard.mood.value,
                                  ),
                                  _DetailInfoRow(
                                    label: 'Color tone',
                                    value: sceneCard.sceneCard.colorTone.value,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (sceneCard.emotionalKeywords.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            _DetailCenteredBlock(
                              child: _DetailSurface(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _DetailSectionTitle(
                                      title: 'Emotional Keywords',
                                      subtitle:
                                          'Little cues to keep the scene soft and memorable.',
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Wrap(
                                      spacing: AppSpacing.sm,
                                      runSpacing: AppSpacing.sm,
                                      children: sceneCard.emotionalKeywords
                                          .map(
                                            (item) => MidoraPill(
                                              label: item,
                                              icon: Icons.pets_rounded,
                                              backgroundColor:
                                                  _DetailPalette.pillBackground,
                                              foregroundColor:
                                                  _DetailPalette.pillText,
                                              borderColor:
                                                  _DetailPalette.pillBorder,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (sceneCard.suggestedLyricStyles.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            _DetailCenteredBlock(
                              child: _DetailSurface(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _DetailSectionTitle(
                                      title: 'Suggested Styles',
                                      subtitle:
                                          'Purr-fect directions if you want to turn this into words.',
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    ...sceneCard.suggestedLyricStyles.map(
                                      (style) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: AppSpacing.sm),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Icon(
                                                Icons.auto_awesome_rounded,
                                                size: 16,
                                                color: AppColors.secondaryLight,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.sm),
                                            Expanded(
                                              child: Text(
                                                style,
                                                style:
                                                    AppTextStyles.body.copyWith(
                                                  color: _DetailPalette.body,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                        if (lyricCard != null) ...[
                          _DetailCenteredBlock(
                            child: _DetailSurface(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _DetailSectionTitle(
                                    title: 'Track Details',
                                    subtitle: 'Metadata for your lyric card.',
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _DetailInfoRow(
                                      label: 'Artist', value: lyricCard.artist),
                                  _DetailInfoRow(
                                      label: 'Album', value: lyricCard.album),
                                  _DetailInfoRow(
                                      label: 'Genre', value: lyricCard.genre),
                                  _DetailInfoRow(
                                      label: 'Likes',
                                      value: '${lyricCard.likes}'),
                                ],
                              ),
                            ),
                          ),
                        ],
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
}

class _DetailCenteredBlock extends StatelessWidget {
  const _DetailCenteredBlock({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: child,
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveFilePath(imagePath);
    final isFile = resolved != null;
    return Container(
      height: 500,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.borderRadiusXl,
        boxShadow: AppColors.shadowLg,
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.borderRadiusXl,
        child: Stack(
          fit: StackFit.expand,
          children: [
            isFile
                ? Image.file(
                    File(resolved!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.backgroundGradient,
                        ),
                      );
                    },
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.backgroundGradient,
                        ),
                      );
                    },
                  ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _resolveFilePath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;

  if (trimmed.startsWith('file://')) {
    final uri = Uri.tryParse(trimmed);
    final p = uri?.toFilePath(windows: false);
    return (p == null || p.isEmpty) ? null : p;
  }

  // Heuristic: absolute paths are treated as local image files.
  if (trimmed.startsWith('/')) return trimmed;

  return null;
}

class _DetailSurface extends StatelessWidget {
  const _DetailSurface({
    required this.child,
    this.padding = AppSpacing.paddingMd,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppBorderRadius.borderRadiusXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.borderRadiusXl,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x40FFFFFF),
                Color(0x2AD8B6FF),
                Color(0x228456D8),
              ],
            ),
            border: Border.all(color: _DetailPalette.border),
            boxShadow: AppColors.shadowMd,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: _DetailPalette.title,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: _DetailPalette.subtitle,
          ),
        ),
      ],
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
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
                color: _DetailPalette.subtitle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: _DetailPalette.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPalette {
  static const Color border = Color(0x52FFFFFF);
  static const Color title = Color(0xFFF9F5FF);
  static const Color subtitle = Color(0xD7D8C9F4);
  static const Color body = Color(0xF0F4ECFF);
  static const Color pillText = Color(0xFFFFE778);
  static const Color pillBackground = Color(0x2BFFF3B0);
  static const Color pillBorder = Color(0x70FFE384);
}
