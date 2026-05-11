import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinsManager {
  static final CoinsManager _instance = CoinsManager._internal();
  factory CoinsManager() => _instance;
  CoinsManager._internal();

  static const String _coinsKey = 'coins';

  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  int get currentCoins => coinsNotifier.value;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    coinsNotifier.value = prefs.getInt(_coinsKey) ?? 0;
    debugPrint('CoinsManager initialized with ${coinsNotifier.value} coins');
  }

  Future<void> setCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, amount);
    coinsNotifier.value = amount;
    debugPrint('Coins set to: $amount');
  }

  Future<void> addCoins(int amount) async {
    final newAmount = coinsNotifier.value + amount;
    await setCoins(newAmount);
    debugPrint('Added $amount coins, total: $newAmount');
  }

  Future<bool> subCoins(int amount) async {
    if (!isEnough(amount)) {
      debugPrint('Insufficient coins: ${coinsNotifier.value}, needed: $amount');
      return false;
    }

    final newAmount = coinsNotifier.value - amount;
    await setCoins(newAmount);
    debugPrint('Subtracted $amount coins, total: $newAmount');
    return true;
  }

  bool isEnough(int amount) {
    return coinsNotifier.value >= amount;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coinsKey);
    coinsNotifier.value = 0;
    debugPrint('Coins cleared');
  }

  void dispose() {
    // App-wide singleton. Its notifier may be observed by multiple screens,
    // so page-level lifecycle hooks must not dispose it.
  }
}
