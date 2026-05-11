import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/feedback_controller.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';

class FeedbackPage extends GetView<FeedbackController> {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: AppBackdrop(
          child: SafeArea(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              children: [
                const AppTopBar(
                  title: 'Share feedback',
                  subtitle: 'HELP US POLISH THE EXPERIENCE',
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildTypeSelector(),
                const SizedBox(height: AppSpacing.lg),
                _buildMessageInput(),
                const SizedBox(height: AppSpacing.lg),
                _buildVoiceStatus(),
                const SizedBox(height: AppSpacing.xl),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Feedback type', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: controller.feedbackTypes.map((type) {
                final isSelected = controller.selectedType.value == type.id;
                return FilterChip(
                  label: Text(type.label),
                  selected: isSelected,
                  onSelected: (_) => controller.selectType(type.id),
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  selectedColor: AppColors.secondaryMain,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  checkmarkColor: AppColors.textOnDark,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your message', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller.messageController,
            maxLines: 7,
            onChanged: controller.setMessage,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            textInputAction: TextInputAction.done,
            style: AppTextStyles.body,
            cursorColor: AppColors.secondaryMain,
            decoration: const InputDecoration(
              hintText: 'Tell us what feels great, confusing, or missing...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceStatus() {
    return Obx(
      () => AppSurface(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Voice input', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    controller.isListening.value
                        ? 'Listening now...'
                        : controller.isInitializing.value
                            ? 'Preparing microphone...'
                            : 'Tap the button to dictate feedback.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            AppRoundIconButton(
              icon: controller.isListening.value ? Icons.mic : Icons.mic_none_rounded,
              onTap: controller.isInitializing.value ? () {} : controller.toggleListening,
              iconColor: controller.isListening.value
                  ? AppColors.semanticSuccess
                  : AppColors.secondaryMain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
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
            onPressed: controller.isSubmitting.value ? null : controller.submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(AppColors.secondaryMain),
                    ),
                  )
                : const Text('Submit feedback'),
          ),
        ),
      ),
    );
  }
}
