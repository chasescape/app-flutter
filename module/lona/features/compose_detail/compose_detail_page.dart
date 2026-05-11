import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/compose_detail_controller.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';

class ComposeDetailPage extends GetView<ComposeDetailController> {
  const ComposeDetailPage({super.key});

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
              AppTopBar(
                title: controller.scene.title,
                subtitle: 'DETAIL PREVIEW',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildHeroImage(),
              const SizedBox(height: AppSpacing.lg),
              _buildIntroCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildOldImagesSection(),
              const SizedBox(height: AppSpacing.lg),
              _buildCopySection(
                title: 'How it works',
                content: controller.scene.howItWorks,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildCopySection(
                title: 'Why this works better',
                content: controller.scene.whyBetter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
      child: AspectRatio(
        aspectRatio: 0.84,
        child: Image.asset(
          controller.scene.assetImg,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(gradient: AppGradients.accent),
              child: const Icon(
                Icons.image_outlined,
                size: 52,
                color: AppColors.textOnDark,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppTag(label: 'AFTER RESULT'),
          const SizedBox(height: AppSpacing.md),
          Text(controller.scene.subtitle, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildOldImagesSection() {
    if (controller.scene.oldAssetImgs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(
          title: 'Before references',
          subtitle: 'Kept below the main image so nothing blocks the hero shot.',
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.scene.oldAssetImgs.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final oldImg = controller.scene.oldAssetImgs[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    oldImg,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(gradient: AppGradients.surfaceWarm),
                        child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCopySection({
    required String title,
    required String content,
  }) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Text(content, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
