import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileLogic extends GetxController {
  static const String _kBalanceKey = 'rova.coins.balance';
  static const int _kInitialBalance = 100;

  final RxInt coins = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshCoins();
  }

  Future<void> refreshCoins() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_kBalanceKey);
    if (stored == null) {
      coins.value = _kInitialBalance;
      await prefs.setInt(_kBalanceKey, coins.value);
      return;
    }
    coins.value = stored;
  }
}
