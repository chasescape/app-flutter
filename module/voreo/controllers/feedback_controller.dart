import 'package:get/get.dart';
import '../services/api_service.dart';

class FeedbackController extends GetxController {
  final RxString feedback = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt charCount = 0.obs;

  final int maxChars = 500;

  void onFeedbackChanged(String value) {
    if (value.length <= maxChars) {
      feedback.value = value;
      charCount.value = value.length;
    }
  }

  Future<bool> submitFeedback() async {
    if (feedback.value.trim().isEmpty) {
      Get.snackbar(
        'Empty Feedback',
        'Please enter your feedback',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isSubmitting.value = true;

    try {
      final success = await ApiService.submitFeedback(
        feedback: feedback.value,
      );

      isSubmitting.value = false;

      if (success) {
        feedback.value = '';
        charCount.value = 0;
        return true;
      }
      return false;
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar(
        'Error',
        'Failed to submit feedback: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  void clearFeedback() {
    feedback.value = '';
    charCount.value = 0;
  }
}
