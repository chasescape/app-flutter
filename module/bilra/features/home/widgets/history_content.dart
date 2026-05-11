import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bilra/bilra/controllers/history_controller.dart';
import 'package:bilra/bilra/data/models/makeup_analysis.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/widgets/bilra_ui.dart';

class HistoryContent extends StatelessWidget {
  const HistoryContent({
    super.key,
    required this.embeddedInHome,
  });

  final bool embeddedInHome;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          BilraTopBar(
            title: embeddedInHome ? 'Saved looks' : 'History',
            subtitle: embeddedInHome
                ? 'Your recent image-led results'
                : 'Past analyses',
            leading: embeddedInHome
                ? null
                : BilraIconChipButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => AppRoutes.pop(context),
                  ),
            trailing: Obx(() {
              if (!controller.hasHistory) {
                return const SizedBox.shrink();
              }
              return BilraIconChipButton(
                icon: Icons.delete_outline_rounded,
                label: 'Clear',
                onTap: () => _showClearDialog(context, controller),
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryMain),
                  ),
                );
              }

              if (!controller.hasHistory) {
                return BilraEmptyState(
                  title: 'No looks yet',
                  description:
                      'Your analyzed photos will land here as a visual gallery.',
                  icon: Icons.photo_library_outlined,
                  alignment: const Alignment(0, -0.18),
                  action: BilraPrimaryButton(
                    label: 'Create your first look',
                    icon: Icons.add_a_photo_rounded,
                    onTap: () => AppRoutes.pushNamed(context, AppRoutes.create),
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  embeddedInHome ? 120 : AppSpacing.xl,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.7,
                ),
                itemCount: controller.historyItems.length,
                itemBuilder: (context, index) {
                  final item = controller.historyItems[index];
                  return _HistoryCard(
                    item: item,
                    index: index,
                    onTap: () => AppRoutes.toDetail(context, index),
                    onLongPress: () =>
                        _showDeleteDialog(context, index, controller),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    int index,
    HistoryController controller,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete look', style: AppTextStyles.h3),
        content: const Text(
          'Remove this result from your saved gallery?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await controller.removeHistoryItem(index);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.semanticError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDialog(
    BuildContext context,
    HistoryController controller,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear gallery', style: AppTextStyles.h3),
        content: const Text(
          'This removes every saved result from your history.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await controller.clearHistory();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.semanticError,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  final MakeupAnalysis item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final title = item.makeupRecommendation.primaryStyle.replaceAll('_', ' ');
    final note = item.makeupRecommendation.styleTagline;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: BilraGlassCard(
        padding: const EdgeInsets.all(10),
        radius: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: BilraImageFrame(
                      imagePath: item.assetImg,
                      fallbackIndex: index,
                      borderRadius: 22,
                    ),
                  ),
                  const Positioned(
                    top: 10,
                    left: 10,
                    child: BilraPill(
                      label: 'Saved',
                      color: AppColors.backgroundOverlay,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatTitle(title),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTitle(String value) {
    return value
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
