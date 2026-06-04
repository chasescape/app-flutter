import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achievenote/gozi/models/achievement.dart';
import 'package:achievenote/gozi/routes/global_router.dart';
import 'package:achievenote/gozi/services/achievement_storage_service.dart';
import 'package:achievenote/gozi/widgets/common/app_card.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

/// History Page - Display all achievement history
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? _selectedCategory;

  void _showDeleteDialog(Achievement achievement) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Achievement'),
        content:
            Text('Are you sure you want to delete "${achievement.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final service = Get.find<AchievementStorageService>();
              await service.deleteAchievement(achievement.id);
              Get.snackbar(
                'Deleted',
                'Achievement deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All'),
        content: const Text(
            'Are you sure you want to delete all achievements? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final service = Get.find<AchievementStorageService>();
              await service.clearAll();
              Get.snackbar(
                'Cleared',
                'All achievements deleted',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Your Cards'),
        actions: [
          IconButton(
            onPressed: _showClearAllDialog,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: GetX<AchievementStorageService>(
        builder: (service) {
          final achievements = service.achievements;
          final categories = service.getCategories();
          final selectedCategory =
              categories.contains(_selectedCategory) ? _selectedCategory : null;
          final visibleAchievements = selectedCategory == null
              ? achievements
              : service.getAchievementsByCategory(selectedCategory);

          if (achievements.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      size: 64,
                      color: AppTheme.textDisabled,
                    ),
                    const SizedBox(height: AppTheme.md),
                    Text(
                      'Your achievement journey starts here',
                      textAlign: TextAlign.center,
                      style: AppTheme.h3.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.sm),
                    Text(
                      'Create your first card to begin tracking your wins',
                      textAlign: TextAlign.center,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textDisabled,
                      ),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    ElevatedButton(
                      onPressed: () => GlobalRouter.I.goToCreate(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        foregroundColor: AppTheme.primaryWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Create Your First Card'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.md,
              AppTheme.md,
              AppTheme.md,
              262,
            ),
            children: [
              _GoalFolderShelf(
                selectedCategory: selectedCategory,
                totalCount: achievements.length,
                categories: categories,
                countForCategory: service.getCategoryCount,
                onSelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: AppTheme.lg),
              ...visibleAchievements.map((achievement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.md),
                  child: AchievementCard(
                    title: achievement.title,
                    description: achievement.description,
                    tags: achievement.tags,
                    imagePath: achievement.imagePath,
                    category: achievement.category,
                    note: achievement.note,
                    createdAt: achievement.createdAt,
                    onTap: () => GlobalRouter.I.goToResult(
                      imagePath: achievement.imagePath,
                      title: achievement.title,
                      description: achievement.description,
                      tags: achievement.tags,
                      category: achievement.category,
                      note: achievement.note,
                    ),
                    onDelete: () => _showDeleteDialog(achievement),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _GoalFolderShelf extends StatelessWidget {
  final String? selectedCategory;
  final int totalCount;
  final List<String> categories;
  final int Function(String category) countForCategory;
  final ValueChanged<String?> onSelected;

  const _GoalFolderShelf({
    required this.selectedCategory,
    required this.totalCount,
    required this.categories,
    required this.countForCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppTheme.md),
      borderRadius: AppTheme.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryButtonGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.folder_special_rounded,
                  color: AppTheme.primaryWhite,
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: Text(
                  'Goal Folders',
                  style: AppTheme.body.copyWith(
                    color: AppTheme.textInverse,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$totalCount cards',
                style: AppTheme.small.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          Wrap(
            spacing: AppTheme.sm,
            runSpacing: AppTheme.sm,
            children: [
              _FolderChip(
                label: 'All',
                count: totalCount,
                selected: selectedCategory == null,
                onTap: () => onSelected(null),
              ),
              ...categories.map(
                (category) => _FolderChip(
                  label: category,
                  count: countForCategory(category),
                  selected: selectedCategory == category,
                  onTap: () => onSelected(category),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FolderChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FolderChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.md,
          vertical: AppTheme.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accentRed
              : AppTheme.primaryWhite.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: selected
                ? AppTheme.accentRed
                : AppTheme.primaryWhite.withValues(alpha: 0.82),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_rounded,
              color: selected ? AppTheme.primaryWhite : AppTheme.textSecondary,
              size: 16,
            ),
            const SizedBox(width: AppTheme.xs),
            Text(
              '$label $count',
              style: AppTheme.small.copyWith(
                color:
                    selected ? AppTheme.primaryWhite : AppTheme.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
