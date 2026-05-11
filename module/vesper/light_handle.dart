// *** [do change classname] ***
import 'app/network/app_config_service.dart';
import 'interface.dart';

// 具体A面业务处理
class LightHandle {

  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    // A面持久化初始化
    await AppConfigService.loadFromStorage();

    // 从持久化中初始化数据，并进行后续逻辑处理
    await _initDataFromStorage();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    final i = Interface();
    
    // 1. 确保设备ID存在
    await AppConfigService.getOrCreateDeviceId();
    
    // 2. 判断encryptKey是否存在，不存在则调用AppConfig接口获取
    if (i.encryptKey == null || i.encryptKey!.isEmpty) {
      await AppConfigService.ensureEncryptKey();
    }

    // 3. 判断authToken是否空
    // 空：跳登录页
    // 否则：
    //   1) 用户信息处理
    //   2) 内购相关初始化
    //   3) 跳A面home页面，可用 Interface().lightHome
  }

  /// A面退出登录操作 (函数名具体定义)
  static Future<void> logout() async {
    // ...
    onAuthTokenRemoved();
  }
  
  /// A面登录操作 (函数名具体定义)
  static Future<void> login() async {
    // 登录前确保配置已初始化
    await AppConfigService.getOrCreateDeviceId();
    await AppConfigService.ensureEncryptKey();
  }

  /// A面删除账号操作 (函数名具体定义)
  static Future<void> deleteAccount() async {
    // ...
    clearAllData();
  }

  /// 删除登录信息
  static Future<void> onAuthTokenRemoved() async {
    // A面清除数据
    await AppConfigService.clearAuth();

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    Interface().onAuthTokenRemoved();
  }

  /// A面删除账号前清除所有数据处理
  static void clearAllData() {
    // 清除所有持久化数据
    AppConfigService.clearAll();

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    Interface().onAuthTokenRemoved();
  }

  _doShuffleActions(){}
}