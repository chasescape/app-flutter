// *** [do change classname] ***
import 'auth_state.dart';
import 'interface.dart';
import 'module/module.dart';

// 具体A面业务处理
class LightHandle {
  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    // TODO A面持久化初始化
    // await SharedPreferences.getInstance()
    // await getStorage();

    // 从持久化中初始化数据，并进行后续逻辑处理
    _initDataFromStorage();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    // 从A面的持久化中读取token
    final i = Interface();
    i.authToken = null;
    AppAuthState.instance.setToken(i.authToken);

    // 一般处理流程
    // 判断encryptKey是否存在，不存在，调用AppConfig接口获取

    // 判断authToken是否空，空，跳登录页，
    // 否者
    // 1 用户信息处理，2 内购相关初始化，3 跳A面home页面， 可用 Interface().lightHome
  }

  /// A面退出登录操作 (函数名具体定义)
  static Future<void> logout() async {
    // ...
    onAuthTokenRemoved();
  }

  /// A面登录操作 (函数名具体定义)
  static Future<void> login() async {
    final i = Interface();
    i.authToken = 'mock_auth_token';
    AppAuthState.instance.setToken(i.authToken);
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
    AppAuthState.instance.setToken(i.authToken);

    // 持久化数据

    // 跳转

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }

  /// A面删除账号前清除所有数据处理
  static Future<void> clearAllData() async {
    // 内存数据
    final i = Interface();
    i.authToken = null;
    AppAuthState.instance.setToken(i.authToken);

    // 所有持久化数据
    await CoinIapService.instance.clearLocalData();
    await GameProgressStore.instance.clearAll();

    // 跳转

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }

  _doShuffleActions() {}
}
