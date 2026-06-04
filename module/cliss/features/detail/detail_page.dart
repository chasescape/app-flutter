import 'package:flutter/material.dart';
import 'package:cliss/cliss/app/routes/app_routes.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_button.dart';
import 'package:cliss/cliss/app/widgets/app_card.dart';
import 'package:cliss/cliss/app/widgets/app_image_frame.dart';
import 'package:cliss/cliss/app/widgets/app_scaffold.dart';
import 'package:cliss/cliss/data/models/meal_analysis.dart';

class DetailPage extends StatefulWidget {
  final MealAnalysis? meal;
  final bool returnToHomeOnExit;

  const DetailPage({
    super.key,
    this.meal,
    this.returnToHomeOnExit = false,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isBookmarked = false;

  void _handleExit() {
    if (widget.returnToHomeOnExit) {
      AppRoutes.toMain();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    if (meal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: const Center(child: Text('Meal data not found')),
      );
    }

    return AppScaffold(
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          36,
          AppSpacing.md,
          120,
        ),
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: _handleExit,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    meal.oneLineSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _CircleButton(
                  icon: _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  onTap: () {
                    setState(() {
                      _isBookmarked = !_isBookmarked;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppImageFrame(
            imagePath: meal.assetImg,
            height: 408,
            borderRadius: AppBorderRadius.allXlarge,
            overlay: Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Row(
                children: [
                  _Tag(text: meal.sceneCard.mealType),
                  const SizedBox(width: AppSpacing.sm),
                  _Tag(text: meal.sceneCard.balanceTag, soft: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            meal.oneLineSummary,
            style: AppTextStyles.h1,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            meal.sceneCard.visualDescription,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Metric(
                  label: 'Calories',
                  value:
                      '${meal.nutritionAnalysis.calorieEstimate.min}-${meal.nutritionAnalysis.calorieEstimate.max}',
                ),
                _Metric(
                  label: 'Confidence',
                  value: '${(meal.confidence * 100).toInt()}%',
                ),
                _Metric(
                  label: 'Portion',
                  value: meal.sceneCard.estimatedPortion,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            title: 'Detected',
            subtitle: 'The image remains untouched above, so all reading content stays below the photo.',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: meal.sceneCard.mainItems
                  .take(6)
                  .map((item) => _Chip(text: item))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            title: 'Nutrition notes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InsightRow(title: 'Protein', body: meal.nutritionAnalysis.proteinNote),
                _InsightRow(title: 'Carbs', body: meal.nutritionAnalysis.carbNote),
                _InsightRow(title: 'Fat', body: meal.nutritionAnalysis.fatNote),
                _InsightRow(
                  title: 'Overall',
                  body: meal.nutritionAnalysis.overallBalanceSummary,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            title: 'Next meal',
            subtitle: meal.nextMealSuggestion.focusArea,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Chip(text: meal.nextMealSuggestion.mealType, filled: true),
                const SizedBox(height: AppSpacing.md),
                Text(
                  meal.nextMealSuggestion.recommendationSummary,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Try', style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.sm),
                ...meal.nextMealSuggestion.foodSuggestions
                    .map((food) => _BulletLine(text: food)),
                const SizedBox(height: AppSpacing.md),
                Text('Avoid', style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.sm),
                ...meal.nextMealSuggestion.avoidSuggestions
                    .map((food) => _BulletLine(text: food, negative: true)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            title: 'Breakfast idea',
            subtitle: meal.nextBreakfastSuggestion.mainOption.name,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.nextBreakfastSuggestion.mainOption.description,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: meal.nextBreakfastSuggestion.mainOption.keyIngredients
                      .map((item) => _Chip(text: item))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                _BulletLine(
                  text: 'Prep time: ${meal.nextBreakfastSuggestion.mainOption.prepTime}',
                ),
                ...meal.nextBreakfastSuggestion.prepTips
                    .map((tip) => _BulletLine(text: tip)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            backgroundColor: AppColors.surfaceSoft,
            child: Text(
              'This estimate is for wellness guidance only and should not replace personalized medical or nutritional advice.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'View another meal',
            onPressed: _handleExit,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCCFFFFFF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryMain),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.small.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String title;
  final String body;
  final bool isLast;

  const _InsightRow({
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  final bool negative;

  const _BulletLine({
    required this.text,
    this.negative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: negative ? AppColors.semanticError : AppColors.accentDark,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool filled;

  const _Chip({
    required this.text,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: filled ? AppColors.primaryMain : AppColors.surfaceGlass,
        borderRadius: AppBorderRadius.allMedium,
        border: filled ? null : Border.all(color: AppColors.borderSoft),
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          color: filled ? AppColors.textInverse : AppColors.primaryMain,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool soft;

  const _Tag({
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
        color: soft ? const Color(0xBBFFFFFF) : AppColors.primaryMain,
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
