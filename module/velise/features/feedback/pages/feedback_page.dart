import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/velise_ui.dart';
import '../controllers/feedback_controller.dart';

class FeedbackPage extends GetView<FeedbackController> {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VeliseScaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              VeliseSurfaceCard(
                light: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VeliseSectionHeading(
                      title: 'What should improve?',
                      subtitle: 'Type a note or dictate it. Voice input appends directly into the same field.',
                      light: true,
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Stack(
                        children: [
                          TextField(
                            controller: controller.textController,
                            maxLines: 10,
                            textInputAction: TextInputAction.newline,
                            cursorColor: AppColors.primaryMain,
                            style: AppTextStyles.surfaceBodyStyle.copyWith(
                              color: AppColors.textOnSurface,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Share UI polish ideas, friction points, or feature requests...',
                              hintStyle: AppTextStyles.surfaceBodyStyle.copyWith(
                                color: AppColors.textOnSurfaceSoft,
                              ),
                              filled: true,
                              fillColor:
                                  AppColors.secondaryLight.withValues(alpha: 0.72),
                              contentPadding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                72,
                                72,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: controller.toggleListening,
                                borderRadius: BorderRadius.circular(999),
                                child: Ink(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: controller.isListening.value
                                        ? AppColors.error
                                        : AppColors.primaryMain,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Icon(
                                    controller.isListening.value
                                        ? Icons.stop_rounded
                                        : Icons.mic_none_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Obx(
                () => VelisePrimaryButton(
                  label: 'Submit Feedback',
                  icon: Icons.arrow_upward_rounded,
                  isLoading: controller.isSubmitting.value,
                  onTap: controller.canSubmit ? controller.submitFeedback : null,
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                'feedback',
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
            child: Obx(
              () => VelisePill(
                label: controller.isListening.value ? 'Listening' : 'Voice ready',
                icon: controller.isListening.value
                    ? Icons.mic_rounded
                    : Icons.graphic_eq_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
