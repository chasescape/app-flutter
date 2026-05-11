import 'package:shared_preferences/shared_preferences.dart';

import 'env/app_env.dart';
import 'light_handle.dart';

class Interface {
  Interface._();

  static Interface? _instance;
  static SharedPreferences? _prefs;

  factory Interface() {
    _instance ??= Interface._();
    return _instance!;
  }

  static Future<void> initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance (public accessor)
  static SharedPreferences get prefs {
    assert(_prefs != null,
        'SharedPreferences not initialized. Call initPrefs() first.');
    return _prefs!;
  }

  String lightHome = '/create';
  String loginPage = '/login';

  String? env;
  String? authToken;
  String? encryptKey;
  String? userId;
  String? deviceId;

  void setRunEnv({
    required String runEnv,
    required String apiUrl,
    required String h5Url,
    required String imUrl,
    required String logUrl,
    required String h5User,
    required String h5Privacy,
    String? geApiKey,
  }) {
    env = runEnv;
    final config = AppEnv();
    config.env = runEnv == 'prod' ? AppEnvType.product : AppEnvType.test;
    config.hostApi = apiUrl;
    config.hostH5 = h5Url;
    config.hostIM = imUrl;
    config.hostLog = logUrl;
    config.h5User = '$h5Url/$h5User';
    config.h5Privacy = '$h5Url/$h5Privacy';
    config.geApiKey = geApiKey ?? '';
  }

  Future<void> prevInitialize() async {
    await LightHandle.readyToInit();
  }

  Future<void> doSignInAction() async {
    await LightHandle.login();
  }

  Future<void> setHomeEntranceForSideA() async {}

  Future<void> onAuthTokenRemoved() async {
    _doShuffleActions();
  }

  _doShuffleActions() {}
}
