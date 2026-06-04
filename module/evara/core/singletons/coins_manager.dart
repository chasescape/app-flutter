import 'dart:async';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Coins Manager - Singleton Pattern
/// Manages user coins with ValueNotifier for reactive updates
abstract class CoinsManager {
  static CoinsManager? _instance;

  static void setInstance(CoinsManager manager) {
    _instance = manager;
  }

  static CoinsManager get instance {
    _instance ??= _CoinsManagerImpl._();
    return _instance!;
  }

  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  // Abstract methods
  ValueNotifier<int> get coinsNotifier;
  Future<int> getCoins();
  Future<void> setCoins(int coins);
  Future<void> addCoins(int amount);
  Future<bool> subCoins(int amount);
  bool isEnough(int amount);
  Future<void> clear();
}

/// Implementation
class _CoinsManagerImpl implements CoinsManager {
  _CoinsManagerImpl._() {
    _init();
  }

  final StorageService _storage = StorageService.instance;
  final ValueNotifier<int> _coinsNotifier = ValueNotifier<int>(0);

  @override
  ValueNotifier<int> get coinsNotifier => _coinsNotifier;

  void _init() async {
    final coins = await getCoins();
    _coinsNotifier.value = coins;
  }

  @override
  Future<int> getCoins() async {
    return await _storage.loadInt(StorageKeys.userCoins) ?? 0;
  }

  @override
  Future<void> setCoins(int coins) async {
    if (coins < 0) coins = 0;
    await _storage.saveInt(StorageKeys.userCoins, coins);
    _coinsNotifier.value = coins;
  }

  @override
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    final current = await getCoins();
    await setCoins(current + amount);
  }

  @override
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return true;
    final current = await getCoins();
    if (current < amount) return false;
    await setCoins(current - amount);
    return true;
  }

  @override
  bool isEnough(int amount) {
    return _coinsNotifier.value >= amount;
  }

  @override
  Future<void> clear() async {
    await setCoins(0);
  }
}
