import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CoinsManager - Unified coin management service
/// Provides persistent storage and reactive updates for user coins
class CoinsManager {
  CoinsManager._();
  static final CoinsManager _instance = CoinsManager._();
  factory CoinsManager() => _instance;

  static const int initialCoins = 100;
  static const String _storageKey = 'user_coins';

  /// ValueNotifier for reactive coin updates
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(initialCoins);

  /// Current coins value
  int get currentCoins => coinsNotifier.value;

  /// Initialize the service and load coins from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCoins = prefs.getInt(_storageKey);
    final coins = storedCoins ?? initialCoins;
    if (storedCoins == null) {
      await prefs.setInt(_storageKey, coins);
    }
    coinsNotifier.value = coins;
  }

  /// Add coins to balance
  /// Returns the new balance
  Future<int> addCoins(int amount) async {
    if (amount <= 0) return currentCoins;

    final newBalance = currentCoins + amount;
    await _saveCoins(newBalance);
    return newBalance;
  }

  /// Subtract coins from balance
  /// Returns true if successful, false if insufficient coins
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return true;
    if (!isEnough(amount)) return false;

    final newBalance = currentCoins - amount;
    await _saveCoins(newBalance);
    return true;
  }

  /// Check if user has enough coins
  bool isEnough(int amount) {
    return currentCoins >= amount;
  }

  /// Set coins to a specific value (for initialization or testing)
  Future<void> setCoins(int amount) async {
    await _saveCoins(amount);
  }

  /// Save coins to persistent storage
  Future<void> _saveCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, amount);
    coinsNotifier.value = amount;
  }

  /// Clear all coin data (for account deletion)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    coinsNotifier.value = 0;
  }

  /// Dispose the ValueNotifier
  void dispose() {
    coinsNotifier.dispose();
  }
}

/// Global instance
final coinsManager = CoinsManager();
