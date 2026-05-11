// *** [do change classname] ***
/// App environment configuration.
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

  // Whether this is a local development environment.
  bool get isProd {
    return env == AppEnvType.product;
  }
}
