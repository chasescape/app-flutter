import 'package:get/get.dart';

class LoginLogic extends GetxController {
  final isAgreed = false.obs;

  void toggleAgreement() {
    isAgreed.value = !isAgreed.value;
  }

  void onStartTap() {
    if (!isAgreed.value) {
      Get.snackbar(
        'Notice',
        'Please agree to Terms and Privacy Policy',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // TODO: Navigate to next page or perform login
  }
}
