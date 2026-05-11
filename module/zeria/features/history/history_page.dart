import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_routes.dart';
import 'package:zeria/zeria/constants/app_strings.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/models/app_models.dart';
import 'package:zeria/zeria/services/app_service.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  bool _shouldShowImage(String? imageUrl) {
    final url = (imageUrl ?? '').trim();
    if (url.isEmpty) return false;
    if (url.startsWith('http://') || url.startsWith('https://')) return true;
    if (url.startsWith('assets/')) return true;
    return File(url).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    final appService = AppService.to;

    return ZeriaScreen(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: ZeriaHeader(
                title: 'History',
                subtitle: 'YOUR SAVED IDEA PATHS',
              ),
            ),
            Expanded(
              child: Obx(() {
                if (appService.historyItems.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: ZeriaEmptyState(
                      title: AppStrings.noHistoryRecords,
                      description:
                          'Analyzed photos and saved inspiration routes will show up here.',
                      action: SizedBox(
                        width: 220,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.go(AppRoutes.buildMainTabUrl(1)),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Create your first spark',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final grouped = appService.groupedHistory;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                  children: grouped.entries.map((entry) {
                    return _buildGroup(context, entry.key, entry.value);
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(
      BuildContext context, String date, List<HistoryItem> items) {
    final visibleItems = items.where((item) => _shouldShowImage(item.imageUrl));
    if (visibleItems.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZeriaPill(
            label: date,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 14),
          ...visibleItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildHistoryCard(context, item),
              )),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryItem item) {
    final showImage = _shouldShowImage(item.imageUrl);
    return ZeriaSurfaceCard(
      onTap: () {
        if (item.hasSparkData) {
          context.push('/detail/${item.id}');
          return;
        }
        Get.snackbar(
          AppStrings.info,
          'Full idea detail is available for analyzed photo sparks only.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      padding: const EdgeInsets.all(12),
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: ZeriaAdaptiveImage(path: item.imageUrl),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: ZeriaIconButton(
                    icon: Icons.delete_outline_rounded,
                    onPressed: () => _showDeleteDialog(context, item),
                    iconColor: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  item.destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyBold,
                ),
              ),
              if (!showImage) ...[
                const SizedBox(width: 10),
                ZeriaIconButton(
                  icon: Icons.delete_outline_rounded,
                  onPressed: () => _showDeleteDialog(context, item),
                  iconColor: AppColors.error,
                ),
              ],
              ZeriaPill(
                label: DateFormat('MM/dd HH:mm').format(item.createdAt),
                backgroundColor: AppColors.surfaceTint,
                foregroundColor: AppColors.brandHotPink,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.hasSparkData
                ? 'Tap to open the full set of actionable ideas.'
                : 'Saved draft without a full idea detail view.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, HistoryItem item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Remove this image from your history?'),
        actions: [
          ZeriaDialogActions(
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              AppService.to.deleteHistoryItem(item.id);
              Navigator.pop(context);
            },
            confirmLabel: AppStrings.delete,
          ),
        ],
      ),
    );
  }
}
