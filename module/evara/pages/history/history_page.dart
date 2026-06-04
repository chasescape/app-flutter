import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

import '../../../gen_a/A.dart';
import '../../core/router/app_routes.dart';
import '../../core/singletons/ai_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/evara_scaffold.dart';
import '../../features/history/history_controller.dart';

/// History page with image-led masonry-like cards.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());

    return EvaraScaffold(
      safeTop: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            title: const Text('Look Gallery'),
            actions: [
              Watch((context) {
                final hasRecords = controller.records.value.isNotEmpty;
                if (!hasRecords) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: controller.clearAll,
                  tooltip: 'Clear All',
                );
              }),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              AppTheme.spacingSm,
              AppTheme.spacingLg,
              120,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(controller),
                  const SizedBox(height: AppTheme.spacingLg),
                  Watch((context) {
                    final isLoading = controller.isLoading.value;
                    final filtered = controller.filteredRecords.value;

                    if (isLoading) {
                      return SizedBox(
                        height: 420,
                        child: AppWidgets.loading(
                          message: 'Loading your gallery...',
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return AppWidgets.emptyState(
                        message: 'No matching looks found.\nTry a different search or style filter.',
                        icon: '📸',
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppTheme.spacingMd,
                        mainAxisSpacing: AppTheme.spacingMd,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _RecordCard(record: filtered[index]);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(HistoryController controller) {
    return Watch((context) {
      final occasions = controller.getAvailableOccasions();
      final styles = controller.getAvailableStyles();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: controller.setSearchQuery,
            decoration: const InputDecoration(
              hintText: 'Search by mood or scene',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          if (occasions.isNotEmpty || styles.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMd),
            if (occasions.isNotEmpty) ...[
              const Text(
                'Occasion',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: controller.selectedOccasion.value == 'all',
                    onTap: () => controller.setOccasionFilter('all'),
                  ),
                  ...occasions.map((occasion) => _FilterChip(
                        label: occasion,
                        isSelected:
                            controller.selectedOccasion.value == occasion,
                        onTap: () => controller.setOccasionFilter(
                          controller.selectedOccasion.value == occasion
                              ? null
                              : occasion,
                        ),
                      )),
                ],
              ),
            ],
            if (styles.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingMd),
              const Text(
                'Style',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: controller.selectedStyle.value == 'all',
                    onTap: () => controller.setStyleFilter('all'),
                  ),
                  ...styles.map((style) => _FilterChip(
                        label: style,
                        isSelected: controller.selectedStyle.value == style,
                        onTap: () => controller.setStyleFilter(
                          controller.selectedStyle.value == style ? null : style,
                        ),
                      )),
                ],
              ),
            ],
          ],
        ],
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? AppTheme.textInverse : AppTheme.textSecondary,
            fontSize: AppTheme.caption,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final MakeupRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final analysis = record.analysis;
    final styleTags = analysis.styleTags;
    final occasionTags = analysis.occasionTags;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.result,
          arguments: {'record': record.toJson()},
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(analysis.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                A.assets_evara_open,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.16),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.26),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  _formatDate(analysis.createdAt),
                  style: const TextStyle(
                    color: AppTheme.textInverse,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.24),
                  foregroundColor: AppTheme.textInverse,
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                onPressed: () =>
                    Get.find<HistoryController>().deleteRecord(record.id),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    styleTags.isNotEmpty ? styleTags.first : 'Beauty Edit',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textInverse,
                      fontSize: AppTheme.body,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (occasionTags.isNotEmpty)
                        _OverlayChip(label: occasionTags.first),
                      if (styleTags.length > 1)
                        _OverlayChip(label: styleTags[1]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _OverlayChip extends StatelessWidget {
  final String label;

  const _OverlayChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textInverse,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
