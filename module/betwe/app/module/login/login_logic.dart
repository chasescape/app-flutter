import 'package:get/get.dart';

import '../../../interface.dart';

class LoginLogic extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> signIn() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await Interface().doSignInAction();
    } catch (e) {
      Get.snackbar('Login failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
