import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/common/soft_ui.dart';

class FeedbackController extends GetxController {
  final RxString feedback = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isListening = false.obs;
  final RxString selectedType = 'Bug report'.obs;
  final TextEditingController inputController = TextEditingController();
  final List<String> feedbackTypes = const [
    'Bug report',
    'Feature idea',
    'Content issue',
    'Account',
  ];

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (!_speechEnabled) {
      Get.snackbar(
          'Notice', 'Speech recognition is not available on this device');
    }
  }

  void submit() {
    if (feedback.value.trim().isEmpty) {
      Get.snackbar('Notice', 'Please enter your feedback');
      return;
    }

    isSubmitting.value = true;

    Future.delayed(const Duration(seconds: 1), () {
      isSubmitting.value = false;
      Get.back();
      Get.snackbar('Thank you', 'Your feedback has been submitted.');
      reset();
    });
  }

  void startListening() async {
    if (!_speechEnabled) {
      Get.snackbar('Notice', 'Speech recognition is not available');
      return;
    }

    if (isListening.value) {
      await _speechToText.stop();
      isListening.value = false;
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        feedback.value = result.recognizedWords;
        inputController.value = TextEditingValue(
          text: feedback.value,
          selection: TextSelection.collapsed(offset: feedback.value.length),
        );
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
    );
    isListening.value = true;
  }

  void updateFeedback(String value) {
    feedback.value = value;
  }

  void selectType(String value) {
    selectedType.value = value;
  }

  void reset() {
    feedback.value = '';
    inputController.clear();
    isListening.value = false;
  }

  int get characterCount => feedback.value.length;
}

class FeedbackPage extends GetView<FeedbackController> {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FeedbackController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: NeniaBackdrop(
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          NeniaInlineHeader(
                            title: 'Feedback',
                            subtitle:
                                'Tell us where the polish should go next.',
                            onBack: Get.back,
                          ),
                          const SizedBox(height: 18),
                          _buildTypeSelector(),
                          const SizedBox(height: 14),
                          NeniaSurface(
                            radius: 32,
                            gradient: AppColors.spotlightGradient,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.82),
                                    borderRadius: AppBorderRadius.allLg,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  child: TextField(
                                    controller: controller.inputController,
                                    onChanged: controller.updateFeedback,
                                    maxLines: 10,
                                    enabled: !controller.isSubmitting.value,
                                    style: AppTextStyles.body,
                                    cursorColor: AppColors.secondaryMain,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          'What feels great already, and what should become more refined?',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text(
                                      '${controller.characterCount} characters',
                                      style: AppTextStyles.small,
                                    ),
                                    const Spacer(),
                                    NeniaSecondaryButton(
                                      label: controller.isListening.value
                                          ? 'Stop voice'
                                          : 'Voice input',
                                      icon: controller.isListening.value
                                          ? Icons.mic_rounded
                                          : Icons.mic_none_rounded,
                                      onPressed: controller.isSubmitting.value
                                          ? null
                                          : controller.startListening,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          NeniaPrimaryButton(
                            label: controller.isSubmitting.value
                                ? 'Submitting...'
                                : 'Submit feedback',
                            trailingIcon: controller.isSubmitting.value
                                ? Icons.hourglass_top_rounded
                                : Icons.send_rounded,
                            onPressed: controller.isSubmitting.value
                                ? null
                                : controller.submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SizedBox(
      width: double.infinity,
      child: NeniaSurface(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        radius: 28,
        gradient: AppColors.cardGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feedback type',
              style: AppTextStyles.small.copyWith(
                color: AppColors.secondaryDark,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.feedbackTypes.map((type) {
                final selected = controller.selectedType.value == type;
                return GestureDetector(
                  onTap: () => controller.selectType(type),
                  child: AnimatedContainer(
                    duration: AppTheme.animationFast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryMain
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryMain
                            : AppColors.lineSoft,
                      ),
                    ),
                    child: Text(
                      type,
                      style: AppTextStyles.small.copyWith(
                        color: selected
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
