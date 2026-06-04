import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract Storage Service - Singleton Pattern
abstract class StorageService {
  static StorageService? _instance;

  static void setInstance(StorageService service) {
    _instance = service;
  }

  static StorageService get instance {
    _instance ??= _StorageServiceImpl._();
    return _instance!;
  }

  static Future<void> ensureInitialized() async {
    final service = instance;
    if (service is _StorageServiceImpl) {
      await service.init();
    }
  }

  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  // Abstract methods
  Future<void> saveString(String key, String value);
  Future<String?> loadString(String key);
  Future<void> saveInt(String key, int value);
  Future<int?> loadInt(String key);
  Future<void> saveDouble(String key, double value);
  Future<double?> loadDouble(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> loadBool(String key);
  Future<void> saveJSON(String key, Map<String, dynamic> value);
  Future<Map<String, dynamic>?> loadJSON(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}

/// SharedPreferences Implementation
class _StorageServiceImpl implements StorageService {
  _StorageServiceImpl._();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> loadString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<int?> loadInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  Future<double?> loadDouble(String key) async {
    return _prefs.getDouble(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<bool?> loadBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<void> saveJSON(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  @override
  Future<Map<String, dynamic>?> loadJSON(String key) async {
    final str = _prefs.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    final keys = _prefs.getKeys();
    return keys.contains(key);
  }
}

// Storage keys
class StorageKeys {
  // Auth
  static const String authToken = 'auth_token';
  static const String isFirstLaunch = 'is_first_launch';
  static const String freeUsageCount = 'free_usage_count';

  // User data
  static const String userCoins = 'user_coins';
  static const String userName = 'user_name';

  // Records
  static const String makeupRecords = 'makeup_records';
  static const String recordCount = 'record_count';
}
