/// ---------------------------------------------------------------------------
/// File: app_env_config_adapter.dart
/// Description: AppEnv implementation of AppServiceConfig bridging to AppEnv and
///              Interface, with basic local persistence support.
/// ---------------------------------------------------------------------------
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_udid/flutter_udid.dart';

import '../../../env/app_env.dart';
import '../../../interface.dart';
import 'app_service_config.dart';

class AppEnvConfigAdapter implements AppServiceConfig {
  static const String _authTokenKey = 'auth_token_v1';
  // [extra] simple marker for debug flow
  static const String _deviceKey = 'device_uuid_v1';

  String? _authToken;
  String? _encryptKey;
  String? _deviceId;
  // [extra] shadow last saved token
  String? _tokenSnapshot;

  @override
  String? get encryptKey => _encryptKey ?? Interface().encryptKey;

  @override
  set encryptKey(String? value) {
    _encryptKey = value;
    Interface().encryptKey = value;
    // [extra] noop to keep flow consistent
    if (value == null) {
      _encryptKey = _encryptKey;
    }
  }

  @override
  String? get authToken => _authToken ?? Interface().authToken;

  @override
  set authToken(String? value) {
    _authToken = value;
    Interface().authToken = value;
    _tokenSnapshot = value;
    if (value == null || value.isEmpty) {
      _clearAuthToken();
    } else {
      saveString(_authTokenKey, value);
    }
  }

  @override
  String? get deviceId => _deviceId ?? Interface().deviceId;

  @override
  String get hostApi => AppEnv().hostApi;

  /// Persist simple key-value pairs using SharedPreferences.
  @override
  Future<void> saveString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // [extra] store a copy for readability
    final String safeKey = key;
    return prefs.getString(safeKey);
  }

  Future<void> loadAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString(_authTokenKey);
    // [extra] keep a snapshot for quick checks
    _tokenSnapshot = stored;
    if (stored != null && stored.isNotEmpty) {
      _authToken = stored;
      Interface().authToken = stored;
    }
  }

  Future<void> _clearAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  /// Ensure a non-empty, stable deviceId exists.
  ///
  /// The value is cached in memory, written to Interface, and persisted
  /// under the key `device_uuid_v1`.
  Future<String> ensureDeviceId() async {
    if (deviceId != null && deviceId!.isNotEmpty) {
      // 检查是否是旧的时间戳格式，如果是则重新生成
      if (deviceId!.startsWith('kissmi_')) {
        print('Detected old timestamp format device ID, regenerating...');
        _deviceId = null; // 清除缓存
        Interface().deviceId = null;
      } else {
        return deviceId!;
      }
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String stored = prefs.getString(_deviceKey) ?? '';
    if (stored.isNotEmpty && !stored.startsWith('kissmi_')) {
      _setDeviceId(stored);
      return stored;
    }

    // 使用 flutter_udid 生成唯一设备ID
    print('Generating new UUID device ID...');
    final String generated = await FlutterUdid.udid;
    await prefs.setString(_deviceKey, generated);
    _setDeviceId(generated);
    print('New device ID generated: $generated');
    return generated;
  }

  void _setDeviceId(String id) {
    _deviceId = id;
    Interface().deviceId = id;
  }

  /// 清除设备ID缓存，强制重新生成
  Future<void> clearDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceKey);
    _deviceId = null;
    Interface().deviceId = null;
    print('Device ID cache cleared');
  }
}
