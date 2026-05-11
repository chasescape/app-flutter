import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Coins Manager - Unified coin management with persistence
/// Provides global access point for all coin operations
class CoinsManager {
  CoinsManager._();

  static CoinsManager? _instance;
  static CoinsManager get I => _instance ??= CoinsManager._();

  // Storage key
  static const String _kCoinsKey = 'user_coins';
  static const int _kDefaultCoins = 100;

  // ValueNotifier for reactive UI updates
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(_kDefaultCoins);

  // Initial coins flag
  bool _isInitialized = false;

  /// Initialize coins from persistent storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final coins = prefs.getInt(_kCoinsKey) ?? _kDefaultCoins;
      coinsNotifier.value = coins;
      _isInitialized = true;
      debugPrint('CoinsManager: Initialized with $coins coins');
    } catch (e) {
      debugPrint('CoinsManager: Failed to initialize - $e');
      coinsNotifier.value = _kDefaultCoins;
      _isInitialized = true;
    }
  }

  /// Get current coins value
  int get currentCoins => coinsNotifier.value;

  /// Add coins to balance and persist
  Future<void> addCoins(int amount) async {
    if (amount <= 0) {
      debugPrint('CoinsManager: Invalid add amount - $amount');
      return;
    }

    try {
      final newBalance = coinsNotifier.value + amount;
      await _saveCoins(newBalance);
      coinsNotifier.value = newBalance;
      debugPrint('CoinsManager: Added $amount coins, new balance: $newBalance');
    } catch (e) {
      debugPrint('CoinsManager: Failed to add coins - $e');
    }
  }

  /// Subtract coins from balance if sufficient
  /// Returns true if successful, false if insufficient coins
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) {
      debugPrint('CoinsManager: Invalid subtract amount - $amount');
      return false;
    }

    if (!isEnough(amount)) {
      debugPrint('CoinsManager: Insufficient coins - required: $amount, current: ${coinsNotifier.value}');
      return false;
    }

    try {
      final newBalance = coinsNotifier.value - amount;
      await _saveCoins(newBalance);
      coinsNotifier.value = newBalance;
      debugPrint('CoinsManager: Subtracted $amount coins, new balance: $newBalance');
      return true;
    } catch (e) {
      debugPrint('CoinsManager: Failed to subtract coins - $e');
      return false;
    }
  }

  /// Check if user has enough coins
  bool isEnough(int amount) {
    return coinsNotifier.value >= amount;
  }

  /// Save coins to persistent storage
  Future<void> _saveCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kCoinsKey, coins);
    } catch (e) {
      debugPrint('CoinsManager: Failed to save coins - $e');
      rethrow;
    }
  }

  /// Clear all coins data (for logout/account deletion)
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kCoinsKey);
      coinsNotifier.value = _kDefaultCoins;
      _isInitialized = false;
      debugPrint('CoinsManager: Data cleared, reset to default');
    } catch (e) {
      debugPrint('CoinsManager: Failed to clear data - $e');
    }
  }

  /// Reset coins to default value
  Future<void> resetToDefault() async {
    await _saveCoins(_kDefaultCoins);
    coinsNotifier.value = _kDefaultCoins;
    debugPrint('CoinsManager: Reset to default $_kDefaultCoins coins');
  }

  /// Dispose
  void dispose() {
    coinsNotifier.dispose();
  }
}


/// Coins Widget - Helper widget for building coin-related UI
class CoinsBuilder extends StatelessWidget {
  final Widget Function(int coins) builder;

  const CoinsBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: CoinsManager.I.coinsNotifier,
      builder: (context, coins, _) {
        return builder(coins);
      },
    );
  }
}
