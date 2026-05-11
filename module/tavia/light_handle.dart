import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'cherish_ai/cherish_moment_storage.dart';
import 'interface.dart';
import 'core/state/app_state.dart';
import 'core/router/app_routes.dart';

// A面业务处理
class LightHandle {
  // A面业务初始化逻辑
  static Future<void> readyToInit() async {
    // 初始化 SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Interface.setPrefs(prefs);

    // 从持久化中初始化数据
    await _initDataFromStorage(prefs);
  }

  // A面从持久化中初始化数据
  static Future<void> _initDataFromStorage(SharedPreferences prefs) async {
    final i = Interface();
    final appState = AppState();

    // 从 SharedPreferences 读取 token
    final token = prefs.getString('auth_token');
    i.authToken = token;

    final coinBalance = prefs.getInt('coin_balance');
    if (coinBalance != null) {
      appState.setCoinBalance(coinBalance);
    }

    // 初始化用户数据
    if (token != null) {
      appState.setUser(await _getUserDataFromStorage(prefs));
    }
  }

  // 从本地存储获取用户数据
  static Future<dynamic> _getUserDataFromStorage(SharedPreferences prefs) async {
    // 这里应该从本地存储获取完整的用户数据
    // 暂时返回 null，实际使用时需要存储和读取完整的用户信息
    return null;
  }

  /// A面退出登录操作
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // 清除本地存储的 token
    await prefs.remove('auth_token');

    // 清除内存数据
    final i = Interface();
    i.authToken = null;

    // 清除状态
    final appState = AppState();
    appState.clearUser();

    // 跳转到登录页
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  /// A面登录操作
  static Future<void> login(BuildContext context, String token) async {
    final prefs = await SharedPreferences.getInstance();

    // 保存 token 到本地存储
    await prefs.setString('auth_token', token);

    // 设置登录态
    final i = Interface();
    i.authToken = token;

    // 跳转到首页
    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  /// A面删除账号操作
  static Future<void> deleteAccount(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final appState = AppState();

    // 清除历史、金币和购买痕迹
    await CherishMomentStorage.clear();
    await prefs.remove('coin_balance');
    await prefs.remove('store_delivered_purchase_ids');
    await prefs.remove('auth_token');

    // 清除内存数据
    final i = Interface();
    i.authToken = null;

    // 清除状态
    appState.clearSessionData();

    // 跳转到登录页
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  /// 删除登录信息
  static Future<void> onAuthTokenRemoved(BuildContext context) async {
    // A面清除数据
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 内存数据
    final i = Interface();
    i.authToken = null;

    // 跳转
    if (context.mounted) {
      context.go(AppRoutes.login);
    }

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }

  /// A面删除账号前清除所有数据处理
  static Future<void> clearAllData(BuildContext context) async {
    // 内存数据
    final i = Interface();
    i.authToken = null;

    // 所有持久化数据
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 清除状态
    final appState = AppState();
    appState.clearUser();
    appState.dispose();

    // 跳转
    if (context.mounted) {
      context.go(AppRoutes.login);
    }

    // 固定，合B时候，注释上面跳转, 由B面进行跳转
    i.onAuthTokenRemoved();
  }
}
