import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import '../../controllers/collection_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/perfume.dart';
import '../../data/models/perfume_record.dart';
import '../widgets/perfume_artwork.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CollectionController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.backgroundPrimary,
            title: Text('Collection'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AddBottleCard(onTap: () => _showAddBottleSheet(context)),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Your Bottles', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.md),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final perfumes = controller.filteredPerfumes;
                    if (perfumes.isEmpty) {
                      return _EmptyCollection(
                        onTap: () => _showAddBottleSheet(context),
                      );
                    }

                    return Column(
                      children: perfumes.map((perfume) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _PerfumeCollectionCard(
                            perfume: perfume,
                            onRecord: () => Get.toNamed(
                              AppRoutes.record,
                              arguments: {
                                'perfumeName': perfume.name,
                                'brand': perfume.brand,
                                'imageUrl': perfume.imageUrl,
                                'note': perfume.primaryNote,
                              },
                            ),
                            onDelete: () =>
                                controller.deletePerfume(perfume.id),
                          ),
                        );
                      }).toList(),
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

  void _showAddBottleSheet(BuildContext context) {
    final controller = Get.find<CollectionController>();
    controller.clearForm();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.large),
            topRight: Radius.circular(AppBorderRadius.large),
          ),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add a Bottle', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.md),
                    Obx(
                      () => InkWell(
                        onTap: controller.pickCollectionImage,
                        borderRadius: AppBorderRadius.allLarge,
                        child: Container(
                          width: double.infinity,
                          height: 156,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundElevated,
                            borderRadius: AppBorderRadius.allLarge,
                            border: Border.all(
                              color:
                                  AppColors.accentDark.withValues(alpha: 0.3),
                            ),
                          ),
                          child: controller.selectedImagePath.value == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 28,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Upload bottle photo',
                                      style: AppTextStyles.h3.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Use your own image for the collection card.',
                                      style: AppTextStyles.small,
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: AppBorderRadius.allLarge,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(
                                          controller.selectedImagePath.value!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: AppSpacing.sm,
                                        bottom: AppSpacing.sm,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.45,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'Change photo',
                                            style: AppTextStyles.small.copyWith(
                                              color: AppColors.textInverse,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Fragrance name',
                        hintText: 'e.g. Blanche',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: controller.brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        hintText: 'e.g. Byredo',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Obx(
                      () => Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: PerfumeNote.values.map((note) {
                          return ChoiceChip(
                            label: Text(note.displayName),
                            selected: controller.selectedNote.value == note,
                            onSelected: (_) =>
                                controller.selectedNote.value = note,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: controller.descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText:
                            'Why you keep this bottle, when you reach for it...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.savePerfumeFromForm,
                        child: const Text('Save to Collection'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _AddBottleCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddBottleCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allLarge,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: AppTheme.cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppBorderRadius.allMedium,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add a new fragrance', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Build your bottle library first, then record wear from what you already own.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
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

class _PerfumeCollectionCard extends StatelessWidget {
  final Perfume perfume;
  final VoidCallback onRecord;
  final VoidCallback onDelete;

  const _PerfumeCollectionCard({
    required this.perfume,
    required this.onRecord,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PerfumeArtwork(
            title: perfume.name,
            subtitle: perfume.brand,
            note: perfume.primaryNote,
            height: 220,
            imagePath: perfume.imageUrl,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(perfume.name, style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      perfume.brand,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Tag(text: perfume.primaryNote.displayName),
              _Tag(text: 'Owned bottle'),
            ],
          ),
          if (perfume.description?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              perfume.description!,
              style: AppTextStyles.caption,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRecord,
                  icon: const Icon(Icons.add),
                  label: const Text('Log Wear'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMedium,
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyCollection({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.local_florist_outlined,
            size: 54,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No bottles yet',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add the fragrances you own so your diary can stay fast and organized.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: onTap,
            child: const Text('Add first bottle'),
          ),
        ],
      ),
    );
  }
}
