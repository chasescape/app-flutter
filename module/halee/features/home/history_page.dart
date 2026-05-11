import 'package:flutter/material.dart';
import 'dart:io';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/widgets/glass_card.dart';
import '../../app/widgets/bounce_in_animation.dart';
import '../../app/router/app_router.dart';
import '../../data/models/snap_analysis.dart';
import '../../light_handle.dart';
import 'home_tab_controller.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LightHandle.historyVersion,
      builder: (context, _, __) {
        final history = LightHandle.getAnalysisHistory();

        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          body: SafeArea(
            child: Column(
              children: [
                // Custom AppBar (same style as Feedback)
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top > 0 ? 8 : 16,
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundPrimary.withValues(alpha: 0.8),
                    border: const Border(
                      bottom:
                          BorderSide(color: AppColors.cardBorder, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        onPressed: () {
                          final navigator = Navigator.of(context);
                          if (navigator.canPop()) {
                            navigator.pop();
                            return;
                          }
                          HomeTabController.index.value = 2;
                        },
                        color: AppColors.textPrimary,
                      ),
                      Expanded(
                        child: Text(
                          'My Analyses',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Count badge
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: BounceInAnimation(
                              delay: const Duration(milliseconds: 100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryMain.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.borderRadiusSm,
                                  ),
                                ),
                                child: Text(
                                  '${history.length} Items',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.accentMain),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // History items or empty state
                      if (history.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.photo_library_outlined,
                                    size: 64,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No analyses yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Tap + to analyze your first photo',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = history[index];
                              return BounceInAnimation(
                                delay:
                                    Duration(milliseconds: 200 + index * 100),
                                child: _buildHistoryCard(context, item, index),
                              );
                            },
                            childCount: history.length,
                          ),
                        ),

                      // Bottom spacing
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, SnapAnalysis item, int index) {
    final title = item.diagnosis.oneLineSummary.length > 50
        ? '${item.diagnosis.oneLineSummary.substring(0, 50)}...'
        : item.diagnosis.oneLineSummary;
    final description = item.diagnosis.topImprovement;
    final date = item.createdAt != null
        ? '${item.createdAt!.year}-${item.createdAt!.month.toString().padLeft(2, '0')}-${item.createdAt!.day.toString().padLeft(2, '0')}'
        : '';
    final tags = item.tags.take(4).toList();

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: GlassCard(
        borderRadius: AppSpacing.borderRadiusXl,
        onTap: () => AppRouter.toDetail(context, data: item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.assetImg.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                child: _buildPreviewImage(item.assetImg),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            // Tags
            LayoutBuilder(
              builder: (context, constraints) {
                final maxChipWidth = constraints.maxWidth * 0.48;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxChipWidth),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryMain.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.borderRadiusSm),
                        ),
                        child: Text(
                          tag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.accentMain,
                              ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                GestureDetector(
                  onTap: () async {
                    await LightHandle.deleteAnalysis(index);
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: double.infinity,
        height: 320,
        fit: BoxFit.cover,
      );
    }

    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: double.infinity,
        height: 320,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: double.infinity,
      height: 320,
      color: AppColors.cardBg,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }

}
