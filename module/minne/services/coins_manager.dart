import 'package:flutter/foundation.dart';
import '../data/datasources/local_storage.dart';

/// Coins Manager - Unified coin management with persistence
/// Provides ValueNotifier for reactive UI updates and persistent storage
class CoinsManager extends ChangeNotifier {
  CoinsManager._();

  static CoinsManager? _instance;
  factory CoinsManager() => _instance ??= CoinsManager._();

  // Current coin balance (cached for synchronous access)
  int _coins = 0;

  // ValueNotifier for reactive updates
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);

  // Initialize flag
  bool _isInitialized = false;

  /// Get current coin balance (synchronous)
  int get coins => _coins;

  /// Check if coins have been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize coins from persistent storage
  /// Call this on app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _coins = await LocalStorage.getCoins();
      coinsNotifier.value = _coins;
      _isInitialized = true;
      debugPrint('CoinsManager: Initialized with $_coins coins');
    } catch (e) {
      debugPrint('CoinsManager: Initialization failed - $e');
      _coins = 0;
      coinsNotifier.value = 0;
      _isInitialized = true;
    }
  }

  /// Add coins to balance
  /// Returns the new balance
  Future<int> addCoins(int amount) async {
    if (amount <= 0) return _coins;

    try {
      await LocalStorage.addCoins(amount);
      _coins = await LocalStorage.getCoins();
      coinsNotifier.value = _coins;
      notifyListeners();
      debugPrint('CoinsManager: Added $amount coins, new balance: $_coins');
      return _coins;
    } catch (e) {
      debugPrint('CoinsManager: Failed to add coins - $e');
      return _coins;
    }
  }

  /// Subtract coins from balance
  /// Returns true if successful, false if insufficient coins
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return true;

    if (!isEnoughCoins(amount)) {
      debugPrint('CoinsManager: Insufficient coins (required: $amount, available: $_coins)');
      return false;
    }

    try {
      await LocalStorage.subCoins(amount);
      _coins = await LocalStorage.getCoins();
      coinsNotifier.value = _coins;
      notifyListeners();
      debugPrint('CoinsManager: Subtracted $amount coins, new balance: $_coins');
      return true;
    } catch (e) {
      debugPrint('CoinsManager: Failed to subtract coins - $e');
      return false;
    }
  }

  /// Set coins to a specific value
  Future<void> setCoins(int amount) async {
    if (amount < 0) return;

    try {
      await LocalStorage.setCoins(amount);
      _coins = amount;
      coinsNotifier.value = _coins;
      notifyListeners();
      debugPrint('CoinsManager: Set coins to $amount');
    } catch (e) {
      debugPrint('CoinsManager: Failed to set coins - $e');
    }
  }

  /// Check if user has enough coins
  bool isEnoughCoins(int required) {
    return _coins >= required;
  }

  /// Refresh coins from persistent storage
  /// Use this to sync coins after external changes
  Future<void> refresh() async {
    try {
      _coins = await LocalStorage.getCoins();
      coinsNotifier.value = _coins;
      notifyListeners();
      debugPrint('CoinsManager: Refreshed coins, current balance: $_coins');
    } catch (e) {
      debugPrint('CoinsManager: Failed to refresh coins - $e');
    }
  }

  /// Clear all coins data
  /// Call this when user logs out or deletes account
  Future<void> clear() async {
    try {
      await LocalStorage.setCoins(0);
      _coins = 0;
      coinsNotifier.value = 0;
      notifyListeners();
      debugPrint('CoinsManager: Cleared all coins');
    } catch (e) {
      debugPrint('CoinsManager: Failed to clear coins - $e');
    }
  }

  @override
  void dispose() {
    coinsNotifier.dispose();
    super.dispose();
  }
}
