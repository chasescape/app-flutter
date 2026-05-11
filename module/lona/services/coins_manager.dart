import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class CoinsManager extends GetxService {
  static CoinsManager get to => Get.find();

  final StorageService _storage = StorageService.to;
  final ValueNotifier<int> _coinsNotifier = ValueNotifier(0);
  final ValueNotifier<int> _freeCreditsNotifier = ValueNotifier(0);

  ValueNotifier<int> get coinsNotifier => _coinsNotifier;
  ValueNotifier<int> get freeCreditsNotifier => _freeCreditsNotifier;

  int get coins => _coinsNotifier.value;
  int get freeCredits => _freeCreditsNotifier.value;
  int get costPerAnalysis => _storage.getCostPerAnalysis();

  @override
  void onInit() {
    super.onInit();
    _loadCoins();
  }

  void _loadCoins() {
    _coinsNotifier.value = _storage.coins;
    _freeCreditsNotifier.value = _storage.freeCredits;
    debugPrint('CoinsManager loaded: coins=$coins, freeCredits=$freeCredits');
  }

  Future<void> refresh() async {
    _loadCoins();
  }

  Future<void> addCoins(int amount) async {
    await _storage.addCoins(amount);
    _coinsNotifier.value = _storage.coins;
    debugPrint('Added $amount coins, total: $coins');
  }

  Future<bool> subCoins(int amount) async {
    if (!isEnough(amount)) {
      debugPrint('Insufficient coins: have $coins, need $amount');
      return false;
    }
    final success = await _storage.spendCoins(amount);
    if (success) {
      _coinsNotifier.value = _storage.coins;
      debugPrint('Subtracted $amount coins, remaining: $coins');
    }
    return success;
  }

  bool isEnough(int amount) {
    return coins >= amount;
  }

  bool get canAnalyze => coins >= costPerAnalysis || freeCredits > 0;

  Future<void> decrementFreeCredits() async {
    await _storage.decrementFreeCredits();
    _freeCreditsNotifier.value = _storage.freeCredits;
    debugPrint('Decremented free credits, remaining: $freeCredits');
  }

  Future<void> clear() async {
    await _storage.setCoins(0);
    await _storage.setFreeCredits(0);
    _coinsNotifier.value = 0;
    _freeCreditsNotifier.value = 0;
    debugPrint('CoinsManager cleared');
  }

  void dispose() {
    _coinsNotifier.dispose();
    _freeCreditsNotifier.dispose();
  }
}
