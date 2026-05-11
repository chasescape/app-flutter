import 'package:get/get.dart';
import '../interface.dart';
import '../services/storage_service.dart';
import 'user_controller.dart';

class AuthController extends GetxController {
  final StorageService _storage = StorageService.to;

  final RxBool isLoggedIn = false.obs;
  final RxString authToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final token = _storage.authToken;
    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = true;
      authToken.value = token;
      Interface().authToken = token;
    }
  }

  Future<void> login() async {
    // Set mock token
    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.setAuthToken(token);
    await _storage.setUserId('user_${DateTime.now().millisecondsSinceEpoch}');

    authToken.value = token;
    isLoggedIn.value = true;
    Interface().authToken = token;
    Interface().userId = _storage.userId;
  }

  Future<void> logout() async {
    // Logout should NOT clear local user data/coins/history. Only clear auth.
    await _storage.setAuthToken(null);
    authToken.value = '';
    isLoggedIn.value = false;
    Interface().authToken = null;

    Get.offAllNamed('/login');
  }

  Future<void> deleteAccount() async {
    // Delete account should remove local data (coins + generation history) and sign out.
    if (Get.isRegistered<UserController>()) {
      await Get.find<UserController>().clearAllData();
    } else {
      await _storage.clearAllData();
    }
    authToken.value = '';
    isLoggedIn.value = false;
    Interface().authToken = null;
    Interface().userId = null;

    Get.offAllNamed('/login');
  }
}
