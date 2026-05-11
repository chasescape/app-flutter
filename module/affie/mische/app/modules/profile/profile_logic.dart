import 'package:get/get.dart';

import '../../data/local/local_storage.dart';
import '../../network/app_bootstrap_service.dart';
import '../../network/auth_gateway.dart';
import '../../routes/app_routes.dart';
import '../emotion/emotion_logic.dart';

class ProfileLogic extends GetxController {
  final showDeleteConfirm = false.obs;
  final isLoading = false.obs;

  late final AuthGateway _authGateway;

  @override
  void onInit() {
    super.onInit();
    _authGateway = AuthGateway.ins;
  }

  void toggleDeleteConfirm(bool value) {
    showDeleteConfirm.value = value;
  }

  Future<void> logout() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await _authGateway.logout();
      await AppBootstrapService.clearAuth();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Logout failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      await _authGateway.deleteAccount();
      await AppBootstrapService.clearAuth();
      await LocalStorage.clearUserData();
      if (Get.isRegistered<EmotionLogic>()) {
        await Get.find<EmotionLogic>().clearEntries();
      }
      toggleDeleteConfirm(false);
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Delete account failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
