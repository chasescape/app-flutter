import 'interface.dart';
import 'data/datasources/local_storage.dart';
import 'routes/app_pages.dart';
import 'core/models/user_model.dart';
import 'core/models/creation_model.dart';
import 'core/models/post_model.dart';
import 'services/coins_manager.dart';

// A面业务处理 - Daily Happiness App
class LightHandle {
  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    await _initDataFromStorage();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    final i = Interface();

    // 从A面的持久化中读取token
    final token = await LocalStorage.getToken();
    i.authToken = token;

    // 初始化金币管理器（必须在其他初始化之前）
    await CoinsManager().initialize();

    // 如果有token，加载用户数据
    if (token != null) {
      final userData = await LocalStorage.getUserData();
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        UserState().setUser(user);
      }

      // 加载创作记录
      final creationsData = await LocalStorage.getCreationsData();
      if (creationsData.isNotEmpty) {
        final creations = creationsData.map((data) {
          return CreationModel.fromJson(data);
        }).toList();
        CreationsState().setCreations(creations);
      }
    }
  }

  /// A面登录操作
  static Future<void> login() async {
    // 登录成功后的处理已在登录页面完成
    // 这里只负责更新接口状态
  }

  /// A面退出登录操作
  static Future<void> logout() async {
    await onAuthTokenRemoved();
  }

  /// A面删除账号操作
  static Future<void> deleteAccount() async {
    await clearAllData();
  }

  /// 删除登录信息
  static Future<void> onAuthTokenRemoved() async {
    // A面清除数据
    final i = Interface();
    i.authToken = null;

    // 清除状态管理数据
    UserState().clearUser();
    PostsState().clearPosts();
    CreationsState().clearCreations();

    // 清除持久化数据
    await LocalStorage.removeToken();
    await LocalStorage.removeUserData();
    await LocalStorage.removeCreationsData();

    // 跳转到登录页
    AppRoutes.toLogin();

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }

  /// A面删除账号前清除所有数据处理
  static Future<void> clearAllData() async {
    // 内存数据
    final i = Interface();
    i.authToken = null;

    // 清除状态管理数据
    UserState().clearUser();
    PostsState().clearPosts();
    CreationsState().clearCreations();

    // 清除金币数据
    await CoinsManager().clear();

    // 清除所有持久化数据
    await LocalStorage.clearAll();

    // 跳转到登录页
    AppRoutes.toLogin();

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }

  // 保留混淆方法
  _doShuffleActions() {}
}
