import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cliss/cliss/app/routes/app_routes.dart';
import 'package:cliss/cliss/app/services/meal_storage_service.dart';
import 'package:cliss/cliss/app/services/user_service.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_button.dart';
import 'package:cliss/cliss/app/widgets/app_card.dart';
import 'package:cliss/cliss/app/widgets/app_image_frame.dart';
import 'package:cliss/cliss/app/widgets/app_scaffold.dart';
import 'package:cliss/cliss/data/models/meal_analysis.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  static const int saveMealCost = 12;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  File? _selectedImage;
  MealType _mealType = MealType.lunch;

  @override
  void dispose() {
    _mealController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _selectedImage = File(image.path);
    });
  }

  int get _mealCalories => int.tryParse(_calorieController.text.trim()) ?? 0;
  int get _mealProtein => int.tryParse(_proteinController.text.trim()) ?? 0;

  String get _mealTip {
    if (_selectedImage == null) {
      return 'Upload a photo for this meal so you can visually track what you ate.';
    }
    if (_mealCalories == 0) {
      return 'Photo added. Now fill in the meal name and calories so today stays easy to manage.';
    }
    if (_mealProtein >= 30) {
      return 'Nice protein range. This meal works well for recovery and satiety.';
    }
    return 'Good record. Add a few notes if you want this meal to be easier to repeat later.';
  }

  Future<void> _saveMeal() async {
    final mealName = _mealController.text.trim();
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a meal photo first')),
      );
      return;
    }
    if (mealName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter what you ate')),
      );
      return;
    }
    if (!UserService.instance.hasEnoughCoins(saveMealCost)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need 12 coins to save this meal record')),
      );
      return;
    }

    final calories = _mealCalories > 0 ? _mealCalories : 420;
    final protein = _mealProtein > 0 ? _mealProtein : 18;
    final note = _noteController.text.trim();

    final meal = MealAnalysis(
      assetImg: _selectedImage!.path,
      createdAt: DateTime.now().toIso8601String(),
      sceneCard: SceneCard(
        mealType: _mealType.label,
        mainItems: [mealName],
        estimatedPortion: '1 serving',
        oilLevel: 'Moderate',
        balanceTag: protein >= 30 ? 'Protein-forward' : 'Balanced',
        visualDescription: note.isEmpty ? 'Logged manually from your meal tracker.' : note,
      ),
      nutritionAnalysis: NutritionAnalysis(
        calorieEstimate: CalorieEstimate(
          min: calories,
          max: calories,
          unit: 'kcal',
          confidence: 0.92,
        ),
        proteinNote: protein >= 30
            ? 'Strong protein intake for this meal.'
            : 'Protein is a little light, so your next meal can help balance it.',
        carbNote: 'Tracked manually from your entry.',
        fatNote: 'Use your photo and notes to remember how filling this meal felt.',
        overallBalanceSummary: _mealTip,
      ),
      nextMealSuggestion: NextMealSuggestion(
        mealType: _mealType == MealType.dinner ? 'Tomorrow breakfast' : 'Next meal',
        focusArea: 'Keep the next meal easy to log and balanced.',
        recommendationSummary: _mealTip,
        foodSuggestions: const [
          'Add a lean protein source',
          'Keep vegetables or fruit in the next plate',
          'Choose a simple portion you can repeat',
        ],
        avoidSuggestions: const [
          'Skipping the next meal entirely',
          'Adding extra snack calories without tracking',
        ],
        portionTip: 'Use this meal as your reference point for the rest of the day.',
      ),
      nextBreakfastSuggestion: NextBreakfastSuggestion(
        mainOption: BreakfastOption(
          name: 'Simple high-protein breakfast',
          description: 'A repeatable breakfast makes the rest of the day easier to manage.',
          prepTime: '5-10 min',
          keyIngredients: const ['Eggs', 'Greek yogurt', 'Fruit'],
        ),
        alternativeIngredients: const ['Oats', 'Toast', 'Protein milk'],
        prepTips: const [
          'Keep breakfast lighter if this meal was heavy.',
          'Add more protein if this meal was low in protein.',
        ],
        whyRecommended: 'It helps keep your daily meal rhythm steady.',
      ),
      oneLineSummary: mealName,
      tags: [if (protein >= 30) 'High protein' else 'Logged meal', _mealType.label],
      confidence: 0.92,
    );

    await MealStorageService.instance.saveMealAnalysis(meal);
    await UserService.instance.spendCoins(saveMealCost);
    await UserService.instance.incrementCreated();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal saved for today. 12 coins deducted.')),
    );
    await AppRoutes.toDetail(meal, returnToHomeOnExit: true);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Create')),
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
                Text('Track this meal', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Upload what you ate, then add calories and quick notes for your body goal. Each saved record costs 12 coins.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _InfoStat(
                        label: 'Type',
                        value: _mealType.label,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _InfoStat(
                        label: 'Calories',
                        value: _mealCalories == 0 ? '--' : '$_mealCalories kcal',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _InfoStat(
                        label: 'Protein',
                        value: _mealProtein == 0 ? '--' : '$_mealProtein g',
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
                Text('Meal photo', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage == null
                      ? Container(
                          width: double.infinity,
                          height: 240,
                          decoration: BoxDecoration(
                            borderRadius: AppBorderRadius.allLarge,
                            gradient: AppGradients.softCard,
                            border: Border.all(color: AppColors.borderSoft),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMint,
                                  borderRadius: AppBorderRadius.allLarge,
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 38,
                                  color: AppColors.primaryMain,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text('Upload meal photo', style: AppTextStyles.h3),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'See what you ate at a glance and keep each meal record visual.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : AppImageFrame(
                          imagePath: _selectedImage!.path,
                          height: 300,
                          borderRadius: AppBorderRadius.allLarge,
                        ),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: 'Choose Another',
                    onPressed: _pickImage,
                    isSecondary: true,
                    width: double.infinity,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This meal', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Meal type',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: MealType.values
                      .map(
                        (type) => ChoiceChip(
                          label: Text(type.label),
                          selected: _mealType == type,
                          checkmarkColor: AppColors.textInverse,
                          onSelected: (_) => setState(() => _mealType = type),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _mealController,
                  decoration: const InputDecoration(
                    labelText: 'What did you eat',
                    hintText: 'Chicken salad, rice bowl, salmon...',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _calorieController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          hintText: '520',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                          hintText: '32',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'After gym, ate out, felt full fast, keep this for lunch...',
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
                Text('Today suggestion', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                _PlanRow(
                  label: 'This meal',
                  value: _mealCalories == 0 ? 'Waiting for calories' : '$_mealCalories kcal',
                ),
                _PlanRow(
                  label: 'Protein',
                  value: _mealProtein == 0 ? 'Waiting for protein' : '$_mealProtein g',
                ),
                _PlanRow(
                  label: 'Meal type',
                  value: _mealType.label,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: AppBorderRadius.allMedium,
                  ),
                  child: Text(
                    _mealTip,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Save Meal · 12 coins',
            onPressed: _saveMeal,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snack');

  final String label;
  const MealType(this.label);
}

class _InfoStat extends StatelessWidget {
  final String label;
  final String value;

  const _InfoStat({
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

class _PlanRow extends StatelessWidget {
  final String label;
  final String value;

  const _PlanRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
