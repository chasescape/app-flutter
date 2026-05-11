// *** [do change classname] ***
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'interface.dart';
import 'data/services/storage_service.dart';
import 'data/services/api_service.dart';
import 'data/services/coins_manager.dart';
import 'data/services/purchase_service.dart';
import 'data/services/tool_charge_service.dart';

// 具体A面业务处理
class LightHandle {
  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    // Initialize storage service
    await Get.putAsync(() => StorageService.init(), permanent: true);
    await Get.putAsync(() => ApiService.init(), permanent: true);

    // Initialize coins manager
    Get.put(CoinsManager(), permanent: true);

    // Initialize purchase service
    final purchaseService = Get.put(PurchaseService(), permanent: true);
    await purchaseService.initialize();

    // Initialize tool charge service
    Get.put(ToolChargeService(), permanent: true);

    // 从持久化中初始化数据，并进行后续逻辑处理
    await _initDataFromStorage();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // 从A面的持久化中读取token
    final i = Interface();
    i.authToken = prefs.getString('auth_token');

    // 判断authToken是否为空，空则跳登录页，否则跳A面home页面
    if (i.authToken == null) {
      // 跳转到登录页
      i.loginPage = '/login';
    } else {
      // 已登录，设置主页
      i.lightHome = '/main';
    }
  }

  /// A面退出登录操作 (函数名具体定义)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('is_logged_in');
    await onAuthTokenRemoved();
    Get.offAllNamed('/login');
  }

  /// A面登录操作 (函数名具体定义)
  static Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();

    // Set auth token
    final i = Interface();
    i.authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('auth_token', i.authToken!);
    await prefs.setBool('is_logged_in', true);

    // Navigate to main page
    Get.offAllNamed('/main');
  }

  /// A面删除账号操作 (函数名具体定义)
  static Future<void> deleteAccount() async {
    await clearAllData();
    // Navigate to login page
    Get.offAllNamed('/login');
  }

  /// 删除登录信息
  static Future<void> onAuthTokenRemoved() async {
    // A面清除数据
    final i = Interface();
    i.authToken = null;

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    await i.onAuthTokenRemoved();
  }

  /// A面删除账号前清除所有数据处理
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 内存数据
    final i = Interface();
    i.authToken = null;

    // Clear all storage data
    final storage = Get.find<StorageService>();
    await storage.clearAllData();

    // Clear coins manager data
    final coinsManager = Get.find<CoinsManager>();
    await coinsManager.clear();

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    await i.onAuthTokenRemoved();
  }

  _doShuffleActions() {}
}
