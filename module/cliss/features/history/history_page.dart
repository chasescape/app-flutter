import 'package:flutter/material.dart';
import 'package:cliss/cliss/app/routes/app_routes.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_button.dart';
import 'package:cliss/cliss/app/widgets/app_card.dart';
import 'package:cliss/cliss/app/widgets/app_image_frame.dart';
import 'package:cliss/cliss/app/widgets/app_scaffold.dart';
import 'package:cliss/cliss/app/services/meal_storage_service.dart';
import 'package:cliss/cliss/data/models/meal_analysis.dart';

class HistoryPage extends StatefulWidget {
  final int refreshVersion;

  const HistoryPage({
    super.key,
    this.refreshVersion = 0,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<MealAnalysis> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    final history = await MealStorageService.instance.getMealHistory();
    if (!mounted) return;
    setState(() {
      _historyItems = history;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    await MealStorageService.instance.clearMealHistory();
    if (!mounted) return;
    setState(() {
      _historyItems = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Records'),
        actions: [
          TextButton(
            onPressed: _historyItems.isEmpty ? null : _clearHistory,
            child: Text(
              'Clear',
              style: AppTextStyles.label.copyWith(
                color: _historyItems.isEmpty
                    ? AppColors.textTertiary
                    : AppColors.primaryMain,
              ),
            ),
          ),
        ],
      ),
      safeBottom: false,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      120,
                    ),
                    children: [
                      ..._historyItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: _HistoryCard(item: item),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 56,
                  color: AppColors.secondaryDark,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('No meal records yet', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Once you add a meal, it will show up here with its photo and estimated kcal.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Add First Meal',
            onPressed: () => AppRoutes.toCreate(),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final MealAnalysis item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => AppRoutes.toDetail(item),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImageFrame(
            imagePath: item.assetImg,
            height: 248,
            borderRadius: const BorderRadius.vertical(
              top: AppBorderRadius.radiusLarge,
            ),
            overlay: Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Row(
                children: [
                  _Badge(text: item.sceneCard.mealType),
                  const Spacer(),
                  _Badge(
                    text: '${item.nutritionAnalysis.calorieEstimate.min}-${item.nutritionAnalysis.calorieEstimate.max} kcal',
                    soft: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.oneLineSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyEmphasis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.sceneCard.visualDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final bool soft;

  const _Badge({
    required this.text,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: soft ? const Color(0xB2FFFFFF) : AppColors.primaryMain,
        borderRadius: AppBorderRadius.allSmall,
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          color: soft ? AppColors.primaryMain : AppColors.textInverse,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
