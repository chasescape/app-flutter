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
  // Fill this once to enable the built-in AI image analysis flow.
  String aiApiKey = 'sk-rT0clu2sDzlTREJt617c0b0dEa0449448f56Cc149dCe184b';

  // 是否本地开发者环境
  bool get isProd {
    return env == AppEnvType.product;
  }
}
