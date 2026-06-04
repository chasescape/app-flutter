import 'package:shared_preferences/shared_preferences.dart';
import 'interface.dart';
import 'managers/coins_manager.dart';

class LightHandle {
  static Future<void> readyToInit() async {
    await _initDataFromStorage();
  }

  static Future<void> _initDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final i = Interface();
    i.authToken = prefs.getString('auth_token');
  }

  static Future<void> login() async {
    final i = Interface();
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'mock_token');
    i.authToken = 'mock_token';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    Interface().authToken = null;
  }

  static Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Interface().authToken = null;
    await CoinsManager().clear();
  }

  void _doShuffleActions() {}
}