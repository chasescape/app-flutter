import 'interface.dart';
import 'services/storage_service.dart';

class LightHandle {
  static Future<void> readyToInit() async {
    await StorageService.instance.initialize();
    _initDataFromStorage();
  }

  static Future<void> _initDataFromStorage() async {
    final storage = StorageService.instance;
    final i = Interface();

    final authToken = storage.authToken;
    i.authToken = authToken;
  }

  static Future<void> logout() async {
    final storage = StorageService.instance;
    await storage.removeAuthToken();
    onAuthTokenRemoved();
  }

  static Future<void> login() async {
    final storage = StorageService.instance;
    final token = storage.authToken;
    if (token != null) {
      Interface().authToken = token;
    }
  }

  static Future<void> deleteAccount() async {
    final storage = StorageService.instance;
    await storage.clearAllUserData();
    clearAllData();
  }

  static Future<void> onAuthTokenRemoved() async {
    final i = Interface();
    i.authToken = null;
    i.onAuthTokenRemoved();
  }

  static void clearAllData() {
    final i = Interface();
    i.authToken = null;
    i.onAuthTokenRemoved();
  }

  static void _doShuffleActions() {}
}
