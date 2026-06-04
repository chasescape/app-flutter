import 'package:flutter/material.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_card.dart';
import 'package:cliss/cliss/app/widgets/app_scaffold.dart';
import 'package:cliss/cliss/data/models/meal_analysis.dart';

class DataPage extends StatelessWidget {
  final List<MealAnalysis> mealData;
  final int dailyTarget;

  const DataPage({
    super.key,
    required this.mealData,
    this.dailyTarget = 2000,
  });

  @override
  Widget build(BuildContext context) {
    final dailyData = _buildDailyData(mealData, dailyTarget);
    final loggedDailyData = dailyData.where((item) => item.calories > 0).toList();
    final weekChartData = _buildWeekdayChartData(dailyData);
    final weekMax = weekChartData.fold<int>(
      dailyTarget,
      (maxValue, item) => item.calories > maxValue ? item.calories : maxValue,
    );

    return AppScaffold(
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Track how many kcal you ate each day and whether you stayed on target.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryStat(
                        label: 'Target',
                        value: '$dailyTarget kcal',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryStat(
                        label: 'Logged days',
                        value: '${loggedDailyData.length}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _SummaryStat(
                        label: 'Hit target',
                        value: '${loggedDailyData.where((item) => item.hitTarget).length}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily calories', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 220,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weekChartData
                        .map(
                          (item) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: _BarColumn(
                                label: item.weekday,
                                calories: item.calories,
                                target: dailyTarget,
                                maxValue: weekMax,
                                hitTarget: item.hitTarget,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Target check', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                if (loggedDailyData.isEmpty)
                  Text(
                    'Save a meal and your daily check will show up here.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  ...loggedDailyData.map((item) => _DayRow(item: item, target: dailyTarget)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<_DailyCalories> _buildDailyData(List<MealAnalysis> mealData, int target) {
  final now = DateTime.now();
  final totals = <String, _DailyCaloriesBuilder>{};

  for (final meal in mealData) {
    final parsed =
        DateTime.tryParse(meal.createdAt) ??
        DateTime(now.year, now.month, now.day);
    final key = _dayKey(parsed);
    final calories =
        (meal.nutritionAnalysis.calorieEstimate.min + meal.nutritionAnalysis.calorieEstimate.max) ~/
            2;
    totals.putIfAbsent(
      key,
      () => _DailyCaloriesBuilder(
        date: DateTime(parsed.year, parsed.month, parsed.day),
      ),
    );
    totals[key]!
      ..calories += calories
      ..mealTypes.add(meal.sceneCard.mealType);
  }

  final items = totals.values
      .map(
        (item) {
          final sortedMealTypes = item.mealTypes.toList()
            ..sort((a, b) => _mealTypeOrder(a).compareTo(_mealTypeOrder(b)));
          return _DailyCalories(
            date: item.date,
            weekday: _weekdayLabel(item.date.weekday),
            calories: item.calories,
            hitTarget: item.calories <= target,
            mealTypes: sortedMealTypes,
          );
        },
      )
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return items;
}

String _dayKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _weekdayLabel(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'Mon',
    DateTime.tuesday => 'Tue',
    DateTime.wednesday => 'Wed',
    DateTime.thursday => 'Thu',
    DateTime.friday => 'Fri',
    DateTime.saturday => 'Sat',
    _ => 'Sun',
  };
}

List<_DailyCalories> _buildWeekdayChartData(List<_DailyCalories> dailyData) {
  final byWeekday = <int, _DailyCalories>{};
  for (final item in dailyData) {
    final weekday = item.date.weekday;
    if (weekday >= DateTime.monday && weekday <= DateTime.sunday) {
      byWeekday[weekday] = item;
    }
  }

  return List.generate(7, (index) {
    final weekday = DateTime.monday + index;
    final existing = byWeekday[weekday];
    if (existing != null) return existing;
    final today = DateTime.now();
    final fallbackDate = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - weekday),
    );
    return _DailyCalories(
      date: fallbackDate,
      weekday: _weekdayLabel(weekday),
      calories: 0,
      hitTarget: false,
      mealTypes: const [],
    );
  });
}

class _DailyCalories {
  final DateTime date;
  final String weekday;
  final int calories;
  final bool hitTarget;
  final List<String> mealTypes;

  const _DailyCalories({
    required this.date,
    required this.weekday,
    required this.calories,
    required this.hitTarget,
    required this.mealTypes,
  });
}

class _DailyCaloriesBuilder {
  final DateTime date;
  int calories = 0;
  final Set<String> mealTypes = {};

  _DailyCaloriesBuilder({
    required this.date,
  });
}

int _mealTypeOrder(String mealType) {
  return switch (mealType.toLowerCase()) {
    'breakfast' => 0,
    'lunch' => 1,
    'dinner' => 2,
    'snack' => 3,
    _ => 4,
  };
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xB2FFFFFF),
        borderRadius: AppBorderRadius.allMedium,
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  final String label;
  final int calories;
  final int target;
  final int maxValue;
  final bool hitTarget;

  const _BarColumn({
    required this.label,
    required this.calories,
    required this.target,
    required this.maxValue,
    required this.hitTarget,
  });

  @override
  Widget build(BuildContext context) {
    final safeMax = maxValue <= 0 ? 1 : maxValue;
    final barHeight = calories == 0 ? 10.0 : (calories / safeMax) * 140;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          calories == 0 ? '--' : '$calories',
          style: AppTextStyles.small.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          height: 148,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: AppBorderRadius.allMedium,
          ),
          child: Container(
            width: double.infinity,
            height: barHeight.clamp(10, 148),
            decoration: BoxDecoration(
              color: calories == 0
                  ? AppColors.borderSoft
                  : hitTarget
                      ? AppColors.primaryMain
                      : AppColors.semanticError,
              borderRadius: AppBorderRadius.allMedium,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final _DailyCalories item;
  final int target;

  const _DayRow({
    required this.item,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final month = item.date.month.toString().padLeft(2, '0');
    final day = item.date.day.toString().padLeft(2, '0');
    final status = item.hitTarget ? 'On target' : 'Over target';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0x80FFFFFF),
          borderRadius: AppBorderRadius.allLarge,
          border: Border.all(color: AppColors.borderSoft),
        ),
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
                        '$month/$day',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${item.calories} / $target kcal',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item.hitTarget
                        ? AppColors.surfaceMint
                        : const Color(0x1AF05A7E),
                    borderRadius: AppBorderRadius.allSmall,
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.small.copyWith(
                      color: item.hitTarget
                          ? AppColors.primaryMain
                          : AppColors.semanticError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: item.mealTypes
                  .map(
                    (meal) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: AppBorderRadius.allSmall,
                      ),
                      child: Text(
                        meal,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
