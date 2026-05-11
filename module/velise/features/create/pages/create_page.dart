import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/velise_ui.dart';
import '../../../services/coins/coins_manager.dart';
import '../controllers/create_controller.dart';

class CreatePage extends GetView<CreateController> {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return VeliseScaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(),
                const SizedBox(height: 24),
                _buildImageStage(),
                const SizedBox(height: 18),
                _buildPrimaryActionButton(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton() {
    return VelisePrimaryButton(
      label: controller.primaryButtonLabel,
      icon: controller.primaryButtonIcon,
      isLoading: controller.isGenerating.value,
      onTap: controller.primaryButtonAction,
    );
  }

  Widget _buildTopRow() {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: VeliseActionButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: Get.back,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 96),
              child: Text(
                'generate',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h3Style.copyWith(
                  fontWeight: AppTextStyles.semibold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<int>(
              valueListenable: CoinsManager.instance,
              builder: (context, balance, child) {
                return VelisePill(
                  label: '$balance coins',
                  icon: Icons.auto_awesome_rounded,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageStage() {
    final hasImage = controller.imagePath.value.isNotEmpty;
    return VeliseSurfaceCard(
      light: true,
      padding: const EdgeInsets.all(14),
      onTap: controller.pickImage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VeliseSectionHeading(
            title: 'Source Photo',
            subtitle:
                'Pick one image, then tap the button below. Velise will generate the page and open it for you.',
            light: true,
          ),
          const SizedBox(height: 16),
          if (hasImage)
            VeliseAdaptiveImage(
              imagePath: controller.imagePath.value,
              width: double.infinity,
              height: 400,
              borderRadius: BorderRadius.circular(30),
            )
          else
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                gradient: AppColors.lavenderGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_camera_back_outlined,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Tap to choose a photo',
                      textAlign: TextAlign.center,
                      style:
                          AppTextStyles.h3Style.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Then tap Generate to open the finished page.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.captionStyle.copyWith(
                          color: Colors.white.withValues(alpha: 0.88)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
