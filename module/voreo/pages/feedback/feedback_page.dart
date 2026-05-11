import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../controllers/feedback_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_border.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../ui/dreamy_ui.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FeedbackController controller = Get.put(FeedbackController());
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _textController = TextEditingController();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speechToText.initialize();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      return;
    }

    final bool available = await _speechToText.initialize();
    if (!available) {
      return;
    }

    setState(() => _isListening = true);
    _speechToText.listen(
      onResult: (result) {
        _textController.text = result.recognizedWords;
        _textController.selection = TextSelection.collapsed(
          offset: _textController.text.length,
        );
        controller.onFeedbackChanged(result.recognizedWords);
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _speechToText.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DreamyPageScaffold(
      showFloor: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DreamyCenteredHeader(
              title: 'Feedback',
              onBack: AppRoutes.goBack,
            ),
            const SizedBox(height: AppSpacing.md),
            DreamyGlassCard(
              radius: AppBorder.radiusXLarge,
              padding: AppSpacing.allLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DreamySectionLabel(
                    title: 'Your note',
                    subtitle:
                        'Typed or spoken. Keep it short, clear, and honest.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _textController,
                    onChanged: controller.onFeedbackChanged,
                    maxLines: 10,
                    maxLength: controller.maxChars,
                    decoration: const InputDecoration(
                      hintText: 'What should we improve next?',
                    ),
                  ),
                  Row(
                    children: [
                      Obx(
                        () => DreamyStatPill(
                          label:
                              '${controller.charCount.value}/${controller.maxChars}',
                          icon: Icons.edit_note_rounded,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      DreamySecondaryButton(
                        label: _isListening ? 'Listening...' : 'Use voice',
                        icon: _isListening
                            ? Icons.mic_rounded
                            : Icons.mic_none_rounded,
                        onTap: _toggleListening,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DreamyGlassCard(
              radius: AppBorder.radiusXLarge,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.softPink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.favorite_border_rounded,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Voice transcription is ideal for quick bug reports or design impressions.',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textGrey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => DreamyPrimaryButton(
                  label: controller.isSubmitting.value
                      ? 'Submitting...'
                      : 'Submit feedback',
                  onTap: controller.isSubmitting.value
                      ? null
                      : () async {
                          final bool success =
                              await controller.submitFeedback();
                          if (success && mounted) {
                            _textController.clear();
                            if (_isListening) {
                              await _speechToText.stop();
                              setState(() => _isListening = false);
                            }
                            AppRoutes.goBack();
                            Future<void>.delayed(
                              const Duration(milliseconds: 150),
                              () {
                                Get.snackbar(
                                  'Submitted',
                                  'Your feedback was sent successfully.',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            );
                          }
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
