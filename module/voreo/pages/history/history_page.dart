import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../models/hairstyle_result.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_border.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../ui/dreamy_ui.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find<UserController>();

    return DreamyPageScaffold(
      showFloor: false,
      child: Obx(() {
        final List<HairstyleResult> history = controller.history
            .where((item) => _resolveDisplayPath(item) != null)
            .toList();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: DreamyIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: AppRoutes.goBack,
                        ),
                      ),
                      Text(
                        'History',
                        textAlign: TextAlign.center,
                        style: AppTypography.h1.copyWith(
                          fontSize: 24,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (history.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: DreamyIconButton(
                            icon: Icons.delete_outline_rounded,
                            onTap: () => _showClearDialog(controller),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (history.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: DreamyEmptyState(
                  title: 'No previews yet',
                  subtitle:
                      'Your generated looks will appear here once you create one.',
                  icon: Icons.photo_library_outlined,
                  action: SizedBox(
                    width: 220,
                    child: DreamyPrimaryButton(
                      label: 'Create first preview',
                      onTap: AppRoutes.toGenerate,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  120,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final HairstyleResult result = history[index];
                      return _HistoryCard(
                        result: result,
                        onTap: () => AppRoutes.toResult(result.id),
                        onLongPress: () =>
                            _showDeleteDialog(result, controller),
                      );
                    },
                    childCount: history.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.75,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  void _showDeleteDialog(HairstyleResult result, UserController controller) {
    Get.dialog(
      Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorder.borderRadiusXL,
        ),
        child: Padding(
          padding: AppSpacing.allLG,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline_rounded,
                  size: 42, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              const Text('Delete this preview?', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This action cannot be undone.',
                style: AppTypography.body.copyWith(color: AppColors.textGrey),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Expanded(
                    child: DreamySecondaryButton(
                      label: 'Cancel',
                      onTap: AppRoutes.goBack,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DreamyPrimaryButton(
                      label: 'Delete',
                      expanded: false,
                      onTap: () {
                        controller.deleteHistoryItem(result.id);
                        AppRoutes.goBack();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearDialog(UserController controller) {
    Get.dialog(
      Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorder.borderRadiusXL,
        ),
        child: Padding(
          padding: AppSpacing.allLG,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_sweep_rounded,
                  size: 42, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              const Text('Clear all history?', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'All saved previews will be removed from this device.',
                style: AppTypography.body.copyWith(color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Expanded(
                    child: DreamySecondaryButton(
                      label: 'Cancel',
                      onTap: AppRoutes.goBack,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DreamyPrimaryButton(
                      label: 'Clear',
                      expanded: false,
                      onTap: () {
                        controller.clearHistory();
                        AppRoutes.goBack();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _resolveDisplayPath(HairstyleResult result) {
    final List<String?> candidates = [
      result.previewImagePath,
      result.originalImagePath,
    ];

    for (final path in candidates) {
      if (path == null || path.isEmpty) {
        continue;
      }
      if (File(path).existsSync()) {
        return path;
      }
    }

    return null;
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.result,
    required this.onTap,
    required this.onLongPress,
  });

  final HairstyleResult result;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final String? displayPath = _resolveDisplayPath();
    if (displayPath == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: DreamyGlassCard(
        radius: AppBorder.radiusXLarge,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DreamyImageCard(
                radius: AppBorder.radiusLarge,
                child: Image.file(
                  File(displayPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              result.mainStyleName,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.textDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${result.createdAt.month}/${result.createdAt.day}/${result.createdAt.year}',
              style: AppTypography.small.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveDisplayPath() {
    final List<String?> candidates = [
      result.previewImagePath,
      result.originalImagePath,
    ];

    for (final path in candidates) {
      if (path == null || path.isEmpty) {
        continue;
      }
      if (File(path).existsSync()) {
        return path;
      }
    }

    return null;
  }
}
