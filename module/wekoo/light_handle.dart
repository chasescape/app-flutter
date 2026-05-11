import 'interface.dart';
import 'services/storage_service.dart';
import 'services/coins_manager.dart';
import 'package:get/get.dart';

class LightHandle {
  static Future<void> readyToInit() async {
    final storageService = await StorageService().init();
    if (Get.isRegistered<StorageService>()) {
      Get.replace<StorageService>(storageService);
    } else {
      Get.put<StorageService>(storageService, permanent: true);
    }
    CoinsManager.instance.init();
    _initDataFromStorage();
  }

  static Future<void> _initDataFromStorage() async {
    final storage = StorageService.to;
    final i = Interface();

    i.authToken = storage.prefs.getString('auth_token');
    i.userId = storage.prefs.getString('user_id');
  }

  static Future<void> login() async {
    final i = Interface();
    final storage = StorageService.to;

    i.authToken = 'mock_token';
    i.userId = 'mock_user_id';

    await storage.prefs.setString('auth_token', 'mock_token');
    await storage.prefs.setString('user_id', 'mock_user_id');
  }

  static Future<void> logout() async {
    final i = Interface();
    final storage = StorageService.to;

    i.authToken = null;
    i.userId = null;

    await storage.prefs.remove('auth_token');
    await storage.prefs.remove('user_id');
  }

  static Future<void> deleteAccount() async {
    final i = Interface();
    final storage = StorageService.to;

    i.authToken = null;
    i.userId = null;

    await storage.prefs.remove('auth_token');
    await storage.prefs.remove('user_id');
    await CoinsManager.instance.clear();
    await storage.clearAllData();
  }

  static void onAuthTokenRemoved() {
    final i = Interface();
    i.authToken = null;
    i.onAuthTokenRemoved();
  }

  static void clearAllData() {
    final i = Interface();
    i.authToken = null;
    StorageService.to.clearAllData();
    i.onAuthTokenRemoved();
  }

  static void _doShuffleActions() {}
}
