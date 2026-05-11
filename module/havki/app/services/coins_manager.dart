import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Coins Manager - Unified coin management using project's existing SharedPreferences
/// Key features:
/// - Singleton pattern for global access
/// - ValueNotifier for reactive UI updates
/// - Thread-safe operations
/// - Persistent storage
class CoinsManager {
  static const int _defaultCoins = 100;

  // Singleton pattern
  static final CoinsManager _instance = CoinsManager._internal();
  factory CoinsManager() => _instance;
  CoinsManager._internal();

  // SharedPreferences key
  static const String _keyCoins = 'user_coins';

  // Reactive state
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(_defaultCoins);

  // Local storage
  SharedPreferences? _prefs;

  /// Initialize manager and load coins from storage
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedCoins = _prefs?.getInt(_keyCoins) ?? _defaultCoins;
    coinsNotifier.value = savedCoins;
    debugPrint('CoinsManager: Initialized with $savedCoins coins');
  }

  /// Get current coins (synchronous access)
  int get currentCoins => coinsNotifier.value;

  /// Add coins to user balance
  /// [amount] - Number of coins to add
  /// Returns true if successful
  Future<bool> addCoins(int amount) async {
    if (amount <= 0) return false;

    final newBalance = coinsNotifier.value + amount;
    coinsNotifier.value = newBalance;

    // Persist to storage
    final success = await _prefs?.setInt(_keyCoins, newBalance) ?? false;
    debugPrint('CoinsManager: Added $amount coins, new balance: $newBalance');
    return success;
  }

  /// Subtract coins from user balance
  /// [amount] - Number of coins to subtract
  /// Returns true if successful, false if insufficient coins
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return false;
    if (!isEnough(amount)) {
      debugPrint('CoinsManager: Insufficient coins - need $amount, have ${coinsNotifier.value}');
      return false;
    }

    final newBalance = coinsNotifier.value - amount;
    coinsNotifier.value = newBalance;

    // Persist to storage
    final success = await _prefs?.setInt(_keyCoins, newBalance) ?? false;
    debugPrint('CoinsManager: Subtracted $amount coins, new balance: $newBalance');
    return success;
  }

  /// Check if user has enough coins
  /// [amount] - Required amount
  /// Returns true if user has sufficient coins
  bool isEnough(int amount) {
    return coinsNotifier.value >= amount;
  }

  /// Set coins to a specific value (for initial setup or corrections)
  /// [amount] - New coin balance
  Future<bool> setCoins(int amount) async {
    if (amount < 0) return false;

    coinsNotifier.value = amount;

    // Persist to storage
    final success = await _prefs?.setInt(_keyCoins, amount) ?? false;
    debugPrint('CoinsManager: Set coins to $amount');
    return success;
  }

  /// Clear all coin data (for account deletion)
  /// Resets to default 100 coins and clears storage
  Future<void> clear() async {
    coinsNotifier.value = _defaultCoins;
    await _prefs?.remove(_keyCoins);
    debugPrint('CoinsManager: Cleared all data, reset to $_defaultCoins coins');
  }

  /// Dispose resources
  void dispose() {
    coinsNotifier.dispose();
  }
}
