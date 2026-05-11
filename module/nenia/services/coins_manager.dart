import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class CoinsManager extends GetxService {
  static CoinsManager get to => Get.find<CoinsManager>();

  static const String _coinsKey = 'user_coins';
  static const int _defaultCoins = 100;

  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);

  int get currentCoins => coinsNotifier.value;

  @override
  void onInit() {
    super.onInit();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    try {
      final storage = Get.find<StorageService>();
      final coins = await storage.getInt(_coinsKey);
      coinsNotifier.value = coins ?? _defaultCoins;
    } catch (e) {
      debugPrint('Error loading coins: $e');
      coinsNotifier.value = _defaultCoins;
    }
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    coinsNotifier.value += amount;
    await _saveCoins();
  }

  Future<void> subCoins(int amount) async {
    if (amount <= 0) return;

    if (!isEnough(amount)) {
      throw Exception('Insufficient coins');
    }

    coinsNotifier.value -= amount;
    await _saveCoins();
  }

  bool isEnough(int amount) {
    return coinsNotifier.value >= amount;
  }

  Future<void> _saveCoins() async {
    try {
      final storage = Get.find<StorageService>();
      await storage.setInt(_coinsKey, coinsNotifier.value);
    } catch (e) {
      debugPrint('Error saving coins: $e');
    }
  }

  Future<void> clear() async {
    coinsNotifier.value = _defaultCoins;
    try {
      final storage = Get.find<StorageService>();
      await storage.remove(_coinsKey);
    } catch (e) {
      debugPrint('Error clearing coins: $e');
    }
  }

  @override
  void onClose() {
    coinsNotifier.dispose();
    super.onClose();
  }
}
