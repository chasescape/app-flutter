import 'package:flutter/foundation.dart';

class CoinWallet {
  CoinWallet._();

  static final ValueNotifier<int> balance = ValueNotifier<int>(0);

  static void add(int amount) {
    if (amount <= 0) {
      return;
    }
    balance.value += amount;
  }

  static bool spend(int amount) {
    if (amount <= 0) {
      return true;
    }
    if (balance.value < amount) {
      return false;
    }
    balance.value -= amount;
    return true;
  }
}
