import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class CoinManager extends GetxController {
  static CoinManager get to => Get.find();

  static const _keyCoins = 'coin_balance';
  static const _keyFreeCount = 'free_count';
  static const _keyInitialized = 'free_initialized';
  static const int initialCoins = 100;

  static const int costPerToolUse = 42;

  final coins = 0.obs;
  final freeCount = 0.obs;

  bool get hasFreeUses => freeCount.value > 0;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_keyCoins)) {
      coins.value = prefs.getInt(_keyCoins) ?? 0;
    } else {
      coins.value = initialCoins;
      await prefs.setInt(_keyCoins, initialCoins);
    }

    final initialized = prefs.getBool(_keyInitialized) ?? false;
    if (!initialized) {
      freeCount.value = Random().nextInt(3) + 1;
      await prefs.setInt(_keyFreeCount, freeCount.value);
      await prefs.setBool(_keyInitialized, true);
    } else {
      freeCount.value = prefs.getInt(_keyFreeCount) ?? 0;
    }
  }

  Future<void> addCoins(int amount) async {
    coins.value += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoins, coins.value);
  }

  Future<void> subCoins(int amount) async {
    coins.value -= amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoins, coins.value);
  }

  bool isEnough(int amount) => coins.value >= amount;

  Future<bool> consumeToolUse() async {
    final prefs = await SharedPreferences.getInstance();
    if (hasFreeUses) {
      freeCount.value--;
      await prefs.setInt(_keyFreeCount, freeCount.value);
      return true;
    }
    if (coins.value >= costPerToolUse) {
      coins.value -= costPerToolUse;
      await prefs.setInt(_keyCoins, coins.value);
      return true;
    }
    return false;
  }

  Future<void> clearAll() async {
    coins.value = 0;
    freeCount.value = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCoins);
    await prefs.remove(_keyFreeCount);
    await prefs.remove(_keyInitialized);
  }
}
