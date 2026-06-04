import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../app/theme/theme.dart';
import '../../app/state/app_state.dart';
import '../../app/state/app_state_provider.dart';
import '../../models/novel.dart';
import '../../widgets/animations/bounce_in_animation.dart';
import '../../widgets/visuals/sunny_visuals.dart';

/// Stats Page
/// Displays reading statistics with charts
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final stats = appState.readingStats;

    return Scaffold(
      body: SunnyPage(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart,
                    color: Color(AppColors.primaryMain),
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Reading Statistics',
                    style: AppTypography.getH2TextStyle(
                      const Color(AppColors.textPrimary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Books',
                      value: '${stats?.totalBooks ?? 0}',
                      icon: Icons.menu_book,
                      color: const Color(AppColors.primaryMain),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      title: 'Finished',
                      value: '${stats?.finishedBooks ?? 0}',
                      icon: Icons.check_circle,
                      color: const Color(AppColors.statusFinished),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Reading Time',
                      value: stats?.totalReadingTimeDisplay ?? '0m',
                      icon: Icons.access_time,
                      color: const Color(AppColors.secondaryMain),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      title: 'This Month',
                      value: '${stats?.currentMonthBooks ?? 0}',
                      icon: Icons.calendar_today,
                      color: const Color(AppColors.statusReading),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Reading Status Distribution (Doughnut Chart)
              _StatusDistributionSection(appState: appState),

              const SizedBox(height: AppSpacing.lg),

              // Monthly Reading Chart
              _MonthlyChartSection(stats: stats),

              const SizedBox(height: AppSpacing.lg),

              // Monthly Reading Time Trend
              _ReadingTimeTrendSection(stats: stats),

              const SizedBox(height: AppSpacing.lg),

              // Genre Distribution
              _GenreDistributionSection(appState: appState),

              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 100),
      child: SunnyCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppBorderRadius.allMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.getH2TextStyle(
                const Color(AppColors.textPrimary),
              ).copyWith(
                fontWeight: AppTypography.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.getSmallTextStyle(
                const Color(AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyChartSection extends StatelessWidget {
  final ReadingStats? stats;

  const _MonthlyChartSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 200),
      child: SunnyCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Reading Activity',
              style: AppTypography.getH3TextStyle(
                const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  labelStyle: TextStyle(
                    color: Color(AppColors.textSecondary),
                    fontSize: 12,
                  ),
                ),
                primaryYAxis: const NumericAxis(
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Color(AppColors.divider),
                  ),
                  minimum: 0,
                  labelStyle: TextStyle(
                    color: Color(AppColors.textSecondary),
                    fontSize: 12,
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  color: const Color(AppColors.backgroundTertiary),
                  textStyle: const TextStyle(
                    color: Color(AppColors.textPrimary),
                  ),
                  format: 'point.x: point.y books',
                ),
                series: <CartesianSeries<ChartData, String>>[
                  // Line series for trend (pattern_id: time_count_trend)
                  LineSeries<ChartData, String>(
                    dataSource: stats?.monthlyData
                            .map((d) =>
                                ChartData(d.month, d.booksRead.toDouble()))
                            .toList() ??
                        [],
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.value,
                    color: const Color(AppColors.primaryMain),
                    width: 2.5,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 6,
                      width: 6,
                      color: Color(AppColors.primaryMain),
                      borderColor: Color(AppColors.cardBackground),
                      borderWidth: 2,
                    ),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                      textStyle: TextStyle(
                        color: Color(AppColors.textPrimary),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingTimeTrendSection extends StatelessWidget {
  final ReadingStats? stats;

  const _ReadingTimeTrendSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 250),
      child: SunnyCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Time Trend',
              style: AppTypography.getH3TextStyle(
                const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Monthly reading time in hours',
              style: AppTypography.getSmallTextStyle(
                const Color(AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (stats?.monthlyData == null ||
                stats!.monthlyData.every((d) => d.minutesRead == 0))
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'No reading time data yet',
                    style: AppTypography.getCaptionTextStyle(
                      const Color(AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(
                    majorGridLines: MajorGridLines(width: 0),
                    labelStyle: TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 12,
                    ),
                  ),
                  primaryYAxis: const NumericAxis(
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Color(AppColors.divider),
                    ),
                    minimum: 0,
                    labelStyle: TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 12,
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: const Color(AppColors.backgroundTertiary),
                    textStyle: const TextStyle(
                      color: Color(AppColors.textPrimary),
                    ),
                    format: 'point.x: point.y hours',
                  ),
                  series: <CartesianSeries<ChartData, String>>[
                    // Area series for reading time trend (pattern_id: time_sum_trend)
                    AreaSeries<ChartData, String>(
                      dataSource: stats?.monthlyData
                              .map((d) => ChartData(
                                    d.month,
                                    (d.minutesRead / 60).toDouble(),
                                  ))
                              .toList() ??
                          [],
                      xValueMapper: (ChartData data, _) => data.category,
                      yValueMapper: (ChartData data, _) => data.value,
                      color:
                          const Color(AppColors.secondaryMain).withOpacity(0.6),
                      borderColor: const Color(AppColors.secondaryMain),
                      borderWidth: 2,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(AppColors.secondaryMain).withOpacity(0.5),
                          const Color(AppColors.secondaryMain)
                              .withOpacity(0.05),
                        ],
                      ),
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        height: 6,
                        width: 6,
                        color: Color(AppColors.secondaryMain),
                        borderColor: Color(AppColors.cardBackground),
                        borderWidth: 2,
                      ),
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top,
                        textStyle: TextStyle(
                          color: Color(AppColors.textPrimary),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      enableTooltip: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GenreDistributionSection extends StatelessWidget {
  final AppState appState;

  const _GenreDistributionSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final genreGroups = appState.getNovelsByGenre();
    final sortedEntries = genreGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return BounceInAnimation(
      delay: const Duration(milliseconds: 300),
      child: SunnyCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genre Distribution',
              style: AppTypography.getH3TextStyle(
                const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (genreGroups.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'No reading data yet',
                    style: AppTypography.getCaptionTextStyle(
                      const Color(AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: sortedEntries.length * 56.0,
                child: SfCartesianChart(
                  primaryXAxis: NumericAxis(
                    isVisible: false,
                    minimum: 0,
                    maximum: sortedEntries.isEmpty
                        ? 0
                        : sortedEntries.first.value.length.toDouble() + 1,
                  ),
                  primaryYAxis: const CategoryAxis(
                    majorGridLines: MajorGridLines(width: 0),
                    labelStyle: TextStyle(
                      color: Color(AppColors.textSecondary),
                      fontSize: 12,
                    ),
                  ),
                  plotAreaBorderWidth: 0,
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: const Color(AppColors.backgroundTertiary),
                    textStyle: const TextStyle(
                      color: Color(AppColors.textPrimary),
                    ),
                    format: 'point.x: point.y books',
                  ),
                  series: <CartesianSeries<GenreChartData, num>>[
                    BarSeries<GenreChartData, num>(
                      dataSource: sortedEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final genreEntry = entry.value;
                        return GenreChartData(
                          genre: genreEntry.key.label,
                          count: genreEntry.value.length,
                          index: index,
                        );
                      }).toList(),
                      xValueMapper: (GenreChartData data, _) => data.count,
                      yValueMapper: (GenreChartData data, _) => data.index,
                      color: const Color(AppColors.primaryMain),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(4),
                      ),
                      width: 0.7,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.outer,
                        textStyle: TextStyle(
                          color: Color(AppColors.textPrimary),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      enableTooltip: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GenreChartData {
  final String genre;
  final int count;
  final int index;

  GenreChartData({
    required this.genre,
    required this.count,
    required this.index,
  });
}

class _StatusDistributionSection extends StatelessWidget {
  final AppState appState;

  const _StatusDistributionSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final statusGroups = appState.getNovelsByStatusGrouped();

    return BounceInAnimation(
      delay: const Duration(milliseconds: 150),
      child: SunnyCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Status',
              style: AppTypography.getH3TextStyle(
                const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (appState.novels.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'No reading data yet',
                    style: AppTypography.getCaptionTextStyle(
                      const Color(AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 220,
                child: SfCircularChart(
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    textStyle: TextStyle(
                      color: const Color(AppColors.textSecondary),
                      fontSize: AppTypography.small,
                    ),
                    overflowMode: LegendItemOverflowMode.wrap,
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    color: const Color(AppColors.backgroundTertiary),
                    textStyle: const TextStyle(
                      color: const Color(AppColors.textPrimary),
                    ),
                    format: 'point.x: point.y',
                  ),
                  series: <CircularSeries>[
                    DoughnutSeries<StatusChartData, String>(
                      dataSource: statusGroups.entries.map((entry) {
                        return StatusChartData(
                          status: entry.key.label,
                          count: entry.value.length,
                          color: _getStatusColor(entry.key),
                        );
                      }).toList(),
                      xValueMapper: (StatusChartData data, _) => data.status,
                      yValueMapper: (StatusChartData data, _) => data.count,
                      pointColorMapper: (StatusChartData data, _) => data.color,
                      innerRadius: '60%',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        textStyle: TextStyle(
                          color: Color(AppColors.textPrimary),
                          fontSize: 11,
                        ),
                        labelIntersectAction: LabelIntersectAction.shift,
                      ),
                      enableTooltip: true,
                      strokeColor: const Color(AppColors.cardBackground),
                      strokeWidth: 2,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(NovelStatus status) {
    switch (status) {
      case NovelStatus.toRead:
        return const Color(AppColors.statusToRead);
      case NovelStatus.reading:
        return const Color(AppColors.statusReading);
      case NovelStatus.finished:
        return const Color(AppColors.statusFinished);
      case NovelStatus.paused:
        return const Color(AppColors.statusPaused);
      case NovelStatus.dropped:
        return const Color(AppColors.statusDropped);
    }
  }
}

class StatusChartData {
  final String status;
  final int count;
  final Color color;

  StatusChartData({
    required this.status,
    required this.count,
    required this.color,
  });
}
