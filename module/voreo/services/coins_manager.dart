import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class CoinsManager extends GetxService {
  static CoinsManager get to => Get.find();

  final StorageService _storage = StorageService.to;

  // ValueNotifier for coin balance changes
  final ValueNotifier<int> coinBalanceNotifier = ValueNotifier<int>(0);

  // Getter for current balance
  int get currentBalance => _storage.coinBalance;

  // Initialize with current balance
  Future<CoinsManager> init() async {
    coinBalanceNotifier.value = currentBalance;
    return this;
  }

  // Add coins to balance
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    await _storage.addCoins(amount);
    coinBalanceNotifier.value = currentBalance;
    debugPrint('CoinsManager: Added $amount coins, new balance: ${currentBalance}');
  }

  // Subtract coins from balance
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return true;
    if (!isEnough(amount)) return false;

    final success = await _storage.spendCoins(amount);
    if (success) {
      coinBalanceNotifier.value = currentBalance;
      debugPrint('CoinsManager: Spent $amount coins, new balance: ${currentBalance}');
    }
    return success;
  }

  // Check if user has enough coins
  bool isEnough(int amount) {
    return currentBalance >= amount;
  }

  // Set balance directly (useful for testing or admin actions)
  Future<void> setBalance(int balance) async {
    await _storage.setCoinBalance(balance);
    coinBalanceNotifier.value = currentBalance;
    debugPrint('CoinsManager: Set balance to $balance');
  }

  // Clear all coin data
  Future<void> clear() async {
    coinBalanceNotifier.value = 0;
    await _storage.setCoinBalance(0);
    debugPrint('CoinsManager: Cleared all coin data');
  }

  @override
  void onClose() {
    coinBalanceNotifier.dispose();
    super.onClose();
  }
}
