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
  
  // AI 图生图服务配置
  String aiApiBaseUrl = 'https://api.gpt.ge';
  String aiApiKey = 'sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a';
  String aiModel = 'gpt-4o-2024-05-13';

  // 是否本地开发者环境
  bool get isProd {
    return env == AppEnvType.product;
  }

}
