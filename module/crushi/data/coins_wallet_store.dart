import 'package:shared_preferences/shared_preferences.dart';

class CoinsWalletStore {
  static const String _key = 'coins_balance';

  int _balance = 0;
  int get balance => _balance;
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_key) ?? 120;
    _loaded = true;
  }

  Future<void> add(int coins) async {
    await _ensureLoaded();
    _balance += coins;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _balance);
  }

  Future<bool> spend(int coins) async {
    if (coins <= 0) return true;
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_key) ?? _balance;
    if (_balance < coins) return false;
    _balance -= coins;
    await prefs.setInt(_key, _balance);
    return true;
  }

  Future<void> refund(int coins) async {
    if (coins <= 0) return;
    await add(coins);
  }

  Future<void> clear() async {
    _balance = 0;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
