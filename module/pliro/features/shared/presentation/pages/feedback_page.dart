import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/features/shared/presentation/controllers/feedback_controller.dart';
import 'package:pliro/pliro/shared/widgets/common_button.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';

/// Feedback page - user feedback and support.
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FeedbackController());

    return DreamScaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: GetBuilder<FeedbackController>(
        builder: (ctrl) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMD,
              AppTheme.spacingSM,
              AppTheme.spacingMD,
              AppTheme.spacingXXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeCard(ctrl),
                const SizedBox(height: AppTheme.spacingLG),
                _buildFeedbackInput(ctrl),
                const SizedBox(height: AppTheme.spacingXXL),
                NeonButton(
                  text: 'Submit Feedback',
                  icon: Icons.send_outlined,
                  onPressed: ctrl.canSubmit ? ctrl.onSubmit : null,
                  isLoading: ctrl.isSubmitting,
                  width: double.infinity,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeCard(FeedbackController ctrl) {
    return SizedBox(
      width: double.infinity,
      child: NeonCard(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feedback type', style: AppTextStyles.bodySemiBold),
            const SizedBox(height: AppTheme.spacingMD),
            Wrap(
              spacing: AppTheme.spacingSM,
              runSpacing: AppTheme.spacingSM,
              children: FeedbackType.values.map((type) {
                return DreamChip(
                  label: _getFeedbackTypeLabel(type),
                  selected: ctrl.selectedType == type,
                  onTap: () => ctrl.selectType(type),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackInput(FeedbackController ctrl) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your feedback',
                  style: AppTextStyles.bodySemiBold,
                ),
              ),
              Material(
                color: ctrl.isListening
                    ? AppColors.roseDeep
                    : AppColors.blushMist.withOpacity(0.78),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: InkWell(
                  onTap: ctrl.toggleVoiceInput,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      ctrl.isListening ? Icons.mic : Icons.mic_none,
                      color: ctrl.isListening
                          ? AppColors.textInverse
                          : AppColors.roseDeep,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSM),
          TextField(
            controller: ctrl.contentController,
            maxLines: 6,
            textInputAction: TextInputAction.done,
            cursorColor: AppColors.roseDeep,
            decoration: const InputDecoration(
              hintText: 'Tell us what you think...',
            ),
            onChanged: (_) => ctrl.update(),
          ),
          if (ctrl.isListening) ...[
            const SizedBox(height: AppTheme.spacingSM),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Text(
                  'Listening...',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.roseDeep,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getFeedbackTypeLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return 'Bug';
      case FeedbackType.feature:
        return 'Feature';
      case FeedbackType.general:
        return 'General';
      case FeedbackType.other:
        return 'Other';
    }
  }
}

/// Feedback type enum.
enum FeedbackType { bug, feature, general, other }
