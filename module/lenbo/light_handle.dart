import 'package:lenbo/lenbo/interface.dart';
import 'app/routes/app_routes.dart';
import 'core/services/analysis_storage.dart';
import 'core/services/coins_manager.dart';

// A面业务处理
class LightHandle {

  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    // A面持久化初始化
    _initDataFromStorage();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    final i = Interface();
    i.authToken = null;
    i.encryptKey = '';
    await CoinsManager.loadCoins();
  }

  /// A面退出登录操作
  static Future<void> logout() async {
    onAuthTokenRemoved();
  }

  /// A面登录操作
  static Future<void> login() async {
    AppRoutes.toMain();
  }

  /// A面删除账号操作
  static Future<void> deleteAccount() async {
    clearAllData();
  }

  /// 删除登录信息
  static Future<void> onAuthTokenRemoved() async {
    final i = Interface();
    i.authToken = null;
    AppRoutes.toLogin();
  }

  /// A面删除账号前清除所有数据处理
  static Future<void> clearAllData() async {
    final i = Interface();
    i.authToken = null;
    await AnalysisStorage.clearHistory();
    await CoinsManager.clear();
    AppRoutes.toLogin();
  }

  _doShuffleActions(){}
}
