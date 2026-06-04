import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinsManager extends ChangeNotifier {
  static const String _keyCoinBalance = 'coin_balance';

  static CoinsManager? _instance;
  int _balance = 0;

  factory CoinsManager() {
    _instance ??= CoinsManager._internal();
    return _instance!;
  }

  CoinsManager._internal();

  static CoinsManager get instance => CoinsManager();

  int get balance => _balance;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt(_keyCoinBalance) ?? 0;
    notifyListeners();
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    _balance += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoinBalance, _balance);
    notifyListeners();
  }

  Future<bool> subCoins(int amount) async {
    if (amount <= 0) return true;
    if (_balance < amount) return false;
    _balance -= amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoinBalance, _balance);
    notifyListeners();
    return true;
  }

  bool isEnough(int amount) {
    return _balance >= amount;
  }

  Future<void> clear() async {
    _balance = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCoinBalance);
    notifyListeners();
  }

  void setBalanceSync(int balance) {
    _balance = balance;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_keyCoinBalance, _balance);
    });
    notifyListeners();
  }

  Future<void> setBalance(int balance) async {
    _balance = balance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoinBalance, _balance);
    notifyListeners();
  }
}
