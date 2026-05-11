import 'package:flutter/material.dart';
import 'interface.dart';
import 'routes/app_routes.dart';
import 'services/coin_manager.dart';
import 'services/ai_service.dart';

class LightHandle {
  static final ValueNotifier<String?> globalLoadingMessage =
      ValueNotifier<String?>(null);

  static void showGlobalLoading({String message = 'Loading...'}) {
    globalLoadingMessage.value = message;
  }

  static void hideGlobalLoading() {
    globalLoadingMessage.value = null;
  }

  static Future<void> readyToInit() async {
    await Interface.initPrefs();
    final prefs = Interface.prefs;
    final token = prefs.getString('auth_token');
    if (token != null) {
      Interface().authToken = token;
    }
  }

  static Future<void> login() async {
    showGlobalLoading(message: 'Signing in...');
    await Future.delayed(const Duration(seconds: 2));
    await Interface.initPrefs();
    final prefs = Interface.prefs;
    await prefs.setString('auth_token', 'mock_token');
    Interface().authToken = 'mock_token';
    hideGlobalLoading();
  }

  static Future<void> logout() async {
    showGlobalLoading(message: 'Signing out...');
    await Future.delayed(const Duration(seconds: 1));
    final i = Interface();
    i.authToken = null;
    await Interface.initPrefs();
    final prefs = Interface.prefs;
    await prefs.remove('auth_token');
    hideGlobalLoading();
    AppRoutes.router.go(AppRoutes.login);
    i.onAuthTokenRemoved();
  }

  static Future<void> deleteAccount() async {
    await clearAllData();
  }

  static Future<void> clearAllData() async {
    showGlobalLoading(message: 'Deleting account...');
    await Future.delayed(const Duration(seconds: 1));
    final i = Interface();
    i.authToken = null;
    await Interface.initPrefs();
    final prefs = Interface.prefs;
    await prefs.remove('auth_token');
    await CoinManager.to.clearAll();
    await AIService().clearHistory();
    hideGlobalLoading();
    AppRoutes.router.go(AppRoutes.login);
    i.onAuthTokenRemoved();
  }

  static Future<void> onAuthTokenRemoved() async {
    final i = Interface();
    i.authToken = null;
    await Interface.initPrefs();
    final prefs = Interface.prefs;
    await prefs.remove('auth_token');
    AppRoutes.router.go(AppRoutes.login);
    i.onAuthTokenRemoved();
  }
}
