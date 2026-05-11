import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

/// Unified coins management service
/// Provides centralized coin management with ValueNotifier for reactive updates
class CoinsManager extends GetxService {
  static CoinsManager get to => Get.find();

  final StorageService _storage = StorageService.to;

  /// Current coins value notifier for reactive listening
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);

  /// Current coins count
  int get currentCoins => coinsNotifier.value;

  @override
  void onInit() {
    super.onInit();
    _loadCoins();
  }

  /// Load coins from storage
  Future<void> _loadCoins() async {
    final userData = await _storage.getUserData();
    coinsNotifier.value = userData.coins;
  }

  /// Add coins to user account
  /// Returns the new coin balance
  Future<int> addCoins(int amount) async {
    if (amount <= 0) return currentCoins;

    await _storage.updateCoins(amount);
    await _loadCoins();
    return currentCoins;
  }

  /// Subtract coins from user account
  /// Returns true if successful, false if insufficient coins
  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return true;
    if (!isEnough(amount)) return false;

    await _storage.updateCoins(-amount);
    await _loadCoins();
    return true;
  }

  /// Check if user has enough coins
  bool isEnough(int amount) {
    return currentCoins >= amount;
  }

  /// Refresh coins from storage
  Future<void> refresh() async {
    await _loadCoins();
  }

  /// Clear all coins data (for account deletion)
  Future<void> clear() async {
    await _storage.updateCoins(-currentCoins);
    coinsNotifier.value = 0;
  }

  @override
  void onClose() {
    coinsNotifier.dispose();
    super.onClose();
  }
}
