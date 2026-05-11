import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lenbo/lenbo/core/utils/constants.dart';

/// Manages user coins with persistence and reactive ValueNotifier.
class CoinsManager {
  static SharedPreferences? _prefs;

  /// Notifier for UI to listen on coin changes.
  static final ValueNotifier<int> coinsNotifier = ValueNotifier(AppConstants.defaultCoins);

  /// Current coin balance.
  static int get coins => coinsNotifier.value;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Load coins from persistence. Call once during app init.
  static Future<void> loadCoins() async {
    final prefs = await _getPrefs();
    final saved = prefs.getInt(AppConstants.coinKey);
    coinsNotifier.value = saved ?? AppConstants.defaultCoins;
  }

  /// Save current coin balance to persistence.
  static Future<void> _saveCoins() async {
    final prefs = await _getPrefs();
    await prefs.setInt(AppConstants.coinKey, coinsNotifier.value);
  }

  /// Add coins (e.g. after successful purchase).
  static Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    coinsNotifier.value += amount;
    await _saveCoins();
  }

  /// Subtract coins. Returns false if insufficient.
  static Future<bool> subCoins(int amount) async {
    if (amount <= 0 || coinsNotifier.value < amount) return false;
    coinsNotifier.value -= amount;
    await _saveCoins();
    return true;
  }

  /// Check if user has enough coins.
  static bool isEnough(int amount) => coinsNotifier.value >= amount;

  /// Clear all coin data (for account deletion).
  static Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.coinKey);
    coinsNotifier.value = AppConstants.defaultCoins;
  }
}
