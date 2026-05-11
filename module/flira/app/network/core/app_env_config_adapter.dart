import 'package:flutter_udid/flutter_udid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../env/app_env.dart';
import '../../../interface.dart';
import 'app_service_config.dart';

/// Flira 项目下的 AppServiceConfig 适配器
///
/// 负责桥接：
/// - 环境配置（AppEnv）
/// - 运行态数据（Interface）
/// - 本地持久化（SharedPreferences）
class AppEnvConfigAdapter implements AppServiceConfig {
  static const String _authTokenKey = 'auth_token_v1';
  static const String _encryptKeyKey = 'encrypt_key_v1';
  static const String _deviceKey = 'device_uuid_v1';

  String? _authToken;
  String? _encryptKey;
  String? _deviceId;

  @override
  String? get encryptKey => _encryptKey ?? Interface().encryptKey;

  @override
  set encryptKey(String? value) {
    _encryptKey = value;
    Interface().encryptKey = value;
    if (value != null && value.isNotEmpty) {
      saveString(_encryptKeyKey, value);
    }
  }

  @override
  String? get authToken => _authToken ?? Interface().authToken;

  @override
  set authToken(String? value) {
    _authToken = value;
    Interface().authToken = value;
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

  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_authTokenKey);
    if (stored != null && stored.isNotEmpty) {
      _authToken = stored;
      Interface().authToken = stored;
    }
  }

  Future<void> loadEncryptKey() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_encryptKeyKey);
    if (stored != null && stored.isNotEmpty) {
      _encryptKey = stored;
      Interface().encryptKey = stored;
    }
  }

  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  /// 确保设备 ID 可用。
  ///
  /// 优先级：内存 -> 本地缓存 -> 生成 udid。
  Future<String> ensureDeviceId() async {
    if (deviceId != null && deviceId!.isNotEmpty) {
      return deviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_deviceKey) ?? '';
    if (stored.isNotEmpty) {
      _setDeviceId(stored);
      return stored;
    }

    final generated = await FlutterUdid.udid;
    await prefs.setString(_deviceKey, generated);
    _setDeviceId(generated);
    return generated;
  }

  void _setDeviceId(String id) {
    _deviceId = id;
    Interface().deviceId = id;
  }
}
