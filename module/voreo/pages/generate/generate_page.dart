import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/generate_controller.dart';
import '../../controllers/user_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/coins_manager.dart';
import '../../theme/app_border.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../ui/dreamy_ui.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  late final GenerateController controller;
  late final UserController userController;
  late final CoinsManager coinsManager;
  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<GenerateController>()
        ? Get.find<GenerateController>()
        : Get.put(GenerateController());
    userController = Get.find<UserController>();
    coinsManager = CoinsManager.to;
    _promptController =
        TextEditingController(text: controller.editPrompt.value);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DreamyPageScaffold(
      showFloor: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DreamyTopBar(
              title: 'Create preview',
              subtitle:
                  'A calmer generation flow with bigger media and less visual noise.',
              onBack: widget.showBackButton ? AppRoutes.goBack : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Obx(() {
              final int cost = controller.coinsCost.value;
              return DreamyGlassCard(
                radius: AppBorder.radiusXLarge,
                padding: AppSpacing.allLG,
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.softPink,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$cost coins per generation',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Use one clean selfie with visible hairline and face for the best analysis result.',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            DreamyGlassCard(
              radius: AppBorder.radiusXLarge,
              padding: AppSpacing.allLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DreamySectionLabel(
                    title: 'Images first',
                    subtitle:
                        'Upload one front-facing selfie. Tap the card anytime to replace it.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(() {
                    if (controller.selectedImages.isEmpty) {
                      return InkWell(
                        onTap: _showAddOptions,
                        borderRadius:
                            BorderRadius.circular(AppBorder.radiusXLarge),
                        child: Container(
                          height: 420,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.84),
                            borderRadius:
                                BorderRadius.circular(AppBorder.radiusXLarge),
                            border: Border.all(color: AppColors.cardStroke),
                          ),
                          child: const Center(
                            child: DreamyImageFallback(
                              label: 'Tap to add your first selfie',
                              icon: Icons.add_a_photo_rounded,
                            ),
                          ),
                        ),
                      );
                    }

                    final File file = controller.selectedImages.first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: _showAddOptions,
                          borderRadius:
                              BorderRadius.circular(AppBorder.radiusXLarge),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 440),
                            child: AspectRatio(
                              aspectRatio: 0.72,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: DreamyImageCard(
                                      radius: AppBorder.radiusXLarge,
                                      child:
                                          Image.file(file, fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: DreamyIconButton(
                                      icon: Icons.close_rounded,
                                      onTap: () => controller.removeImage(0),
                                    ),
                                  ),
                                  Positioned(
                                    left: 12,
                                    right: 12,
                                    bottom: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: AppColors.cardStroke,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.touch_app_rounded,
                                            size: 18,
                                            color: AppColors.textDark,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Tap image to replace with another selfie',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Obx(
              () => DreamyPrimaryButton(
                label: controller.isGenerating.value
                    ? 'Generating...'
                    : 'Generate preview',
                onTap: controller.isGenerating.value
                    ? null
                    : () async {
                        final bool success =
                            await controller.generateHairstyle();
                        if (success &&
                            controller.generatedResult.value != null) {
                          AppRoutes.toResult(
                              controller.generatedResult.value!.id);
                        } else if (controller.errorMessage.value.isNotEmpty) {
                          Get.snackbar(
                            'Unable to generate',
                            controller.errorMessage.value,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddOptions() async {
    final bool? fromGallery = await Get.dialog<bool>(
      Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorder.borderRadiusXL,
        ),
        child: Padding(
          padding: AppSpacing.allLG,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DreamySectionLabel(
                title: 'Add a photo',
                subtitle: 'Choose your source without leaving the visual flow.',
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: DreamySecondaryButton(
                  label: 'Choose from gallery',
                  icon: Icons.photo_library_rounded,
                  onTap: () => Get.back(result: true),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: DreamySecondaryButton(
                  label: 'Take a photo',
                  icon: Icons.camera_alt_rounded,
                  onTap: () => Get.back(result: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (fromGallery == true) {
      await controller.pickImage();
    } else if (fromGallery == false) {
      await controller.takePhoto();
    }
  }
}
