import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackLogic extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final RxInt selectedMoodIndex = 0.obs;
  final RxBool isSubmitting = false.obs;

  final List<String> moods = <String>[
    '😊 Love it',
    '🙂 Good',
    '😐 Okay',
    '😕 Needs work',
  ];

  void selectMood(int index) {
    selectedMoodIndex.value = index;
  }

  Future<void> sendMessage() async {
    final String message = messageController.text.trim();
    final String email = emailController.text.trim();

    if (message.isEmpty) {
      Get.snackbar(
        'Message required',
        'Please share your feedback before sending.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFE9F0),
        colorText: const Color(0xFF7A4B5A),
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isSubmitting.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    isSubmitting.value = false;

    messageController.clear();

    Get.snackbar(
      'Thank you!',
      email.isEmpty
          ? 'Your feedback was sent successfully.'
          : 'Your feedback was sent successfully. We may contact you at $email.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFE9F0),
      colorText: const Color(0xFF7A4B5A),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
