import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../core/models/ingredient_analysis.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../main/main_page.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(analysisHistoryProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'History',
                                  style: AppTextStyles.h2.copyWith(
                                    fontSize: 26,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  history.isEmpty
                                      ? 'Your completed scans will show up here once you analyze a product.'
                                      : 'Revisit saved results, compare scans, or clear entries you no longer need.',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          if (history.isNotEmpty)
                            TextButton(
                              onPressed: () =>
                                  _showClearHistoryDialog(context, ref),
                              child: const Text('Clear all'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
        if (history.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: EmptyState(
                message:
                    'No saved scans yet.\nStart from Home with a camera or gallery scan.',
                icon: Icons.history_toggle_off_rounded,
                actionLabel: 'Go to home',
                onAction: () => _navigateToHome(context),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildRecentCard(history[index], context, ref),
                childCount: history.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentCard(
    IngredientAnalysis analysis,
    BuildContext context,
    WidgetRef ref,
  ) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.zero,
      onTap: () => AppRoutes.toResult({'analysis': analysis}),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppBorderRadius.large),
              ),
              child: AppRemoteImage(imageUrl: analysis.imageUrl),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IngredientCategoryTag(category: _primaryCategory(analysis)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    analysis.productName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(analysis.createdAt),
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showDeleteDialog(context, analysis, ref),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    }
    if (diff.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _primaryCategory(IngredientAnalysis analysis) {
    if (analysis.categories.isEmpty) {
      return 'Result';
    }
    return analysis.categories.first.split(' ').first;
  }

  void _navigateToHome(BuildContext context) {
    try {
      final mainPageState = context.findAncestorStateOfType<State<MainPage>>();
      if (mainPageState is MainPageState) {
        mainPageState.navigateToTab(0);
      }
    } catch (_) {
      AppRoutes.toMain();
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    IngredientAnalysis analysis,
    WidgetRef ref,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete result'),
        content: const Text('Remove this result from the recent list?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(analysisHistoryProvider.notifier)
                  .deleteAnalysis(analysis.id);
              Get.back();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Result deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear history'),
        content: const Text(
          'Delete all saved history items? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(analysisHistoryProvider.notifier).clearHistory();
              Get.back();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text(
              'Clear all',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryContent extends ConsumerWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const HistoryPage();
  }
}
