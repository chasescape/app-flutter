// *** [do change classname] ***
import 'env/app_env.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'services/storage_service.dart';
import 'services/coins_manager.dart';

// interface 相当于协议，约定。不要随意增加方法和修改参数!!!。
class Interface {
  Interface._();

  static Interface? _instance;

  factory Interface() {
    _instance ??= Interface._();
    return _instance!;
  }

  // A面的home页面
  String lightHome = AppRoutes.home;
  // 登录页面路由
  String loginPage = AppRoutes.login;

  // prod | test
  String? env;
  // 用户登录态，在登录后或者开始从持久化读取。接口登录态处理直接读取这值
  String? authToken;

  /// 设置环境变量
  void setRunEnv({
    required String runEnv,
    required String apiUrl,
    required String h5Url,
    required String imUrl,
    required String logUrl,
    required String h5User,
    required String h5Privacy,
    String? geApiKey,
  }) {
    env = runEnv;

    // TODO A面配置
    final config = AppEnv();
    config.env = runEnv == 'prod' ? AppEnvType.product : AppEnvType.test;
    config.hostApi = apiUrl;
    config.hostH5 = h5Url;
    config.hostIM = imUrl;
    config.hostLog = logUrl;
    config.h5User = '$h5Url/$h5User';
    config.h5Privacy = '$h5Url/$h5Privacy';
    config.geApiKey = geApiKey ?? '';

    // TODO B面的配置
  }

  /// 初始化
  Future<void> prevInitialize() async {
    try {
      await _prevInitializeInner().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint(
            '[CheriaStartup] prevInitialize timed out; continuing as logged out.',
          );
        },
      );
    } catch (e, stackTrace) {
      authToken = null;
      debugPrint('[CheriaStartup] prevInitialize failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _prevInitializeInner() async {
    debugPrint('[CheriaStartup] storage init started');
    // A面初始化
    // 持久化初始化，根据项目中的持久化实现，进行初始化处理
    await StorageService.init();
    debugPrint('[CheriaStartup] storage init finished');
    // 恢复登录态：从本地存储读取登录信息
    final savedToken = await StorageService.loadAuthToken();
    if (savedToken != null) {
      authToken = savedToken;
    }
    debugPrint('[CheriaStartup] auth restore finished: ${authToken != null}');

    // TODO B面初始化
  }

  /// 登录操作
  Future<void> doSignInAction() async {
    // 模拟调用接口，随机耗时500到1500毫秒
    final delay = 500 + (DateTime.now().millisecondsSinceEpoch % 1000);
    await Future.delayed(Duration(milliseconds: delay.toInt()));

    // 设置登录态
    authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

    // 持久化登录信息
    await StorageService.saveAuthToken(authToken!);
  }

  /// B面进入A面前的处理
  Future<void> setHomeEntranceForSideA() async {
    // A面时期无需处理
    // TODO 合B阶段进行处理
  }

  /// 删除登录信息
  Future<void> onAuthTokenRemoved() async {
    // 清空登录态
    authToken = null;

    // 清除持久化登录信息
    await StorageService.clearAuthToken();

    // 清除金币数据
    await CoinsManager.instance.clear();

    _doShuffleActions();
  }

  _doShuffleActions() {}
}
