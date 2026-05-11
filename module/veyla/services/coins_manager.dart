import 'package:flutter/foundation.dart';
import '../core/mixin/singleton_mixin.dart';
import 'storage_service.dart';
import '../models/coin_package.dart';

class CoinsManager with SingletonMixin<CoinsManager> {
  CoinsManager._();

  static CoinsManager get instance =>
      SingletonMixin.getInstance(() => CoinsManager._());

  final StorageService _storage = StorageService.instance;
  final ValueNotifier<int> _coinsNotifier = ValueNotifier<int>(0);

  ValueNotifier<int> get coinsNotifier => _coinsNotifier;

  int get currentCoins => _coinsNotifier.value;

  Future<void> initialize() async {
    await _storage.initialize();
    _coinsNotifier.value = _storage.coins;
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    final newAmount = currentCoins + amount;
    await _storage.setCoins(newAmount);
    _coinsNotifier.value = newAmount;
  }

  Future<void> subCoins(int amount) async {
    if (amount <= 0) return;
    final newAmount = currentCoins - amount;
    if (newAmount < 0) return;
    await _storage.setCoins(newAmount);
    _coinsNotifier.value = newAmount;
  }

  bool isEnough(int amount) {
    return currentCoins >= amount;
  }

  Future<void> setCoins(int amount) async {
    await _storage.setCoins(amount);
    _coinsNotifier.value = amount;
  }

  Future<void> clear() async {
    await _storage.setCoins(CoinPackages.initialCoins);
    _coinsNotifier.value = _storage.coins;
  }

  void dispose() {
    _coinsNotifier.dispose();
  }
}
