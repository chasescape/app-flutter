import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'interface.dart';
import 'controllers/user_controller.dart';
import 'services/coins_manager.dart';

class LightHandle {
  static Future<void> readyToInit() async {
    await _initDataFromStorage();
  }

  static Future<void> _initDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final i = Interface();

    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');

    i.authToken = token;
    i.userId = userId;

    if (token != null && token.isNotEmpty) {
      final userController = _ensureUserController();
      await userController.loadUserData();
    }
  }

  static Future<void> login() async {
    final i = Interface();
    i.authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    i.userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', i.authToken!);
    await prefs.setString('user_id', i.userId!);
  }

  static Future<void> logout() async {
    await onAuthTokenRemoved();
  }

  static Future<void> deleteAccount() async {
    await clearAllData();
  }

  static Future<void> onAuthTokenRemoved() async {
    final i = Interface();
    i.authToken = null;
    i.userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');

    final userController = _ensureUserController();
    await userController.signOut();

    i.onAuthTokenRemoved();
  }

  static Future<void> clearAllData() async {
    final i = Interface();
    i.authToken = null;
    i.userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final coinsManager = CoinsManager();
    await coinsManager.clear();

    final userController = _ensureUserController();
    await userController.clearUserData();

    i.onAuthTokenRemoved();
  }

  static UserController _ensureUserController() {
    if (Get.isRegistered<UserController>()) {
      return Get.find<UserController>();
    }
    return Get.put(UserController());
  }

  void _doShuffleActions() {}
}
