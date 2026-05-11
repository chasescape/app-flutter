import 'package:flutter_udid/flutter_udid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../interface.dart';
import 'network_service.dart';

class AppConfigService {
  static const String _keyEncrypt = 'encrypt_key';
  static const String _keyToken = 'auth_token';
  static const String _keyDeviceId = 'device_id';

  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final i = Interface();
    i.authToken = prefs.getString(_keyToken);
    i.encryptKey = prefs.getString(_keyEncrypt);
    i.deviceId = prefs.getString(_keyDeviceId);
  }

  static Future<String> getOrCreateDeviceId() async {
    final i = Interface();
    if (i.deviceId != null && i.deviceId!.isNotEmpty) {
      return i.deviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_keyDeviceId);
    if (cached != null && cached.isNotEmpty) {
      i.deviceId = cached;
      return cached;
    }

    final deviceId = await FlutterUdid.udid;
    i.deviceId = deviceId;
    await prefs.setString(_keyDeviceId, deviceId);
    return deviceId;
  }

  static Future<String?> ensureEncryptKey() async {
    final i = Interface();
    if (i.encryptKey != null && i.encryptKey!.isNotEmpty) {
      return i.encryptKey;
    }

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_keyEncrypt);
    if (cached != null && cached.isNotEmpty) {
      i.encryptKey = cached;
      return cached;
    }

    final key = await _fetchEncryptKey();
    if (key != null && key.isNotEmpty) {
      i.encryptKey = key;
      await prefs.setString(_keyEncrypt, key);
    }
    return key;
  }

  static Future<String?> _fetchEncryptKey() async {
    final res = await NetworkService.ins.post(
      '/api_prod/v2/device_first_group/download',
      body: {'ver': '0'},
      isAppConfig: true,
      printOnSuccess: true,
    );

    final data = res['data'];
    if (data is Map && data['items'] is List) {
      for (final item in data['items'] as List) {
        if (item is Map && item['name'] == 'encrypt_key') {
          return item['data']?.toString();
        }
      }
    }

    return null;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    Interface().authToken = token;
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    Interface().authToken = null;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyEncrypt);
    await prefs.remove(_keyDeviceId);
    final i = Interface();
    i.authToken = null;
    i.encryptKey = null;
    i.deviceId = null;
  }
}
