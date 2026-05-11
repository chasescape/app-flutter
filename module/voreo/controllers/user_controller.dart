import 'package:get/get.dart';
import '../models/user_data.dart';
import '../models/hairstyle_result.dart';
import '../services/storage_service.dart';
import '../services/coins_manager.dart';

class UserController extends GetxController {
  final StorageService _storage = StorageService.to;
  final CoinsManager _coinsManager = CoinsManager.to;

  final Rx<UserData?> userData = Rx<UserData?>(null);
  final RxInt freeAttempts = 0.obs;
  final RxList<HairstyleResult> history = <HairstyleResult>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();

    // Listen to coin balance changes
    _coinsManager.coinBalanceNotifier.addListener(_onCoinBalanceChanged);
  }

  void _onCoinBalanceChanged() {
    // Update userData when coin balance changes
    final data = userData.value;
    if (data != null && data.coinBalance != _coinsManager.currentBalance) {
      userData.value = data.copyWith(coinBalance: _coinsManager.currentBalance);
    }
  }

  void _loadUserData() {
    final data = _storage.getUserData();
    if (data != null) {
      userData.value = data;
      freeAttempts.value = data.freeAttempts;
      history.value = data.history;
      // Sync coin balance with CoinsManager
      _coinsManager.coinBalanceNotifier.value = data.coinBalance;
    } else {
      // Initialize new user with random free attempts (1-3)
      _initializeNewUser();
    }
  }

  void _initializeNewUser() {
    final randomAttempts = 1 + (DateTime.now().millisecond % 3);
    final newData = UserData(
      userId:
          _storage.userId ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      coinBalance: 100,
      freeAttempts: randomAttempts,
      history: [],
    );
    _saveUserData(newData);
  }

  void _saveUserData(UserData data) {
    userData.value = data;
    freeAttempts.value = data.freeAttempts;
    history.value = data.history;
    _storage.saveUserData(data);
  }

  // Coin balance getter from CoinsManager
  RxInt get coinBalance => _coinsManager.coinBalanceNotifier as RxInt;

  bool get canGenerate => _coinsManager.isEnough(99);

  int get estimatedCost {
    return 99;
  }

  Future<bool> spendForGeneration() async {
    if (freeAttempts.value > 0) {
      final success = await _storage.useFreeAttempt();
      if (success) {
        final data = userData.value!;
        _saveUserData(data.copyWith(freeAttempts: data.freeAttempts - 1));
        return true;
      }
    } else {
      final cost = estimatedCost;
      final success = await _coinsManager.subCoins(cost);
      if (success) {
        final data = userData.value!;
        _saveUserData(data.copyWith(coinBalance: _coinsManager.currentBalance));
        return true;
      }
    }
    return false;
  }

  Future<void> addCoins(int amount) async {
    await _coinsManager.addCoins(amount);
    final data = userData.value!;
    _saveUserData(data.copyWith(coinBalance: _coinsManager.currentBalance));
  }

  Future<void> addHistoryItem(HairstyleResult result) async {
    await _storage.addHistoryItem(result);
    final data = userData.value!;
    _saveUserData(data.copyWith(history: [result, ...data.history]));
  }

  Future<void> deleteHistoryItem(String id) async {
    await _storage.deleteHistoryItem(id);
    final data = userData.value!;
    _saveUserData(data.copyWith(
      history: data.history.where((item) => item.id != id).toList(),
    ));
  }

  Future<void> clearHistory() async {
    await _storage.clearHistory();
    final data = userData.value!;
    _saveUserData(data.copyWith(history: []));
  }

  void refreshData() {
    _loadUserData();
  }

  // Clear all user data (for logout/delete account)
  Future<void> clearAllData() async {
    await _coinsManager.clear();
    await _storage.clearAllData();
    userData.value = null;
    freeAttempts.value = 0;
    history.value = [];
  }

  @override
  void onClose() {
    _coinsManager.coinBalanceNotifier.removeListener(_onCoinBalanceChanged);
    super.onClose();
  }
}
