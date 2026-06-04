import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Coins Manager - Unified coin management with persistence
/// Provides singleton access to coin balance and real-time updates
class CoinsManager extends ChangeNotifier {
  CoinsManager._internal();

  static final CoinsManager _instance = CoinsManager._internal();

  /// Singleton instance
  static CoinsManager get instance => _instance;

  /// Coin balance
  int _coins = 0;

  /// Current coin balance
  int get coins => _coins;

  /// Initialize manager and load coins from storage
  Future<void> initialize() async {
    _coins = await StorageService.loadCoinBalance();
    notifyListeners();
  }

  /// Add coins to balance
  /// Returns the new balance
  int addCoins(int amount) {
    if (amount <= 0) return _coins;
    _coins += amount;
    _persistAndNotify();
    return _coins;
  }

  /// Subtract coins from balance
  /// Returns true if successful, false if insufficient coins
  bool subCoins(int amount) {
    if (amount <= 0) return true;
    if (!isEnough(amount)) return false;
    _coins -= amount;
    _persistAndNotify();
    return true;
  }

  /// Check if user has enough coins
  bool isEnough(int amount) {
    return _coins >= amount;
  }

  /// Set coin balance directly (for initialization or restore)
  void setCoins(int amount) {
    _coins = amount;
    _persistAndNotify();
  }

  /// Clear all coin data (for account deletion)
  Future<void> clear() async {
    _coins = 0;
    await StorageService.saveCoinBalance(0);
    notifyListeners();
  }

  /// Persist coins to storage and notify listeners
  void _persistAndNotify() {
    StorageService.saveCoinBalance(_coins);
    notifyListeners();
  }
}
