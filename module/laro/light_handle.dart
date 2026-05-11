import 'package:shared_preferences/shared_preferences.dart';

import 'services/coins_manager.dart';

// *** [do change classname] ***
import 'interface.dart';

// 具体A面业务处理
class LightHandle {
  static const _authTokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    // 初始化金币管理器
    await CoinsManager().initialize();
    // TODO A面持久化初始化
    // await SharedPreferences.getInstance()
    // await getStorage();

    // 从持久化中初始化数据，并进行后续逻辑处理
    _initDataFromStorage();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final i = Interface();
    i.authToken = prefs.getString(_authTokenKey);
    i.userId = prefs.getString(_userIdKey);
    i.encryptKey = 'getAppConfig and set';

    // 一般处理流程
    // 判断encryptKey是否存在，不存在，调用AppConfig接口获取

    // 判断authToken是否空，空，跳登录页，
    // 否者
    // 1 用户信息处理，2 内购相关初始化，3 跳A面home页面， 可用 Interface().lightHome
  }

  /// A面退出登录操作 (函数名具体定义)
  static Future<void> logout() async {
    await onAuthTokenRemoved();
  }

  /// A面登录操作 (函数名具体定义)
  static Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    final i = Interface();
    final loginTimestamp = DateTime.now().millisecondsSinceEpoch;
    final authToken = 'mock_token_$loginTimestamp';
    final userId = 'user_$loginTimestamp';

    await prefs.setString(_authTokenKey, authToken);
    await prefs.setString(_userIdKey, userId);

    i.authToken = authToken;
    i.userId = userId;
  }

  /// A面删除账号操作 (函数名具体定义)
  static Future<void> deleteAccount() async {
    // ...
    await clearAllData();
  }

  /// 删除登录信息
  static Future<void> onAuthTokenRemoved() async {
    // A面清除数据
    // 内存数据
    final i = Interface();
    i.authToken = null;
    i.userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);

    // 跳转

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }

  /// A面删除账号前清除所有数据处理
  static Future<void> clearAllData() async {
    // 内存数据
    final i = Interface();
    i.authToken = null;
    i.userId = null;

    // 清除金币数据
    await CoinsManager().clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 跳转

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }
}
