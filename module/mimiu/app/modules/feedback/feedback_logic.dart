import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FeedbackLogic extends GetxController {
  final stt.SpeechToText speech = stt.SpeechToText();
  final TextEditingController controller = TextEditingController();

  final RxBool isListening = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString feedbackType = 'General'.obs;

  static const List<String> feedbackTypes = <String>[
    'General',
    'Bug',
    'Feature request',
    'Billing',
    'Other',
  ];

  Future<void> toggleListening() async {
    if (isListening.value) {
      await speech.stop();
      isListening.value = false;
      return;
    }

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      Get.snackbar(
        'Permission required',
        'Please allow microphone access to use voice input.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final initialized = await speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
        }
      },
      onError: (_) => isListening.value = false,
    );

    if (!initialized) {
      Get.snackbar(
        'Speech unavailable',
        'Speech recognition is not available on this device.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isListening.value = true;
    await speech.listen(
      onResult: (result) {
        controller.text = result.recognizedWords;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
    );
  }

  Future<void> submit() async {
    final text = controller.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Feedback required',
        'Please enter your feedback before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (isSubmitting.value) return;
    isSubmitting.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    isSubmitting.value = false;

    Get.back();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    Get.snackbar(
      'Submitted',
      'Thanks for your feedback!',
      backgroundColor: Colors.black.withValues(alpha: 0.78),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    controller.dispose();
    unawaited(speech.stop());
    super.onClose();
  }
}
