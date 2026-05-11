import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinsWalletStore extends GetxController {
  static const String _key = 'coins_wallet_balance';

  int balance = 100;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void add(int amount) {
    balance += amount;
    update();
    _save();
  }

  bool spend(int amount) {
    if (balance < amount) {
      return false;
    }
    balance -= amount;
    update();
    _save();
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    balance = prefs.getInt(_key) ?? 100;
    update();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, balance);
  }

  Future<void> clear() async {
    balance = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, balance);
    update();
  }
}
