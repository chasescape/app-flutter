import 'package:get/get.dart';

import '../../../light_handle.dart';

class ProfileLogic extends GetxController {
  final RxBool isProcessing = false.obs;

  Future<void> logout() async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      await LightHandle.logout();
    } catch (e) {
      Get.snackbar('Logout failed', e.toString());
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> deleteAccount() async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      await LightHandle.deleteAccount();
    } catch (e) {
      Get.snackbar('Delete account failed', e.toString());
    } finally {
      isProcessing.value = false;
    }
  }
}
