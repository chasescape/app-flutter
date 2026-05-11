import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';
import '../global_service.dart';

/// Coins Manager - Unified Coin Management
/// Provides centralized access to coin balance across the app
class CoinsManager extends ValueNotifier<int> {
  static const int defaultBalance = 100;
  static CoinsManager? _instance;

  static CoinsManager get instance {
    _instance ??= CoinsManager._internal();
    return _instance!;
  }

  late final Future<void> _ready;

  CoinsManager._internal() : super(defaultBalance) {
    _ready = _loadBalance();
  }

  final GlobalService _globalService = GlobalService.to;
  final StorageService _storage = StorageService.instance;

  Future<void> _ensureReady() => _ready;

  /// Load balance from storage
  Future<void> _loadBalance() async {
    try {
      final balanceStr = await _storage.getString(StorageKeys.coinBalance);
      final parsedBalance = int.tryParse(balanceStr ?? '');
      final balance = parsedBalance == null || parsedBalance < 0
          ? defaultBalance
          : parsedBalance;
      value = balance;
      await _globalService.updateCoinBalance(balance.toString());
      debugPrint('CoinsManager: Loaded balance = $balance');
    } catch (e) {
      debugPrint('CoinsManager: Error loading balance - $e');
      value = defaultBalance;
      await _globalService.updateCoinBalance(defaultBalance.toString());
    }
  }

  /// Add coins to balance
  Future<void> addCoins(int coins) async {
    if (coins <= 0) return;
    await _ensureReady();

    final newBalance = value + coins;
    value = newBalance;

    await _globalService.updateCoinBalance(newBalance.toString());
    debugPrint('CoinsManager: Added $coins coins, new balance = $newBalance');
  }

  /// Subtract coins from balance
  Future<bool> subCoins(int coins) async {
    if (coins <= 0) return true;
    await _ensureReady();

    if (!isEnough(coins)) {
      debugPrint('CoinsManager: Not enough coins (need $coins, have $value)');
      return false;
    }

    final newBalance = value - coins;
    value = newBalance;

    await _globalService.updateCoinBalance(newBalance.toString());
    debugPrint(
        'CoinsManager: Subtracted $coins coins, new balance = $newBalance');
    return true;
  }

  /// Check if enough coins available
  bool isEnough(int coins) {
    return value >= coins;
  }

  /// Get current balance as string
  String get balanceString => value.toString();

  /// Get current balance
  int get balance => value;

  /// Clear all coin data
  Future<void> clear() async {
    await _ensureReady();
    value = 0;
    await _globalService.updateCoinBalance('0');
    debugPrint('CoinsManager: Cleared all coin data');
  }

  /// Refresh balance from storage
  Future<void> refresh() async {
    await _ensureReady();
    await _loadBalance();
  }
}
