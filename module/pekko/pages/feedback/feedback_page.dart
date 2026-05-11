import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/main_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_theme.dart';

/// Feedback page for user feedback with voice input support
class FeedbackPage extends StatelessWidget {
  FeedbackPage({super.key});

  final controller = Get.put(_FeedbackController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        controller.exitFeedback();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: controller.exitFeedback,
          ),
          title: const Text('Feedback'),
        ),
        body: SingleChildScrollView(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feedback type
              Text(
                'Feedback Type',
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Obx(
                () => Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    'Bug',
                    'Feature',
                    'General',
                    'Other',
                  ].map((type) {
                    final isSelected = controller.feedbackType.value == type;
                    return ChoiceChip(
                      label: Text(
                        type,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.textInverse
                              : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        controller.feedbackType.value = type;
                      },
                      selectedColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Message input with voice button
              Text(
                'Your Message',
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: AppSpacing.paddingMD,
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: controller.messageController,
                      maxLines: 6,
                      maxLength: 500,
                      textInputAction: TextInputAction.done,
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Tell us what you think...',
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Voice input button
                    Obx(() => _VoiceInputButton(
                      isListening: controller.isListening.value,
                      isInitializing: controller.isInitializing.value,
                      onTap: controller.toggleVoiceInput,
                    )),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Obx(
                () => Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${controller.messageCount.value}/500',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Submit button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value ||
                            !controller.canSubmit.value
                        ? null
                        : controller.submitFeedback,
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textInverse,
                              ),
                            ),
                          )
                        : const Text('Submit Feedback'),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Voice input button widget
class _VoiceInputButton extends StatelessWidget {
  final bool isListening;
  final bool isInitializing;
  final VoidCallback onTap;

  const _VoiceInputButton({
    required this.isListening,
    required this.isInitializing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isInitializing ? null : onTap,
        borderRadius: AppBorderRadius.allMedium,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isListening
                ? AppColors.error.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: AppBorderRadius.allMedium,
            border: Border.all(
              color: isListening ? AppColors.error : AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInitializing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
              else
                Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: isListening ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isInitializing
                    ? 'Initializing...'
                    : isListening
                        ? 'Stop Listening'
                        : 'Voice Input',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isListening ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feedback controller with voice input support
class _FeedbackController extends GetxController {
  final MainController _mainController = Get.find<MainController>();
  final feedbackType = ''.obs;
  final messageController = TextEditingController();
  final isSubmitting = false.obs;
  final messageCount = 0.obs;
  final canSubmit = false.obs;

  // Speech to text - lazy initialization
  SpeechToText? _speechToText;
  final isListening = false.obs;
  final isInitializing = false.obs;

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(() {
      messageCount.value = messageController.text.length;
      _updateCanSubmit();
    });
    ever(feedbackType, (_) => _updateCanSubmit());
  }

  @override
  void onClose() {
    messageController.dispose();
    // Stop listening and release speech to text resources
    if (_speechToText != null) {
      if (isListening.value) {
        _speechToText!.stop();
      }
      _speechToText = null;
    }
    super.onClose();
  }

  /// Toggle voice input - requests permissions and initializes speech recognition on first tap
  Future<void> toggleVoiceInput() async {
    // If currently listening, stop
    if (isListening.value) {
      await _stopListening();
      return;
    }

    // Prevent duplicate initialization
    if (isInitializing.value) return;

    // Lazy initialize speech to text on first tap
    if (_speechToText == null) {
      await _initializeSpeechToText();
      return;
    }

    // Start listening
    await _startListening();
  }

  /// Initialize speech to text (called on first tap)
  Future<void> _initializeSpeechToText() async {
    isInitializing.value = true;

    try {
      // Request permissions first
      final micStatus = await Permission.microphone.request();
      final speechStatus = await Permission.speech.request();

      if (!micStatus.isGranted || !speechStatus.isGranted) {
        // Show permission denied message
        Get.snackbar(
          'Permission Required',
          'Microphone and speech recognition permissions are required for voice input.',
          backgroundColor: AppColors.error,
          colorText: AppColors.textInverse,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Initialize speech to text
      _speechToText = SpeechToText();
      final hasSpeech = await _speechToText!.initialize(
        onError: (error) {
          Get.snackbar(
            'Speech Recognition Error',
            'Failed to recognize speech. Please try again.',
            backgroundColor: AppColors.error,
            colorText: AppColors.textInverse,
          );
          isListening.value = false;
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
      );

      if (!hasSpeech) {
        Get.snackbar(
          'Speech Recognition Unavailable',
          'Speech recognition is not available on this device.',
          backgroundColor: AppColors.error,
          colorText: AppColors.textInverse,
        );
        return;
      }

      // Start listening after successful initialization
      await _startListening();
    } catch (e) {
      Get.snackbar(
        'Initialization Failed',
        'Failed to initialize speech recognition. Please try again.',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
    } finally {
      isInitializing.value = false;
    }
  }

  /// Start listening for speech input
  Future<void> _startListening() async {
    if (_speechToText == null) return;

    try {
      await _speechToText!.listen(
        onResult: (result) {
          // Update text field with recognized words
          final recognizedWords = result.recognizedWords;
          if (recognizedWords.isNotEmpty) {
            // Append or replace text based on final result
            if (result.finalResult) {
              // Get current text and cursor position
              final currentText = messageController.text;
              final selection = messageController.selection;
              final cursorPosition = selection.baseOffset >= 0
                  ? selection.baseOffset
                  : currentText.length;

              // Insert recognized words at cursor position
              final newText = currentText.substring(0, cursorPosition) +
                  recognizedWords +
                  currentText.substring(cursorPosition);

              messageController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(
                  offset: cursorPosition + recognizedWords.length,
                ),
              );
            }
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
      isListening.value = true;
    } catch (e) {
      Get.snackbar(
        'Listening Failed',
        'Failed to start listening. Please try again.',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
    }
  }

  /// Stop listening
  Future<void> _stopListening() async {
    if (_speechToText == null) return;
    await _speechToText!.stop();
    isListening.value = false;
  }

  Future<void> submitFeedback() async {
    try {
      isSubmitting.value = true;

      // Stop voice input if active
      if (isListening.value) {
        await _stopListening();
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.allLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Thank You!',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your feedback has been submitted',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: completeFeedback,
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit feedback',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _updateCanSubmit() {
    canSubmit.value = messageController.text.trim().isNotEmpty;
  }

  Future<void> completeFeedback() async {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    await exitFeedback();
  }

  Future<void> exitFeedback() async {
    if (isListening.value) {
      await _stopListening();
    }
    _mainController.changeTab(0);
    Get.offAllNamed(AppRoutes.main);
  }
}
