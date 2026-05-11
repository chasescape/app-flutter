import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinsService extends GetxService {
  static const String _key = 'user_coins';
  static const int initialCoins = 100;

  final RxInt coins = 0.obs;
  final _loaded = Completer<void>();

  static CoinsService get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    coins.value = prefs.getInt(_key) ?? initialCoins;
    if (!_loaded.isCompleted) {
      _loaded.complete();
    }
  }

  Future<void> ensureLoaded() => _loaded.future;

  Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, coins.value);
  }

  Future<void> reset() async {
    coins.value = initialCoins;
    await _saveCoins();
  }

  /// 扣除金币，返回是否成功
  Future<bool> deduct(int amount) async {
    if (coins.value < amount) return false;
    coins.value -= amount;
    await _saveCoins();
    return true;
  }

  /// 增加金币
  Future<void> add(int amount) async {
    coins.value += amount;
    await _saveCoins();
  }
}
