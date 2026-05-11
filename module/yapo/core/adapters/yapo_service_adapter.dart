import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapo/yapo/env/app_env.dart';
import 'package:yapo/yapo/interface.dart';


import '../core/service_config.dart';

/// 将项目的全局状态（Interface、AppEnv）桥接到可复用服务层。
/// 
/// 使用方式：
/// ```dart
/// final config = PaechServiceAdapter();
/// final appConfigService = AppConfigService(dio, config);
/// ```
class YapoServiceAdapter implements ServiceConfig {
  final Interface _interface = Interface();
  SharedPreferences? _prefs;

  @override
  String? get encryptKey => _interface.encryptKey;

  @override
  set encryptKey(String? value) => _interface.encryptKey = value;

  @override
  String? get authToken => _interface.authToken;

  @override
  set authToken(String? value) => _interface.authToken = value;

  @override
  String? get deviceId => _interface.deviceId;

  @override
  String get hostApi => AppEnv().hostApi;

  @override
  Future<void> saveString(String key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(key);
  }
}
