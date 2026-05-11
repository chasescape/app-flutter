import 'dart:math' as math;

import 'package:enkou/enkou/env/app_env.dart';
import 'package:enkou/enkou/interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'service_config.dart';

class EnkouServiceAdapter implements ServiceConfig {
  static const String _kDeviceId = 'device_uuid_v1';
  static const String _kEncryptKey = 'encrypt_key';
  static const String _kAuthToken = 'auth_token';

  final Interface _i = Interface();

  @override
  String? get encryptKey => _i.encryptKey;

  @override
  set encryptKey(String? value) {
    _i.encryptKey = value;
    if (value != null && value.isNotEmpty) {
      saveString(_kEncryptKey, value);
    }
  }

  @override
  String? get authToken => _i.authToken;

  @override
  set authToken(String? value) {
    _i.authToken = value;
    if (value != null && value.isNotEmpty) {
      saveString(_kAuthToken, value);
    }
  }

  @override
  String? get deviceId => _i.deviceId;

  @override
  String get hostApi => AppEnv().hostApi;

  @override
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<String> ensureDeviceId() async {
    final existing = _i.deviceId;
    if (existing != null && existing.isNotEmpty) return existing;

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kDeviceId);
    if (cached != null && cached.isNotEmpty) {
      _i.deviceId = cached;
      return cached;
    }

    final generated = _uuidV4();
    await prefs.setString(_kDeviceId, generated);
    _i.deviceId = generated;
    return generated;
  }

  Future<void> clearAuthToken() async {
    _i.authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthToken);
  }

  Future<void> clearEncryptKey() async {
    _i.encryptKey = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEncryptKey);
  }

  String _uuidV4() {
    final rnd = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant RFC4122

    String two(int v) => v.toRadixString(16).padLeft(2, '0');
    final hex = bytes.map(two).toList();
    return '${hex.sublist(0, 4).join()}-'
        '${hex.sublist(4, 6).join()}-'
        '${hex.sublist(6, 8).join()}-'
        '${hex.sublist(8, 10).join()}-'
        '${hex.sublist(10, 16).join()}';
  }
}

