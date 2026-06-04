// *** [do change classname] ***
///app环境配置
enum AppEnvType {
  test,
  product,
}

class AppEnv {
  static AppEnv? _ins;
  AppEnv._internal();
  factory AppEnv() {
    _ins ??= AppEnv._internal();
    return _ins!;
  }

  AppEnvType env = AppEnvType.test;
  String hostApi = '';
  String hostIM = '';
  String hostLog = '';
  String hostH5 = '';
  String h5User = '';
  String h5Privacy = '';
  // AI 服务的key
  String geApiKey = '';

  // 是否本地开发者环境
  bool get isProd {
    return env == AppEnvType.product;
  }

}
