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
  // 图生图 AI 服务独立域名（与业务 hostApi 分离）
  String imageEditApiUrl = 'https://api.gpt.ge';

  // 金币内购商品ID
  String get coinProductId100 => 'com.funny.temp.preview.coins.100';
  String get coinProductId500 => 'com.funny.temp.preview.coins.500';
  String get coinProductId1200 => 'com.funny.temp.preview.coins.1200';
  String get coinProductId3000 => 'com.funny.temp.preview.coins.3000';

  // 是否本地开发者环境
  bool get isProd {
    return env == AppEnvType.product;
  }

}
