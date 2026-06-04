import 'package:flutter/foundation.dart';

import '../core/storage/local_storage.dart';

class CoinsManager {
  CoinsManager._();

  static final CoinsManager _instance = CoinsManager._();

  static CoinsManager get instance => _instance;

  final ValueNotifier<int> _balanceNotifier = ValueNotifier<int>(0);

  ValueNotifier<int> get balanceNotifier => _balanceNotifier;
  int get balance => _balanceNotifier.value;

  void init() {
    _balanceNotifier.value = LocalStorage.instance.coins;
  }

  void addCoins(int amount) {
    if (amount <= 0) return;
    final newBalance = balance + amount;
    LocalStorage.instance.coins = newBalance;
    _balanceNotifier.value = newBalance;
  }

  bool canSpend(int amount) {
    if (amount <= 0) return true;
    return balance >= amount;
  }

  bool spendCoins(int amount) {
    if (amount <= 0) return true;
    if (!canSpend(amount)) return false;
    final newBalance = balance - amount;
    LocalStorage.instance.coins = newBalance;
    _balanceNotifier.value = newBalance;
    return true;
  }

  void clear() {
    LocalStorage.instance.coins = 0;
    _balanceNotifier.value = 0;
  }
}
