import 'package:flutter/foundation.dart';
import 'package:pliro/pliro/core/storage/storage_service.dart';

/// Coins manager - unified coin balance management with reactive updates
class CoinsManager {
  CoinsManager._internal();

  static CoinsManager? _instance;

  static CoinsManager get instance {
    _instance ??= CoinsManager._internal();
    return _instance!;
  }

  final StorageService _storage = StorageService.instance;

  /// ValueNotifier for reactive coin balance updates
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);

  /// Current coin balance (cached value)
  int get currentCoins => coinsNotifier.value;

  /// Initialize - load coins from storage
  Future<void> init() async {
    final coins = await _storage.getCoins();
    coinsNotifier.value = coins;
  }

  /// Add coins to balance
  /// Returns the new balance
  Future<int> addCoins(int amount) async {
    if (amount <= 0) return currentCoins;

    await _storage.addCoins(amount);
    final newBalance = await _storage.getCoins();
    coinsNotifier.value = newBalance;
    return newBalance;
  }

  /// Subtract coins from balance
  /// Returns true if successful, false if insufficient coins
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return true;

    final current = await _storage.getCoins();
    if (current < amount) return false;

    await _storage.setCoins(current - amount);
    coinsNotifier.value = current - amount;
    return true;
  }

  /// Check if user has enough coins
  Future<bool> isEnough(int amount) async {
    final current = await _storage.getCoins();
    return current >= amount;
  }

  /// Set coins directly
  Future<void> setCoins(int coins) async {
    await _storage.setCoins(coins);
    coinsNotifier.value = coins;
  }

  /// Reload coins from storage
  Future<void> reload() async {
    final coins = await _storage.getCoins();
    coinsNotifier.value = coins;
  }

  /// Clear all coin data
  Future<void> clear() async {
    await _storage.setCoins(0);
    coinsNotifier.value = 0;
  }

  /// Dispose the notifier when done
  void dispose() {
    coinsNotifier.dispose();
  }
}
