import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FeedbackLogic extends GetxController {
  final messageController = TextEditingController();
  final isListening = false.obs;
  final isSubmitting = false.obs;

  final _speech = stt.SpeechToText();

  Future<void> toggleListening() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      Get.snackbar(
        'Voice unavailable',
        'Speech recognition is not available on this device.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1A1A22),
        colorText: Colors.white,
      );
      return;
    }

    isListening.value = true;
    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      onResult: (result) {
        if (result.recognizedWords.isEmpty) {
          return;
        }
        messageController.text = result.recognizedWords;
        messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length),
        );
        if (result.finalResult) {
          isListening.value = false;
        }
      },
    );
  }

  Future<void> submit() async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar(
        'Missing message',
        'Tell us what you think before sending.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1A1A22),
        colorText: Colors.white,
      );
      return;
    }

    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      messageController.clear();
      Get.snackbar(
        'Thank you!',
        'Your feedback has been sent.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF42E5C0),
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    _speech.stop();
    super.onClose();
  }
}
