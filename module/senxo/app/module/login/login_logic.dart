import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../routes/app_pages.dart';

class LoginLogic extends GetxController {
  var isAgreed = false.obs;
  var isPageLoading = true.obs;
  var isLoggingIn = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 1200), () {
      isPageLoading.value = false;
    });
  }

  void toggleAgreement() {
    isAgreed.value = !isAgreed.value;
  }

  /// 点击进入：先 getAppConfig，再 udid + oauthType 调 /security/oauth，走加密后进入首页
  Future<void> doLogin() async {
    isLoggingIn.value = true;
    try {
      final ok = await _authService.loginWithDevice();
      if (ok) {
        Get.offAllNamed(Routes.home);
      } else {
        Get.snackbar('Notice', 'Login failed', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Notice', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoggingIn.value = false;
    }
  }
}
