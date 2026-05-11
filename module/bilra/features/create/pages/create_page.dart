import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bilra/bilra/controllers/create_controller.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/widgets/bilra_ui.dart';
import 'package:bilra/gen_a/A.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  late final CreateController controller;
  Worker? _promptWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CreateController>()
        ? Get.find<CreateController>()
        : Get.put(CreateController());
    _promptWorker = ever<CreatePromptData?>(controller.prompt, (prompt) {
      if (prompt == null || !mounted) return;
      _showPromptSheet(prompt);
    });
  }

  @override
  void dispose() {
    _promptWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BilraBackdrop(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              BilraTopBar(
                title: 'Create a look',
                subtitle: 'Upload and analyze',
                leading: BilraIconChipButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => AppRoutes.pop(context),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const _CreateIntroCard(),
              const SizedBox(height: AppSpacing.md),
              _TypeSelector(controller: controller),
              const SizedBox(height: AppSpacing.md),
              _UploadSection(controller: controller),
              const SizedBox(height: AppSpacing.md),
              BilraGlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.tips_and_updates_outlined,
                        color: AppColors.primaryMain,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Text(
                        'Use a front-facing photo with clean light for the most refined result.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              BilraGlassCard(
                color: AppColors.surfaceTertiary.withValues(alpha: 0.92),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: AppColors.primaryMain),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Each analysis costs ${controller.analysisCost} coins',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(() {
                return BilraPrimaryButton(
                  label: 'Get my recommendation',
                  icon: Icons.auto_awesome_rounded,
                  expanded: true,
                  loading: controller.isLoading.value,
                  onTap: controller.canPublish && !controller.isLoading.value
                      ? () async {
                          final success = await controller.publish();
                          if (!context.mounted || !success) return;
                          AppRoutes.toDetail(context, 0);
                        }
                      : null,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPromptSheet(CreatePromptData prompt) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (sheetContext) {
        final actionEnabled = prompt.opensCoinStore;
        if (!actionEnabled) {
          Future<void>.delayed(const Duration(milliseconds: 1800), () {
            if (!sheetContext.mounted) return;
            Navigator.of(sheetContext).pop();
          });
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: actionEnabled
                    ? () {
                        Navigator.of(sheetContext).pop();
                        AppRoutes.pushNamed(context, AppRoutes.coinStore);
                      }
                    : null,
                child: BilraGlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  radius: 30,
                  color: const Color(0xFFFFEEF1),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDDE3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.semanticError,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notice',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prompt.message,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.semanticError,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (prompt.actionLabel != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          prompt.actionLabel!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    controller.clearPrompt();
  }
}

class _CreateIntroCard extends StatelessWidget {
  const _CreateIntroCard();

  @override
  Widget build(BuildContext context) {
    return BilraGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BilraPill(
            label: 'Image-led workflow',
            color: AppColors.surfaceTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Lead with the image, then let the text stay light and supportive.',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We will read the visual tone, suggest a polished makeup direction, and keep the result clean enough to browse like a moodboard.',
            style: AppTextStyles.caption.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 112,
            child: Row(
              children: [
                Expanded(
                  child: BilraImageFrame(
                    imagePath: A.assets_bilra_3,
                    fallbackIndex: 2,
                    preferIndexedGalleryForBundledAssets: true,
                    borderRadius: 22,
                    height: double.infinity,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: BilraImageFrame(
                    imagePath: A.assets_bilra_5,
                    fallbackIndex: 4,
                    preferIndexedGalleryForBundledAssets: true,
                    borderRadius: 22,
                    height: double.infinity,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: BilraImageFrame(
                    imagePath: A.assets_bilra_9,
                    fallbackIndex: 8,
                    preferIndexedGalleryForBundledAssets: true,
                    borderRadius: 22,
                    height: double.infinity,
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

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.controller,
  });

  final CreateController controller;

  @override
  Widget build(BuildContext context) {
    return BilraGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Creative mode', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Obx(() {
            return Row(
              children: PostType.values.map((type) {
                final isSelected = controller.selectedType.value == type;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: type == PostType.values.last ? 0 : AppSpacing.sm,
                    ),
                    child: GestureDetector(
                      onTap: () => controller.selectPostType(type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryMain
                              : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _labelFor(type),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? AppColors.textInverse
                                : AppColors.primaryMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  String _labelFor(PostType type) {
    switch (type) {
      case PostType.look:
        return 'Look';
      case PostType.tutorial:
        return 'Tutorial';
      case PostType.review:
        return 'Review';
    }
  }
}

class _UploadSection extends StatelessWidget {
  const _UploadSection({
    required this.controller,
  });

  final CreateController controller;

  @override
  Widget build(BuildContext context) {
    return BilraGlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your photo', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Obx(() {
            final hasImage = controller.selectedImagePath.value.isNotEmpty;
            return GestureDetector(
              onTap: hasImage ? null : () => _showImageSourceDialog(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: double.infinity,
                height: 420,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color:
                        hasImage ? Colors.transparent : AppColors.outlineStrong,
                    width: 1.5,
                  ),
                ),
                child: hasImage
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: BilraImageFrame(
                              imagePath: controller.selectedImagePath.value,
                              borderRadius: 26,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: BilraIconChipButton(
                              icon: Icons.close_rounded,
                              onTap: controller.clearImage,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primaryMain,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.add_a_photo_rounded,
                              color: AppColors.textInverse,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Tap to upload your selfie',
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Gallery or camera both work',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: BilraGlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              radius: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choose photo source', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.md),
                  _SourceOption(
                    icon: Icons.photo_library_outlined,
                    title: 'Photo Library',
                    subtitle: 'Use image_picker to choose from your gallery',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await controller.pickImage();
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SourceOption(
                    icon: Icons.photo_camera_outlined,
                    title: 'Camera',
                    subtitle: 'Use image_picker to capture a new photo',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await controller.takePhoto();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surfacePrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primaryMain),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.small),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
