import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Coin Service - Manages coin balance globally
class CoinService extends GetxService {
  static CoinService get to => Get.find();

  final RxInt _balance = 0.obs;
  final RxInt _freeUses = 3.obs;

  /// Get current balance
  int get balance => _balance.value;

  /// Get free uses remaining
  int get freeUses => _freeUses.value;

  /// Balance stream
  RxInt get balanceStream => _balance;

  /// Free uses stream
  RxInt get freeUsesStream => _freeUses;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  /// Load data from local storage
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _balance.value = prefs.getInt('coin_balance') ?? 100;
    _freeUses.value = prefs.getInt('free_uses') ?? 3;
  }

  /// Save data to local storage
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coin_balance', _balance.value);
    await prefs.setInt('free_uses', _freeUses.value);
  }

  /// Add coins
  Future<void> addCoins(int amount) async {
    _balance.value += amount;
    await _saveData();
  }

  /// Deduct coins
  Future<bool> deductCoins(int amount) async {
    if (_balance.value >= amount) {
      _balance.value -= amount;
      await _saveData();
      return true;
    }
    return false;
  }

  /// Use free use
  Future<bool> useFreeUse() async {
    if (_freeUses.value > 0) {
      _freeUses.value--;
      await _saveData();
      return true;
    }
    return false;
  }

  /// Check if can create achievement
  bool canCreateAchievement() {
    return _balance.value >= 50 || _freeUses.value > 0;
  }

  /// Get cost to create achievement
  int getCreationCost() {
    return _freeUses.value > 0 ? 0 : 50;
  }

  /// Reset data (for testing)
  Future<void> resetData() async {
    _balance.value = 100;
    _freeUses.value = 3;
    await _saveData();
  }

  /// Clear all coin data
  Future<void> clearBalance() async {
    _balance.value = 0;
    _freeUses.value = 0;
    await _saveData();
  }
}
