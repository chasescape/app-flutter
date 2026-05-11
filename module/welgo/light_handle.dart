import 'package:shared_preferences/shared_preferences.dart';
import 'interface.dart';
import 'core/managers/coins_manager.dart';
import 'core/services/storage_service.dart';

class LightHandle {
  static Future<void> readyToInit() async {
    await _initDataFromStorage();
    CoinsManager.instance;
  }

  static Future<void> _initDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final i = Interface();

    i.authToken = prefs.getString('auth_token');

    final freeUses = prefs.getInt('free_uses');
    if (freeUses == null) {
      final randomFreeUses = 1 + (DateTime.now().millisecond % 3);
      await prefs.setInt('free_uses', randomFreeUses);
    }

    i.userId = prefs.getString('user_id') ?? '';
    i.deviceId = prefs.getString('device_id') ?? '';
    i.encryptKey = prefs.getString('encrypt_key') ?? 'default_encrypt_key';
  }

  static Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');

    final i = Interface();
    i.authToken = prefs.getString('auth_token');

    final freeUses = prefs.getInt('free_uses');
    if (freeUses == null) {
      final randomFreeUses = 1 + (DateTime.now().millisecond % 3);
      await prefs.setInt('free_uses', randomFreeUses);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    final i = Interface();
    i.authToken = null;
  }

  static Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final i = Interface();
    i.authToken = null;

    await StorageService.instance.clear();
    await CoinsManager.instance.clear();
  }
}
