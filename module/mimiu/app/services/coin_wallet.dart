import 'package:shared_preferences/shared_preferences.dart';

class CoinWallet {
  static const String balanceKey = 'coins_balance_v1';
  static const String signupBonusKey = 'coins_signup_bonus_v1';

  Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(balanceKey) ?? 0;
  }

  Future<void> setBalance(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(balanceKey, value < 0 ? 0 : value);
  }

  Future<void> add(int amount) async {
    final cur = await getBalance();
    await setBalance(cur + amount);
  }

  /// Grants a one-time signup bonus.
  Future<bool> ensureSignupBonus({int amount = 100}) async {
    final prefs = await SharedPreferences.getInstance();
    final granted = prefs.getBool(signupBonusKey) ?? false;
    if (granted) return false;
    await add(amount);
    await prefs.setBool(signupBonusKey, true);
    return true;
  }

  /// Spends up to [amount] coins. Returns `true` when successful.
  Future<bool> spend(int amount) async {
    if (amount <= 0) return true;
    final cur = await getBalance();
    if (cur < amount) return false;
    await setBalance(cur - amount);
    return true;
  }
}
