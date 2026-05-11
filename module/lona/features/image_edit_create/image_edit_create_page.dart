import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/image_edit_create_controller.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';

class ImageEditCreatePage extends GetView<ImageEditCreateController> {
  const ImageEditCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                title: 'Create',
                subtitle: 'IMAGE TO IMAGE',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildImagePicker(),
              const SizedBox(height: AppSpacing.lg),
              _buildCostInfo(),
              const SizedBox(height: AppSpacing.xl),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Obx(
      () => AppSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text('Source image', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: controller.selectedImages.isEmpty
                  ? _buildPickerPlaceholder()
                  : _buildSelectedImagePanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerPlaceholder() {
    return Container(
      key: const ValueKey('picker_placeholder'),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 420),
      decoration: BoxDecoration(
        gradient: AppGradients.surfaceWarm,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              gradient: AppGradients.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_rounded,
              color: AppColors.textOnDark,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Upload one source photo',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'We use a single image for each remix.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pillAction(
                'Camera',
                Icons.camera_alt_rounded,
                controller.pickImageFromCamera,
              ),
              const SizedBox(width: AppSpacing.sm),
              _pillAction(
                'Gallery',
                Icons.photo_library_rounded,
                controller.pickImageFromGallery,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillAction(String label, IconData icon, VoidCallback onTap) {
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

  Widget _buildSelectedImagePanel() {
    return Column(
      key: const ValueKey('selected_image_panel'),
      children: [
        SizedBox(
          width: double.infinity,
          height: 420,
          child: _buildImageThumbnail(0),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _pillAction(
                'Camera',
                Icons.camera_alt_rounded,
                controller.pickImageFromCamera,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _pillAction(
                'Gallery',
                Icons.photo_library_rounded,
                controller.pickImageFromGallery,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            child: Image.file(
              controller.selectedImages[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: AppRoundIconButton(
            icon: Icons.close_rounded,
            onTap: () => controller.removeImage(index),
          ),
        ),
      ],
    );
  }

  Widget _buildCostInfo() {
    return AppSurface(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryMain.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.secondaryMain,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Cost: ${ImageEditCreateController.costPerCreation} coins per creation',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
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
            onPressed: controller.isProcessing.value ? null : controller.createImageEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: controller.isProcessing.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(AppColors.secondaryMain),
                    ),
                  )
                : const Text('Create image'),
          ),
        ),
      ),
    );
  }
}
