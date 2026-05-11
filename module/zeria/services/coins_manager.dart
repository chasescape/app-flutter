import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeria/zeria/constants/app_constants.dart';

/// Coins Manager - Unified coin management with ValueNotifier
/// Uses existing SharedPreferences for persistence
class CoinsManager {
  CoinsManager._privateConstructor();

  static final CoinsManager _instance = CoinsManager._privateConstructor();

  static CoinsManager get instance => _instance;

  static CoinsManager get I => instance;

  /// ValueNotifier for reactive coin updates
  final ValueNotifier<int> coinsNotifier =
      ValueNotifier<int>(AppConstants.defaultCoins);

  SharedPreferences? _prefs;

  /// Initialize the coins manager
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _loadCoins();
  }

  /// Load coins from storage
  void _loadCoins() {
    if (_prefs == null) return;
    final coins =
        _prefs!.getInt(AppConstants.keyCoins) ?? AppConstants.defaultCoins;
    coinsNotifier.value = coins;
  }

  /// Get current coins value
  int get currentCoins => coinsNotifier.value;

  /// Add coins (for purchase completion)
  Future<void> addCoins(int amount) async {
    if (_prefs == null) await init();
    final newCoins = currentCoins + amount;
    await _prefs!.setInt(AppConstants.keyCoins, newCoins);
    coinsNotifier.value = newCoins;
  }

  /// Subtract coins (for consumption)
  Future<bool> subCoins(int amount) async {
    if (_prefs == null) await init();
    if (currentCoins < amount) return false;
    final newCoins = currentCoins - amount;
    await _prefs!.setInt(AppConstants.keyCoins, newCoins);
    coinsNotifier.value = newCoins;
    return true;
  }

  /// Check if user has enough coins
  bool isEnough(int amount) {
    return currentCoins >= amount;
  }

  /// Set coins directly (for initialization)
  Future<void> setCoins(int amount) async {
    if (_prefs == null) await init();
    await _prefs!.setInt(AppConstants.keyCoins, amount);
    coinsNotifier.value = amount;
  }

  /// Clear all coins data (for account deletion)
  Future<void> clear() async {
    if (_prefs == null) await init();
    await _prefs!.remove(AppConstants.keyCoins);
    coinsNotifier.value = AppConstants.defaultCoins;
  }

  /// Dispose the notifier
  void dispose() {
    coinsNotifier.dispose();
  }
}
