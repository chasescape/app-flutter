import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/analysis_controller.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Simple local stats page focused on clear charts and lightweight insight.
class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalysisController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final topPerfumeItems = controller.chartPerfumeStats
            .map(
              (stat) => _ChartDatum(
                label: stat.name,
                secondaryLabel: stat.brand,
                value: stat.wearCount.toDouble(),
                trailing: '${stat.wearCount}',
              ),
            )
            .toList();

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  child: controller.collectionSize == 0 &&
                          controller.totalEntries == 0
                      ? const _EmptyInsightsState()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _OverviewCard(
                              summary: _buildSummary(controller),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSpacing.md,
                              crossAxisSpacing: AppSpacing.md,
                              childAspectRatio: 1.28,
                              children: [
                                _StatCard(
                                  title: 'Bottles',
                                  value: '${controller.collectionSize}',
                                  subtitle: 'Saved collection',
                                ),
                                _StatCard(
                                  title: 'Entries',
                                  value: '${controller.totalEntries}',
                                  subtitle: 'Diary logs',
                                ),
                                _StatCard(
                                  title: 'Top note',
                                  value: controller.favoriteNoteLabel,
                                  subtitle: 'Most used family',
                                ),
                                _StatCard(
                                  title: 'Avg wear',
                                  value: controller.totalEntries == 0
                                      ? '--'
                                      : '${controller.averageLongevity.toStringAsFixed(1)}h',
                                  subtitle: 'Typical duration',
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _BarChartCard(
                              title: 'Most Worn Bottles',
                              subtitle:
                                  'A simple look at which perfumes appear most in your diary.',
                              items: topPerfumeItems,
                              emptyText:
                                  'Log a few wears to see your bottle ranking.',
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _buildSummary(AnalysisController controller) {
    if (controller.totalEntries == 0) {
      return 'You have ${controller.collectionSize} bottles saved. Start logging daily wears to unlock simple usage charts.';
    }

    final goToScene = controller.goToSceneLabel == 'None'
        ? 'daily life'
        : controller.goToSceneLabel.toLowerCase();
    final topNote = controller.favoriteNoteLabel == 'None'
        ? 'your collection'
        : controller.favoriteNoteLabel.toLowerCase();

    return 'You have logged ${controller.totalEntries} wears so far. $topNote scents show up most often, and your diary leans toward $goToScene moments.';
  }
}

class _OverviewCard extends StatelessWidget {
  final String summary;

  const _OverviewCard({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.allLarge,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFCFF),
            Color(0xFFF0E8FB),
          ],
        ),
        border: Border.all(
          color: AppColors.accentDark.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Wear Stats',
            style: AppTextStyles.h2.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium,
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h2.copyWith(
              fontFamily: AppTextStyles.bodyFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_ChartDatum> items;
  final String emptyText;

  const _BarChartCard({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue =
        items.isEmpty ? 0.0 : items.map((item) => item.value).reduce(math.max);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            Text(
              emptyText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: AppBorderRadius.allLarge,
              ),
              child: SizedBox(
                height: 230,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: _ChartGrid(),
                    ),
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: items.map((item) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              child: _VerticalBarItem(
                                item: item,
                                maxValue: maxValue,
                                barColor: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
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

class _ChartGrid extends StatelessWidget {
  const _ChartGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(3, (index) {
        return Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 1,
              color: AppColors.accentDark.withValues(alpha: 0.16),
            ),
          ),
        );
      }),
    );
  }
}

class _VerticalBarItem extends StatelessWidget {
  final _ChartDatum item;
  final double maxValue;
  final Color barColor;

  const _VerticalBarItem({
    required this.item,
    required this.maxValue,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final factor =
        maxValue <= 0 ? 0.0 : (item.value / maxValue).clamp(0.0, 1.0);
    final barHeight = 124.0 * factor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Spacer(),
        Text(
          item.trailing,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(
            color: barColor,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 132,
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 20,
            height: barHeight <= 8 ? 8 : barHeight,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: barColor.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (item.secondaryLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            item.secondaryLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.small,
          ),
        ] else
          const SizedBox(height: 18),
      ],
    );
  }
}

class _EmptyInsightsState extends StatelessWidget {
  const _EmptyInsightsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.bar_chart_rounded,
            size: 52,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No stats yet',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Save a bottle and log a few daily wears. This page will turn into a simple overview of your perfume habits.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartDatum {
  final String label;
  final String? secondaryLabel;
  final double value;
  final String trailing;

  const _ChartDatum({
    required this.label,
    this.secondaryLabel,
    required this.value,
    required this.trailing,
  });
}
