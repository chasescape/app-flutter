import 'dart:async';
import 'package:flutter/foundation.dart';
import '../singletons/storage_service.dart';

/// User Service - Singleton Pattern
abstract class UserService {
  static UserService? _instance;

  static void setInstance(UserService service) {
    _instance = service;
  }

  static UserService get instance {
    _instance ??= _UserServiceImpl._();
    return _instance!;
  }

  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  // Abstract methods
  Future<bool> isLoggedIn();
  Future<void> login();
  Future<void> logout();
  Future<void> clearData();
  Future<int> getCoins();
  Future<void> setCoins(int coins);
  Future<void> addCoins(int amount);
  Future<bool> consumeCoins(int amount);
  Future<int> getFreeUsageCount();
  Future<void> setFreeUsageCount(int count);
  Future<bool> hasFreeUsage();
  Future<void> useFreeUsage();
}

/// Implementation
class _UserServiceImpl implements UserService {
  _UserServiceImpl._();

  final StorageService _storage = StorageService.instance;

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.loadString(StorageKeys.authToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> login() async {
    await _storage.saveString(StorageKeys.authToken, 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<void> logout() async {
    await _storage.remove(StorageKeys.authToken);
  }

  @override
  Future<void> clearData() async {
    // Clear only local history data. Auth state and coin balance remain intact.
    await _storage.remove(StorageKeys.makeupRecords);
    await _storage.remove(StorageKeys.recordCount);
  }

  @override
  Future<int> getCoins() async {
    return await _storage.loadInt(StorageKeys.userCoins) ?? 0;
  }

  @override
  Future<void> setCoins(int coins) async {
    await _storage.saveInt(StorageKeys.userCoins, coins);
  }

  @override
  Future<void> addCoins(int amount) async {
    final current = await getCoins();
    await setCoins(current + amount);
  }

  @override
  Future<bool> consumeCoins(int amount) async {
    final current = await getCoins();
    if (current < amount) return false;
    await setCoins(current - amount);
    return true;
  }

  @override
  Future<int> getFreeUsageCount() async {
    return await _storage.loadInt(StorageKeys.freeUsageCount) ?? 0;
  }

  @override
  Future<void> setFreeUsageCount(int count) async {
    await _storage.saveInt(StorageKeys.freeUsageCount, count);
  }

  @override
  Future<bool> hasFreeUsage() async {
    final count = await getFreeUsageCount();
    return count > 0;
  }

  @override
  Future<void> useFreeUsage() async {
    final count = await getFreeUsageCount();
    if (count > 0) {
      await setFreeUsageCount(count - 1);
    }
  }
}
