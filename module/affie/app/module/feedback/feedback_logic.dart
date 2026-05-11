import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../theme/app_colors.dart';

class FeedbackLogic extends GetxController {
  final selectedType = ''.obs;
  final contentController = TextEditingController();
  final contactController = TextEditingController();
  final images = <String>[].obs;

  final _speech = SpeechToText();
  final isListening = false.obs;
  final lastSpeechError = ''.obs;

  var _speechBaseText = '';

  void selectType(String type) {
    selectedType.value = type;
  }

  void addImage() {
    if (images.length < 3) {
      images.add('image_${images.length}');
    }
  }

  void removeImage(String image) {
    images.remove(image);
  }

  Future<void> toggleVoiceInput() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
        }
      },
      onError: (error) {
        lastSpeechError.value = error.errorMsg;
        isListening.value = false;
        Get.snackbar(
          'Voice input unavailable',
          error.errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary.withOpacity(0.95),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      },
    );

    if (!available) {
      Get.snackbar(
        'Voice input unavailable',
        'Speech recognition is not available on this device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary.withOpacity(0.95),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    _speechBaseText = contentController.text.trimRight();
    isListening.value = true;

    await _speech.listen(
      onResult: (result) {
        final recognized = result.recognizedWords.trim();
        final base = _speechBaseText;
        final merged = recognized.isEmpty
            ? base
            : base.isEmpty
                ? recognized
                : '$base $recognized';

        contentController
          ..text = merged
          ..selection = TextSelection.collapsed(offset: merged.length);

        if (result.finalResult) {
          isListening.value = false;
        }
      },
    );
  }

  void submitFeedback() {
    if (selectedType.value.isEmpty) {
      Get.snackbar(
        'Missing info',
        'Please select a feedback type.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary.withOpacity(0.95),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    if (contentController.text.isEmpty) {
      Get.snackbar(
        'Missing info',
        'Please enter a description.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary.withOpacity(0.95),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Get.snackbar(
      'Submitted',
      "Thanks for your feedback — we'll review it soon.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.95),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
    });
  }

  @override
  void onClose() {
    _speech.stop();
    contentController.dispose();
    contactController.dispose();
    super.onClose();
  }
}
