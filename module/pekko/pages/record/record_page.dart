import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/record_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/perfume_record.dart';
import '../widgets/perfume_artwork.dart';

/// Lightweight diary-style record page.
class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecordController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Wear'),
        actions: [
          Obx(
            () => TextButton(
              onPressed:
                  controller.isSaving.value ? null : controller.clearForm,
              child: const Text('Reset'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _RecordHero(),
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Bottle details'),
            const SizedBox(height: AppSpacing.sm),
            const _PerfumeSelector(),
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle('When did you wear it?'),
            const SizedBox(height: AppSpacing.sm),
            const _TimeSelector(),
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle('How did it feel?'),
            const SizedBox(height: AppSpacing.sm),
            const _MoodSelector(),
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle('Diary note'),
            const SizedBox(height: AppSpacing.sm),
            const _DiaryEditor(),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      controller.isSaving.value ? null : controller.saveRecord,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textInverse,
                            ),
                          ),
                        )
                      : const Text('Save to Diary'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.labelLarge);
  }
}

class _RecordHero extends StatelessWidget {
  const _RecordHero();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecordController>();
    return Obx(() {
      final selectedPerfume = controller.selectedPerfume.value;
      final perfumeName =
          selectedPerfume?.name ?? controller.perfumeNameController.text.trim();
      final brandName =
          selectedPerfume?.brand ?? controller.brandController.text.trim();
      return PerfumeArtwork(
        title: perfumeName.isEmpty ? 'Your Signature' : perfumeName,
        subtitle: brandName.isEmpty ? 'Private label' : brandName,
        note: controller.selectedNote.value ?? PerfumeNote.floral,
        imagePath: selectedPerfume?.imageUrl,
        height: 240,
        showNoteChip: false,
      );
    });
  }
}

class _PerfumeSelector extends StatelessWidget {
  const _PerfumeSelector();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecordController>();

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: AppTheme.cardDecoration(color: AppColors.backgroundElevated),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type the fragrance details here, or open this page from Collection to prefill them automatically.',
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller.perfumeNameController,
            decoration: const InputDecoration(
              labelText: 'Fragrance name',
              hintText: 'e.g. Blanche',
            ),
            onChanged: controller.updatePerfumeName,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller.brandController,
            decoration: const InputDecoration(
              labelText: 'Brand',
              hintText: 'e.g. Byredo',
            ),
            onChanged: controller.updateBrand,
          ),
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecordController>();

    return Obx(
      () => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: TimeOfDayType.values.map((time) {
          final isSelected = controller.selectedTime.value == time;
          return FilterChip(
            label: Text(time.displayName),
            selected: isSelected,
            onSelected: (_) => controller.selectTime(time),
            selectedColor: AppColors.primary.withValues(alpha: 0.16),
            checkmarkColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector();

  static const List<({String label, int value})> _items = [
    (label: 'Calm', value: 2),
    (label: 'Happy', value: 4),
    (label: 'Romantic', value: 5),
    (label: 'Confident', value: 1),
    (label: 'Soft', value: 3),
    (label: 'Reflective', value: 6),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecordController>();

    return Obx(
      () => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _items.map((item) {
          final isSelected = controller.moodRating.value == item.value;
          return ChoiceChip(
            label: Text(item.label),
            selected: isSelected,
            onSelected: (_) => controller.updateMoodRating(item.value),
          );
        }).toList(),
      ),
    );
  }
}

class _DiaryEditor extends StatelessWidget {
  const _DiaryEditor();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecordController>();
    return TextField(
      onChanged: controller.updateNotes,
      maxLines: 5,
      decoration: const InputDecoration(
        hintText:
            'Write a quick note about your mood, the moment, or why you chose this scent today...',
      ),
    );
  }
}
