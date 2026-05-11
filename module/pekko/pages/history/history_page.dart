import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/history_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/perfume_record.dart';
import '../widgets/record_card.dart';

/// History page
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
        actions: [
          PopupMenuButton<_MenuOption>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == _MenuOption.clearFilters) {
                controller.clearFilters();
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: _MenuOption.clearFilters,
                  child: Text('Clear Filters'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.records.isEmpty) {
            return _EmptyState(
              onRefresh: controller.refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: CustomScrollView(
              slivers: [
                // Search and filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.paddingMD,
                    child: Column(
                      children: [
                        // Search bar
                        TextField(
                          onChanged: controller.setSearchQuery,
                          decoration: InputDecoration(
                            hintText: 'Search fragrances...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: Obx(
                              () => controller.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        controller.setSearchQuery('');
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Filter chips
                        Obx(
                          () => Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              if (controller.filterNote.value != null)
                                FilterChip(
                                  label: Text(
                                      controller.filterNote.value!.displayName),
                                  selected: true,
                                  onSelected: (_) =>
                                      controller.setNoteFilter(null),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () =>
                                      controller.setNoteFilter(null),
                                ),
                              if (controller.filterScene.value != null)
                                FilterChip(
                                  label: Text(controller
                                      .filterScene.value!.displayName),
                                  selected: true,
                                  onSelected: (_) =>
                                      controller.setSceneFilter(null),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () =>
                                      controller.setSceneFilter(null),
                                ),
                              if (controller.filterNote.value == null &&
                                  controller.filterScene.value == null)
                                ActionChip(
                                  label: const Text('Filter by note'),
                                  avatar:
                                      const Icon(Icons.filter_list, size: 18),
                                  onPressed: () => _showFilterSheet(context),
                                ),
                              ActionChip(
                                label: const Text('Filter by scene'),
                                avatar: const Icon(Icons.filter_list, size: 18),
                                onPressed: () => _showFilterSheet(context),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ),

                // Records grouped by date
                Obx(
                  () {
                    final grouped = controller.groupedByDate;

                    if (grouped.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: AppSpacing.paddingXL,
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: AppColors.textDisabled,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'No matching entries',
                                  style: AppTextStyles.h3,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Try a softer filter or another keyword.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final currentDate = grouped.keys.toList()[index];
                          final records = grouped[currentDate]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                child: Text(
                                  currentDate,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),

                              // Records for this date
                              ...records.map((record) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.md,
                                    right: AppSpacing.md,
                                    bottom: AppSpacing.md,
                                  ),
                                  child: Dismissible(
                                    key: Key(record.id),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (direction) async {
                                      final confirm = await Get.dialog<bool>(
                                        AlertDialog(
                                          title: const Text('Delete entry'),
                                          content: const Text(
                                            'Are you sure you want to remove this scent entry?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Get.back(result: false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Get.back(result: true),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.error,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      return confirm ?? false;
                                    },
                                    onDismissed: (_) {
                                      controller.deleteRecord(record.id);
                                    },
                                    background: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius: AppBorderRadius.allMedium,
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: AppSpacing.paddingMD,
                                      child: const Icon(
                                        Icons.delete,
                                        color: AppColors.textInverse,
                                      ),
                                    ),
                                    child: RecordCard(
                                      record: record,
                                      onTap: () {
                                        Get.toNamed(
                                          '${AppRoutes.recordDetail}?id=${record.id}',
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                        childCount: grouped.keys.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final controller = Get.find<HistoryController>();

    Get.bottomSheet(
      Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.large),
            topRight: Radius.circular(AppBorderRadius.large),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filters', style: AppTextStyles.h3),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Scent family', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: PerfumeNote.values.map((note) {
                  return Obx(
                    () => FilterChip(
                      label: Text(note.displayName),
                      selected: controller.filterNote.value == note,
                      onSelected: (_) {
                        controller.setNoteFilter(
                          controller.filterNote.value == note ? null : note,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Occasion', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: UsageScene.values.map((scene) {
                  return Obx(
                    () => FilterChip(
                      label: Text(scene.displayName),
                      selected: controller.filterScene.value == scene,
                      onSelected: (_) {
                        controller.setSceneFilter(
                          controller.filterScene.value == scene ? null : scene,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

enum _MenuOption { clearFilters }

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_florist_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Scent Memories Yet',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your fragrance journey begins with the first recording',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => Get.toNamed('/record'),
              child: const Text('Record First Scent'),
            ),
          ],
        ),
      ),
    );
  }
}
