import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/history_controller.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';
import '../../data/models/saved_result_item.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Obx(
                  () => AppTopBar(
                    title: 'Saved results',
                    subtitle: 'VISUAL LIBRARY',
                    actions: controller.historyItems.isEmpty
                        ? null
                        : [
                            Tooltip(
                              message: 'Clear all',
                              child: AppRoundIconButton(
                                icon: Icons.delete_outline_rounded,
                                onTap: controller.clearAll,
                                iconColor: AppColors.semanticError,
                              ),
                            ),
                          ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: Obx(
                    () => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : controller.isEmpty.value
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                onRefresh: controller.refresh,
                                child: ListView.separated(
                                  physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  itemCount: controller.historyItems.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: AppSpacing.md),
                                  itemBuilder: (context, index) {
                                    return _buildHistoryItem(
                                        controller.historyItems[index]);
                                  },
                                ),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SizedBox(
        width: 360,
        height: 280,
        child: AppSurface(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppGradients.accent,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.neon(AppColors.secondaryMain),
                  ),
                  child: const Icon(
                    Icons.collections_outlined,
                    color: AppColors.textOnDark,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'No saved results yet',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Your analyzed shots and AI generations will show up here once you create them.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(SavedResultItem item) {
    return AppSurface(
      onTap: () => controller.openItem(item),
      onLongPress: () => controller.deleteItem(item),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppBorderRadius.xxl),
            ),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.18,
                  child: Image.file(
                    File(item.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration:
                            const BoxDecoration(gradient: AppGradients.accent),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: AppColors.textOnDark,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                if ((item.subtitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(_formatDate(item.createdAt),
                        style: AppTextStyles.small),
                    const Spacer(),
                    Text('${item.coinsUsed} coins', style: AppTextStyles.small),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
