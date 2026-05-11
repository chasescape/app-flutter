// *** [do change classname] ***
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'interface.dart';
import 'app/routes/app_routes.dart';
import 'app/data/journal_store.dart';
import 'app/data/travel_plan_store.dart';
import 'app/data/guides_store.dart';
import 'app/services/diary_storage_service.dart';

// 具体A面业务处理
class LightHandle {
  static const String _kAuthToken = 'auth_token';
  static const String _kEncryptKey = 'encrypt_key';

  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    await _initDataFromStorage();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final i = Interface();

    // 从持久化读取 token
    final token = prefs.getString(_kAuthToken);
    if (token != null && token.isNotEmpty) {
      i.authToken = token;
    } else {
      i.authToken = null;
    }

    // 从持久化读取 encryptKey，不存在时后续接口会通过 AppConfig 获取
    final encryptKey = prefs.getString(_kEncryptKey);
    if (encryptKey != null && encryptKey.isNotEmpty) {
      i.encryptKey = encryptKey;
    }
  }

  /// A面退出登录操作 (函数名具体定义)
  static Future<void> logout() async {
    await onAuthTokenRemoved();
  }
  /// A面登录操作 (函数名具体定义)
  static Future<void> login() async {

  }

  /// A面删除账号操作 (函数名具体定义)
  static Future<void> deleteAccount() async {
    await clearAllData();
  }

  /// 删除登录信息
  static Future<void> onAuthTokenRemoved() async {
    final i = Interface();
    i.authToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthToken);

    i.onAuthTokenRemoved();

    // 固定，合B时候，注释下面跳转, 由B面进行跳转
    Get.offAllNamed(AppRoutes.login);
  }



  /// A面删除账号前清除所有数据处理（金币、日记、行程、guides、auth、encryptKey）
  static Future<void> clearAllData() async {
    final i = Interface();
    i.authToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthToken);
    await prefs.remove(_kEncryptKey);
    await prefs.remove('enkou_coin_balance');
    await prefs.remove('journal_entries_v2');
    await prefs.remove('journal_entries_v1');
    await prefs.remove('travel_plans_v1');
    await prefs.remove('travel_guides_v1');

    if (Get.isRegistered<JournalStore>()) {
      await Get.find<JournalStore>().clearUserData();
    }
    if (Get.isRegistered<TravelPlanStore>()) {
      await Get.find<TravelPlanStore>().clearUserData();
    }
    if (Get.isRegistered<GuidesStore>()) {
      await Get.find<GuidesStore>().clearUserData();
    }

    await DiaryStorageService.clearAll();

    i.onAuthTokenRemoved();

    Get.offAllNamed(AppRoutes.login);
  }

}