import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/midora_card_view_data.dart';
import '../../core/widgets/midora_design.dart';
import '../../core/widgets/midora_open_background.dart';
import '../../data/models/scene_card.dart';
import '../../models/lyric_card.dart';
import '../detail/detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AppController _controller = AppController.I;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MidoraOpenBackground(overlayOpacity: 0.24),
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
                  child: MidoraTopBar(
                    title: 'Your Keepsakes',
                    subtitle:
                        'A cozy trail of the scenes and pieces you created.',
                    leading: MidoraCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Obx(() {
                    final cards = <dynamic>[
                      ..._controller.mySceneCards,
                      ..._controller.myCreatedCards.where(
                        (card) => (card.imageUrl?.trim().isNotEmpty ?? false),
                      ),
                    ];

                    if (cards.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: MidoraGlassCard(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Nothing created yet',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textInverse,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Create your first dreamy card and it will live here.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.xxl,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return Dismissible(
                          key: ValueKey(_stableKey(card)),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(context),
                          background: const SizedBox.shrink(),
                          secondaryBackground: const _DeleteBackground(),
                          onDismissed: (_) {
                            if (card is SceneCard) {
                              _controller.deleteSceneCard(card);
                            } else if (card is LyricCard) {
                              _controller.deleteLyricCard(card);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Deleted',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textInverse,
                                  ),
                                ),
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.55),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.fromLTRB(
                                  AppSpacing.md,
                                  0,
                                  AppSpacing.md,
                                  AppSpacing.md,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.borderRadiusLg,
                                ),
                              ),
                            );
                          },
                          child: _HistoryCard(card: card),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.card});

  final dynamic card;

  @override
  Widget build(BuildContext context) {
    final data = describeMidoraCard(card);
    final description = _descriptionPreview(data);
    final meta = data.tags.where((item) => item.trim().isNotEmpty).take(2);
    final showThumb = _shouldShowThumb(card, data.imagePath);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailPage(card: card)),
          );
        },
        child: MidoraGlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: showThumb
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HistoryThumb(path: data.imagePath),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title,
                                style: AppTextStyles.bodyBold.copyWith(
                                  color: AppColors.textInverse,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                description,
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: meta
                            .map(
                              (item) => MidoraPill(
                                label: item,
                                backgroundColor: AppColors.glassLight,
                                borderColor: AppColors.glassBorder,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.textInverse,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: meta
                            .map(
                              (item) => MidoraPill(
                                label: item,
                                backgroundColor: AppColors.glassLight,
                                borderColor: AppColors.glassBorder,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  String _descriptionPreview(MidoraCardViewData data) {
    final source = data.description.trim().isNotEmpty
        ? data.description.trim()
        : data.subtitle.trim();
    final compact = source.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) {
      return 'Open this piece to see the full details.';
    }
    if (compact.length <= 120) {
      return compact;
    }
    return '${compact.substring(0, 117).trimRight()}...';
  }
}

bool _shouldShowThumb(dynamic card, String imagePath) {
  final path = imagePath.trim();
  if (path.isEmpty) return false;

  final isNetwork = path.startsWith('http://') || path.startsWith('https://');
  final isLocalFile = path.startsWith('/');

  // For scene cards, only show the thumb when it is the user-picked image path
  // (stored as a local file path). Avoid showing a generic asset placeholder.
  if (card is SceneCard) return isLocalFile || isNetwork;

  // For lyric cards, only show when user provided an image url/path.
  if (card is LyricCard) return isLocalFile || isNetwork;

  return false;
}

class _HistoryThumb extends StatelessWidget {
  const _HistoryThumb({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(22);

    Widget image;
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      image = Image.network(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (trimmed.startsWith('/')) {
      image = Image.file(
        File(trimmed),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      image = Image.asset(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: image,
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.white.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_rounded,
        color: Colors.white.withValues(alpha: 0.65),
      ),
    );
  }
}

String _stableKey(dynamic card) {
  if (card is SceneCard) {
    // Avoid long keys; keep it stable for the life of the stored card.
    return 'scene:${card.assetImg}:${card.visualStory.hashCode}';
  }
  if (card is LyricCard) {
    return 'lyric:${card.id}';
  }
  return 'unknown:${card.hashCode}';
}

Future<bool> _confirmDelete(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: MidoraGlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete this keepsake?',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textInverse,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This will remove it from your history list.',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: MidoraGlassCard(
                      padding: EdgeInsets.zero,
                      blur: 14,
                      borderRadius: AppBorderRadius.borderRadiusFull,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textInverse,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: 14,
                          ),
                          shape: AppBorderRadius.shapeXl,
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.buttonSmall.copyWith(
                            color: AppColors.textInverse,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: AppBorderRadius.borderRadiusFull,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF5A8A),
                            Color(0xFFFF2D55),
                          ],
                        ),
                        boxShadow: AppColors.glowMd,
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: 14,
                          ),
                          shape: AppBorderRadius.shapeXl,
                        ),
                        child: Text(
                          'Delete',
                          style: AppTextStyles.buttonSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ClipRRect(
        borderRadius: AppBorderRadius.borderRadiusXl,
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.borderRadiusXl,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFFFF2D55).withValues(alpha: 0.10),
                const Color(0xFFFF2D55).withValues(alpha: 0.42),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFFFA2B6).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_rounded,
                color: Colors.white.withValues(alpha: 0.95),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Delete',
                style: AppTextStyles.bodyBold.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
