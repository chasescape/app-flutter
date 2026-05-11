import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinStore {
  CoinStore._();

  static const String _keyBalance = 'coin_balance';
  static final ValueNotifier<int> balance = ValueNotifier<int>(110);

  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    balance.value = prefs.getInt(_keyBalance) ?? balance.value;
  }

  static void setBalance(int value) {
    balance.value = value;
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyBalance, value);
    }();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBalance);
    balance.value = 0;
  }
}
