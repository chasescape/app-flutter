// *** [do change classname] ***
import 'package:get/get.dart';
import 'interface.dart';
import 'services/global_service.dart';
import 'routes/app_pages.dart';

// 具体A面业务处理
class LightHandle {

  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    // 初始化全局服务
    await GlobalService.init();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    final globalService = GlobalService.to;
    await globalService.loadAuthState();

    final i = Interface();
    i.authToken = globalService.authToken.value;

    // 判断登录态，决定跳转
    if (globalService.isLoggedIn) {
      // 已登录，跳转首页
      AppRoutes.goToHome();
    } else {
      // 未登录，跳转登录页
      AppRoutes.goToLogin();
    }
  }

  /// A面退出登录操作
  static Future<void> logout() async {
    final globalService = GlobalService.to;
    await globalService.clearAuthState();
    Interface().authToken = null;
    AppRoutes.goToLogin();
  }

  /// A面登录操作
  static Future<void> login() async {
    // 登录逻辑在 LoginController 中处理
  }

  /// A面删除账号操作
  static Future<void> deleteAccount() async {
    final globalService = GlobalService.to;
    await globalService.clearAuthState();
    Interface().authToken = null;
    AppRoutes.goToLogin();
  }

  /// 删除登录信息
  static Future<void> onAuthTokenRemoved() async {
    // A面清除数据
    final globalService = GlobalService.to;
    await globalService.clearAuthState();

    final i = Interface();
    i.authToken = null;

    // 跳转
    AppRoutes.goToLogin();

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }

  /// A面删除账号前清除所有数据处理
  static Future<void> clearAllData() async {
    // 内存数据
    final globalService = GlobalService.to;
    await globalService.clearAuthState();

    final i = Interface();
    i.authToken = null;

    // 所有持久化数据在 GlobalService 中处理

    // 跳转
    AppRoutes.goToLogin();

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }

  _doShuffleActions(){}
}
