import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/midora_card_view_data.dart';
import '../../core/widgets/midora_design.dart';
import '../../core/widgets/midora_open_background.dart';
import '../detail/detail_page.dart';
import '../history/history_page.dart';
import '../store/store_page.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final AppController _controller = AppController.I;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MidoraOpenBackground(overlayOpacity: 0.10),
          SafeArea(
            bottom: false,
            child: Obx(
              () => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.lg,
                      ),
                      child: MidoraGlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dream Gallery',
                                        style: AppTextStyles.h2.copyWith(
                                          color: AppColors.textInverse,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Soft-focus scenes curated around your Midora mood.',
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.textSecondary,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                MidoraCircleButton(
                                  size: 44,
                                  icon: Icons.history_rounded,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => const HistoryPage()),
                                    );
                                  },
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                MidoraCircleButton(
                                  size: 44,
                                  icon: Icons.shopping_bag_rounded,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => const StorePage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_controller.isLoadingFeed.value)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryLight),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        24,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final card = _controller.feedCards[index];
                            return _DreamCard(
                              card: card,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DetailPage(card: card),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: _controller.feedCards.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.63,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DreamCard extends StatelessWidget {
  const _DreamCard({
    required this.card,
    required this.onTap,
  });

  final dynamic card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final data = describeMidoraCard(card);
    final story = _storyPreview(data);
    final accentLabel = data.tags
        .where((item) => item.trim().isNotEmpty)
        .cast<String?>()
        .firstWhere(
          (item) => item != null && item.trim().isNotEmpty,
          orElse: () => data.kicker,
        );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.borderRadiusXl,
          boxShadow: AppColors.shadowLg,
        ),
        child: ClipRRect(
          borderRadius: AppBorderRadius.borderRadiusXl,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _MidoraSmartImage(path: data.imagePath),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.58),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                top: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.90),
                    borderRadius: AppBorderRadius.borderRadiusFull,
                  ),
                  child: Text(
                    accentLabel!,
                    style: AppTextStyles.smallMedium.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.title,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 18,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story,
                      style: AppTextStyles.small.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.38,
                        shadows: const [
                          Shadow(
                            color: Color(0x88000000),
                            blurRadius: 16,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _storyPreview(MidoraCardViewData data) {
    final source = data.description.trim().isNotEmpty
        ? data.description.trim()
        : data.subtitle.trim();
    final compact = source.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) {
      return 'Tap to open this dreamy scene.';
    }
    if (compact.length <= 88) {
      return compact;
    }
    return '${compact.substring(0, 85).trimRight()}...';
  }
}

class _MidoraSmartImage extends StatelessWidget {
  const _MidoraSmartImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveFilePath(path);
    final isFile = resolved != null;

    if (isFile) {
      return Image.file(
        File(resolved!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
          );
        },
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        );
      },
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

  if (trimmed.startsWith('/')) return trimmed;

  return null;
}
