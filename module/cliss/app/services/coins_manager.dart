import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinsManager {
  CoinsManager._();

  static late final CoinsManager _instance = CoinsManager._internal();
  static CoinsManager get instance => _instance;

  CoinsManager._internal();

  static const String _keyCoins = 'user_coins';

  final ValueNotifier<int> coinsV = ValueNotifier<int>(0);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    coinsV.value = prefs.getInt(_keyCoins) ?? 100;
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final current = coinsV.value;
    coinsV.value = current + amount;
    await prefs.setInt(_keyCoins, coinsV.value);
  }

  Future<void> subCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = coinsV.value;
    if (current < amount) return;
    coinsV.value = current - amount;
    await prefs.setInt(_keyCoins, coinsV.value);
  }

  bool isEnough(int amount) {
    return coinsV.value >= amount;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCoins);
    coinsV.value = 0;
  }
}
