import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../routes/app_pages.dart';

/// Feedback Controller
/// Manages feedback page state and speech to text functionality
class FeedbackController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final SpeechToText speechToText = SpeechToText();
  final RxBool isListening = false.obs;
  final RxBool isSpeechInitialized = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString draftText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_syncDraftText);
    _initSpeech();
  }

  @override
  void onClose() {
    textController.removeListener(_syncDraftText);
    textController.dispose();
    if (isListening.value) {
      speechToText.stop();
    }
    super.onClose();
  }

  /// Initialize speech to text
  Future<void> _initSpeech() async {
    try {
      final isAvailable = await speechToText.initialize(
        onError: (error) {
          isListening.value = false;
          Get.snackbar(
            'Speech Recognition Error',
            error.errorMsg,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        onStatus: (status) {
          if (status == 'listening') {
            isListening.value = true;
          } else if (status == 'notListening' || status == 'done') {
            isListening.value = false;
          }
        },
      );
      isSpeechInitialized.value = isAvailable;
    } catch (e) {
      isSpeechInitialized.value = false;
    }
  }

  /// Toggle speech listening
  Future<void> toggleListening() async {
    if (!isSpeechInitialized.value) {
      Get.snackbar(
        'Not Available',
        'Speech recognition is not available on this device',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isListening.value) {
      await speechToText.stop();
      isListening.value = false;
    } else {
      final isAvailable = await speechToText.listen(
        onResult: (result) {
          textController.text = result.recognizedWords;
          textController.selection = TextSelection.fromPosition(
            TextPosition(offset: textController.text.length),
          );
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        listenOptions: SpeechListenOptions(
          partialResults: true,
        ),
      );
      if (!isAvailable) {
        isListening.value = false;
      }
    }
  }

  /// Submit feedback
  Future<void> submitFeedback() async {
    final feedback = draftText.value.trim();
    if (feedback.isEmpty) {
      Get.snackbar(
        'Empty Feedback',
        'Please enter your feedback',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isListening.value) {
      await speechToText.stop();
      isListening.value = false;
    }

    isSubmitting.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    isSubmitting.value = false;

    textController.clear();

    if (Get.previousRoute == AppRoutes.profile) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.profile);
    }

    await Future<void>.delayed(const Duration(milliseconds: 120));
    _showSubmitSuccessBanner();
  }

  /// Check if feedback can be submitted
  bool get canSubmit =>
      draftText.value.trim().isNotEmpty && !isSubmitting.value;

  void _syncDraftText() {
    draftText.value = textController.text;
  }

  void _showSubmitSuccessBanner() {
    Get.generalDialog<void>(
      barrierLabel: 'Feedback success',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        Future<void>.delayed(const Duration(seconds: 2), () {
          if (Get.isDialogOpen == true) {
            Get.back<void>();
          }
        });

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.52),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Submitted',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Thank you for your feedback.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.18),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }
}
