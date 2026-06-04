// *** [do change classname] ***
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'interface.dart';
import 'core/singletons/storage_service.dart';
import 'core/singletons/coins_manager.dart';
import 'core/router/app_routes.dart';

// 具体A面业务处理
class LightHandle {

  // A面业务初始化逻辑，最多进行持久化初始化数据，其他处理应该收到进入Home页面才进行
  static Future<void> readyToInit() async {
    // TODO A面持久化初始化
    // await SharedPreferences.getInstance()
    // await getStorage();

    //
    // 从持久化中初始化数据，并进行后续逻辑处理
    await _initDataFromStorage();
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage() async {
    // 从A面的持久化中读取token
    final i = Interface();
    await i.restoreAuthToken();


    // 一般处理流程
    // 判断encryptKey是否存在，不存在，调用AppConfig接口获取

    // 判断authToken是否空，空，跳登录页，
    // 否者
    // 1 用户信息处理，2 内购相关初始化，3 跳A面home页面， 可用 Interface().lightHome
  }

  /// 登录操作
  static Future<void> login() async {
    // 显示全局 loading
    SmartDialog.showLoading(
      msg: 'Logging in...',
      backDismiss: false,
    );

    try {
      // 模拟 API 请求，随机耗时 1-2 秒
      final random = Random();
      final delay = 1000 + random.nextInt(1000);
      await Future.delayed(Duration(milliseconds: delay));

      // 生成模拟 token
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // 持久化 token
      await StorageService.instance.saveString(StorageKeys.authToken, token);

      // 设置登录态
      Interface().authToken = token;

      // 关闭 loading
      SmartDialog.dismiss();

      // 跳转首页
      AppRoutes.toHome();
    } catch (e, stackTrace) {
      debugPrint('Login failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      // 关闭 loading
      SmartDialog.dismiss();

      // 显示错误提示
      SmartDialog.showToast('Login failed, please try again');
    }
  }

  /// 退出登录
  static Future<void> logout() async {
    // 显示全局 loading
    SmartDialog.showLoading(
      msg: 'Logging out...',
      backDismiss: false,
    );

    try {
      // 模拟 API 请求
      await Future.delayed(const Duration(milliseconds: 800));

      // 清空登录态
      await Interface().onAuthTokenRemoved();

      // 关闭 loading
      SmartDialog.dismiss();

      // 跳转登录页
      AppRoutes.toLogin();
    } catch (e) {
      // 关闭 loading
      SmartDialog.dismiss();

      // 显示错误提示
      SmartDialog.showToast('Logout failed, please try again');
    }
  }

  /// 删除账号
  static Future<void> deleteAccount() async {
    // 显示全局 loading
    SmartDialog.showLoading(
      msg: 'Deleting account...',
      backDismiss: false,
    );

    try {
      // 模拟 API 请求
      await Future.delayed(const Duration(milliseconds: 1500));

      // 清空登录态
      await Interface().onAuthTokenRemoved();

      // 清除所有用户数据
      await CoinsManager.instance.clear();
      await StorageService.instance.remove(StorageKeys.makeupRecords);
      await StorageService.instance.remove(StorageKeys.recordCount);
      await StorageService.instance.remove(StorageKeys.freeUsageCount);

      // 关闭 loading
      SmartDialog.dismiss();

      // 跳转登录页
      AppRoutes.toLogin();
    } catch (e) {
      // 关闭 loading
      SmartDialog.dismiss();

      // 显示错误提示
      SmartDialog.showToast('Delete account failed, please try again');
    }
  }

  _doShuffleActions(){}
}
