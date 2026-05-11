import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinsManager {
  static final CoinsManager _instance = CoinsManager._internal();
  factory CoinsManager() => _instance;
  CoinsManager._internal();

  static const String _coinsKey = 'user_coins';
  SharedPreferences? _prefs;
  Future<void>? _initializing;

  final ValueNotifier<int> _coinsNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> get coinsNotifier => _coinsNotifier;

  int get currentCoins => _coinsNotifier.value;

  Future<void> initialize() async {
    if (_prefs != null) {
      return;
    }
    if (_initializing != null) {
      await _initializing;
      return;
    }

    _initializing = _doInitialize();
    try {
      await _initializing;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _doInitialize() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    _coinsNotifier.value = prefs.getInt(_coinsKey) ?? 100;
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    await initialize();
    _coinsNotifier.value += amount;
    await _prefs!.setInt(_coinsKey, _coinsNotifier.value);
  }

  Future<void> subCoins(int amount) async {
    if (amount <= 0) return;
    await initialize();
    if (_coinsNotifier.value < amount) {
      debugPrint(
          'Insufficient coins: current=${_coinsNotifier.value}, required=$amount');
      return;
    }
    _coinsNotifier.value -= amount;
    await _prefs!.setInt(_coinsKey, _coinsNotifier.value);
  }

  bool isEnough(int amount) {
    return _coinsNotifier.value >= amount;
  }

  Future<void> setCoins(int amount) async {
    await initialize();
    _coinsNotifier.value = amount;
    await _prefs!.setInt(_coinsKey, amount);
  }

  Future<void> clear() async {
    await initialize();
    _coinsNotifier.value = 0;
    await _prefs!.remove(_coinsKey);
  }

  void dispose() {
    _coinsNotifier.dispose();
  }
}
