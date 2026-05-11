import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class CoinsManager {
  CoinsManager._();

  static CoinsManager? _instance;

  static CoinsManager get instance {
    _instance ??= CoinsManager._();
    return _instance!;
  }

  final StorageService _storage = StorageService.to;
  final ValueNotifier<int> _coinsNotifier = ValueNotifier(0);
  final ValueNotifier<int> _freeResultsNotifier = ValueNotifier(0);

  ValueNotifier<int> get coinsNotifier => _coinsNotifier;
  ValueNotifier<int> get freeResultsNotifier => _freeResultsNotifier;

  int get coins => _coinsNotifier.value;
  int get freeResults => _freeResultsNotifier.value;

  void init() {
    _coinsNotifier.value = _storage.getCoins();
    _freeResultsNotifier.value = _storage.getFreeResults();
  }

  Future<void> addCoins(int amount) async {
    await _storage.addCoins(amount);
    _coinsNotifier.value = _storage.getCoins();
  }

  Future<bool> subCoins(int amount) async {
    final success = await _storage.deductCoins(amount);
    if (success) {
      _coinsNotifier.value = _storage.getCoins();
    }
    return success;
  }

  bool isEnough(int amount) {
    return coins >= amount;
  }

  Future<bool> useFreeResult() async {
    final success = await _storage.useFreeResult();
    if (success) {
      _freeResultsNotifier.value = _storage.getFreeResults();
    }
    return success;
  }

  Future<void> clear() async {
    await _storage.clearAllData();
    _coinsNotifier.value = 10;
    _freeResultsNotifier.value = 3;
  }

  void dispose() {
    _coinsNotifier.dispose();
    _freeResultsNotifier.dispose();
  }
}
