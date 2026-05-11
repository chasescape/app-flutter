import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinsManager {
  static CoinsManager? _instance;

  static CoinsManager get instance {
    _instance ??= CoinsManager._internal();
    return _instance!;
  }

  CoinsManager._internal() {
    _initFuture = _loadCoins();
  }

  static const String storageKey = 'coins';
  static const String _legacyCoinsKey = 'user_coins';

  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  Future<void>? _initFuture;

  int get currentCoins => coinsNotifier.value;

  Future<void> ensureInitialized() async {
    _initFuture ??= _loadCoins();
    await _initFuture;
  }

  Future<void> _loadCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCoins = prefs.getInt(storageKey);
      final legacyCoins = prefs.getInt(_legacyCoinsKey);
      final coins = storedCoins ?? legacyCoins ?? 0;

      if (storedCoins == null && legacyCoins != null) {
        await prefs.setInt(storageKey, legacyCoins);
        await prefs.remove(_legacyCoinsKey);
      }

      coinsNotifier.value = coins;
    } catch (e) {
      debugPrint('Error loading coins: $e');
      coinsNotifier.value = 0;
    }
  }

  Future<void> _saveCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(storageKey, coins);
      await prefs.remove(_legacyCoinsKey);
      coinsNotifier.value = coins;
    } catch (e) {
      debugPrint('Error saving coins: $e');
    }
  }

  Future<void> addCoins(int coins) async {
    if (coins <= 0) return;
    await ensureInitialized();
    final newCoins = currentCoins + coins;
    await _saveCoins(newCoins);
    debugPrint('Added $coins coins. Total: $newCoins');
  }

  Future<void> subCoins(int coins) async {
    if (coins <= 0) return;
    await ensureInitialized();
    if (!isEnough(coins)) {
      debugPrint('Not enough coins. Current: $currentCoins, Required: $coins');
      return;
    }
    final newCoins = currentCoins - coins;
    await _saveCoins(newCoins);
    debugPrint('Subtracted $coins coins. Total: $newCoins');
  }

  bool isEnough(int coins) {
    return currentCoins >= coins;
  }

  Future<void> setCoins(int coins) async {
    if (coins < 0) return;
    await ensureInitialized();
    await _saveCoins(coins);
    debugPrint('Set coins to: $coins');
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
      await prefs.remove(_legacyCoinsKey);
      coinsNotifier.value = 0;
      debugPrint('Cleared all coins');
    } catch (e) {
      debugPrint('Error clearing coins: $e');
    }
  }

  void dispose() {
    coinsNotifier.dispose();
  }
}
