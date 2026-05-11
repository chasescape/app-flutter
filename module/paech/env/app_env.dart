// *** [do change classname] ***
///app环境配置
enum Wreaking868AppEnvType {
  test,
  product,
}

class Aquaria255AppEnv {
  static Aquaria255AppEnv? _ins;
  Aquaria255AppEnv._internal();
  factory Aquaria255AppEnv() {
    _ins ??= Aquaria255AppEnv._internal();
    return _ins!;
  }

  Wreaking868AppEnvType env = Wreaking868AppEnvType.test;
  String hostApi = '';
  String hostIM = '';
  String hostLog = '';
  String hostH5 = '';
  String h5User = '';
  String h5Privacy = '';

  // 是否本地开发者环境
  bool get isProd {
    return env == Wreaking868AppEnvType.product;
  }

}
