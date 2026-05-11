import 'package:shared_preferences/shared_preferences.dart';

class CoinStore {
  CoinStore._();

  static const String _key = 'coins_balance_v1';
  static const int _defaultCoins = 100;
  static int? _cache;

  static Future<int> loadBalance() async {
    if (_cache != null) return _cache!;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int value = prefs.getInt(_key) ?? _defaultCoins;
    _cache = value;
    return value;
  }

  static int? get cachedBalance => _cache;

  static Future<int> setBalance(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, value);
    _cache = value;
    return value;
  }

  static Future<int> addCoins(int amount) async {
    final int current = await loadBalance();
    return setBalance(current + amount);
  }

  static Future<int> spendCoins(int amount) async {
    final int current = await loadBalance();
    final int next = current - amount;
    return setBalance(next < 0 ? 0 : next);
  }

  static Future<bool> canSpend(int amount) async {
    final int current = await loadBalance();
    return current >= amount;
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _cache = null;
  }
}
