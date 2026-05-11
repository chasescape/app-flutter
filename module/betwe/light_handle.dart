// *** [do change classname] ***
import 'package:get/get.dart';

import 'app/service/app_config_service.dart';
import 'app/service/auth_service.dart';
import 'app/service/coins_service.dart';
import 'app/service/history_service.dart';
import 'app/routes/app_routes.dart';
import 'interface.dart';

// 具体A面业务处理
class LightHandle {

  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    // TODO A面持久化初始化
    // await SharedPreferences.getInstance()
    // await getStorage();

    // 从持久化中初始化数据，并进行后续逻辑处理
    await _initDataFromStorage();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    await AppConfigService.loadFromStorage();
    await AppConfigService.getOrCreateDeviceId();
    try {
      await AppConfigService.ensureEncryptKey();
    } catch (e) {
      // ignore: avoid_print
      print('Init app config failed: $e');
    }
  }

  /// A面退出登录操作 (函数名具体定义)
  static Future<void> logout() async {
    try {
      await AuthService.ins.logout();
    } finally {
      await onAuthTokenRemoved();
    }
  }
  /// A面登录操作 (函数名具体定义)
  static Future<void> login() async {
    final res = await AuthService.ins.signInWithDevice();
    if (res['code'] == 0) {
      Get.offAllNamed(AppRoutes.nav);
    } else {
      throw Exception(res['message'] ?? 'Login failed');
    }
  }

  /// A面删除账号操作 (函数名具体定义)
  static Future<void> deleteAccount() async {
    final res = await AuthService.ins.deleteAccount();
    if (res['code'] == 0) {
      await clearAllData();
    } else {
      throw Exception(res['message'] ?? 'Delete account failed');
    }
  }

  /// 删除登录信息
  static Future<void> onAuthTokenRemoved() async {
    // A面清除数据
    // 内存数据
    final i = Interface();
    i.authToken = null;

    // 持久化数据
    await AppConfigService.clearAuth();

    // 跳转
    Get.offAllNamed(AppRoutes.login);

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }



  /// A面删除账号前清除所有数据处理
  static Future<void> clearAllData() async {
    // 内存数据
    final i = Interface();
    i.authToken = null;

    // 所有持久化数据
    await AppConfigService.clearAll();
    await HistoryService.clear();
    if (Get.isRegistered<CoinsService>()) {
      await Get.find<CoinsService>().reset();
    }

    // 跳转
    Get.offAllNamed(AppRoutes.login);

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }

  _doShuffleActions(){}
}
