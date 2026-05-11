import 'package:get/get.dart';
import '../services/storage_service.dart';

class CoinController extends GetxController {
  final StorageService _storage = StorageService.to;

  final RxInt coins = 0.obs;
  final RxInt freeResults = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    coins.value = _storage.getCoins();
    freeResults.value = _storage.getFreeResults();
  }

  Future<bool> purchaseCoins(int amount, int price) async {
    if (coins.value >= price) {
      await _storage.deductCoins(price);
      await addCoins(amount);
      coins.value = _storage.getCoins();
      return true;
    }
    return false;
  }

  Future<void> addCoins(int amount) async {
    await _storage.addCoins(amount);
    coins.value = _storage.getCoins();
  }

  Future<bool> useCoins(int amount) async {
    final success = await _storage.deductCoins(amount);
    if (success) {
      coins.value = _storage.getCoins();
    }
    return success;
  }

  Future<bool> useFreeResult() async {
    final success = await _storage.useFreeResult();
    if (success) {
      freeResults.value = _storage.getFreeResults();
    }
    return success;
  }

  Future<bool> canGenerateResult() async {
    if (freeResults.value > 0) return true;
    return coins.value >= 50;
  }
}
