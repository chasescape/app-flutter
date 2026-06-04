import 'env/app_env.dart';
import 'light_handle.dart';

class Interface {
  Interface._();

  static Interface? _instance;

  factory Interface() {
    _instance ??= Interface._();
    return _instance!;
  }

  String lightHome = 'AppRoutes.main';
  String loginPage = 'AppRoutes.login';

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
