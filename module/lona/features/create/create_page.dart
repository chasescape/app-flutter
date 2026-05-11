import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/create_controller.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';
import '../../data/models/composition_result.dart';

class CreatePage extends GetView<CreateController> {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? source = Get.arguments as String?;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.handleInitialSource(source);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              const AppTopBar(
                title: 'Create a new analysis',
                subtitle: 'UPLOAD A FRAME',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildImagePicker(),
              const SizedBox(height: AppSpacing.lg),
              _buildTypeSelector(),
              const SizedBox(height: AppSpacing.lg),
              _buildGoalSelector(),
              const SizedBox(height: AppSpacing.lg),
              _buildCostInfo(),
              const SizedBox(height: AppSpacing.xl),
              _buildAnalyzeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Obx(
      () => AppSurface(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: SizedBox(
          height: 380,
          child: controller.selectedImage.value == null
              ? _buildPickerPlaceholder()
              : _buildSelectedImage(),
        ),
      ),
    );
  }

  Widget _buildPickerPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            gradient: AppGradients.accent,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColors.textOnDark,
            size: 38,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Choose a photo to review', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Keep the composition front and center with a large preview.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPickerButton(
              label: 'Camera',
              icon: Icons.camera_alt_rounded,
              onTap: controller.pickImageFromCamera,
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildPickerButton(
              label: 'Gallery',
              icon: Icons.photo_library_rounded,
              onTap: controller.pickImageFromGallery,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickerButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.whitePill,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  Widget _buildSelectedImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          child: Image.file(
            controller.selectedImage.value!,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: AppRoundIconButton(
            icon: Icons.close_rounded,
            onTap: controller.reset,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return _buildChipGroup<ImageType>(
      title: 'Image type',
      values: ImageType.values,
      isSelected: (type) => controller.selectedType.value == type,
      label: (type) => type.label,
      onSelected: controller.setImageType,
    );
  }

  Widget _buildGoalSelector() {
    return _buildChipGroup<AnalysisGoal>(
      title: 'Goal',
      values: AnalysisGoal.values,
      isSelected: (goal) => controller.selectedGoal.value == goal,
      label: (goal) => goal.label,
      onSelected: controller.setAnalysisGoal,
    );
  }

  Widget _buildChipGroup<T>({
    required String title,
    required List<T> values,
    required bool Function(T value) isSelected,
    required String Function(T value) label,
    required void Function(T value) onSelected,
  }) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: values.map((value) {
                final selected = isSelected(value);
                return FilterChip(
                  label: Text(label(value)),
                  selected: selected,
                  onSelected: (_) => onSelected(value),
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  selectedColor: AppColors.secondaryMain,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: selected ? AppColors.textOnDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  checkmarkColor: AppColors.textOnDark,
                  side: BorderSide(
                    color: selected
                        ? AppColors.secondaryMain
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostInfo() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.freeCreditsNotifier,
      builder: (context, freeCredits, _) {
        final hasFreeCredit = freeCredits > 0;
        final costPerAnalysis = controller.costPerAnalysis;

        return AppSurface(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (hasFreeCredit
                        ? AppColors.semanticSuccess
                        : AppColors.secondaryMain)
                    .withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFreeCredit
                    ? Icons.card_giftcard_rounded
                    : Icons.auto_awesome_rounded,
                color: hasFreeCredit
                    ? AppColors.semanticSuccess
                    : AppColors.secondaryMain,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFreeCredit ? 'Free credit available' : 'Analysis cost',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasFreeCredit
                        ? '$freeCredits free credits left'
                        : '$costPerAnalysis coins',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      },
    );
  }

  Widget _buildAnalyzeButton() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.coinsNotifier,
      builder: (context, coins, _) => ValueListenableBuilder<int>(
        valueListenable: controller.freeCreditsNotifier,
        builder: (context, freeCredits, __) {
          final costPerAnalysis = controller.costPerAnalysis;
          final canAnalyze = freeCredits > 0 || coins >= costPerAnalysis;

          return Obx(
            () => SizedBox(
              width: double.infinity,
              height: 58,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.whitePill,
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
                child: ElevatedButton(
                  onPressed: canAnalyze && !controller.isAnalyzing.value
                      ? controller.analyzeComposition
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: controller.isAnalyzing.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation(AppColors.secondaryMain),
                          ),
                        )
                      : Text(canAnalyze ? 'Analyze composition' : 'Get more coins'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
