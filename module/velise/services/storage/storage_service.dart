import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage Service - Abstract Singleton Pattern
/// Manages all local storage operations
abstract class StorageService {
  static StorageService? _instance;

  static void setInstance(StorageService storage) {
    _instance = storage;
  }

  static StorageService get instance {
    _instance ??= _StorageServiceImpl._();
    return _instance!;
  }

  Future<void> init();

  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> setInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> setDouble(String key, double value);
  Future<double?> getDouble(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Implementation of StorageService
class _StorageServiceImpl extends GetxService implements StorageService {
  late SharedPreferences _prefs;

  _StorageServiceImpl._();

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

/// Storage Keys
class StorageKeys {
  StorageKeys._();

  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userAvatar = 'user_avatar';
  static const String coinBalance = 'coin_balance';
  static const String deliveredPurchaseIds = 'delivered_purchase_ids';
  static const String isFirstLaunch = 'is_first_launch';
  static const String language = 'language';
}
