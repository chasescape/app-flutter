import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../models/user_data.dart';
import '../models/hairstyle_result.dart';
import 'dart:convert';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  static const String _keyUserData = 'user_data';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  SharedPreferences? _prefs;

  UserData _defaultUserData() {
    return UserData(
      userId: userId ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      coinBalance: 0,
      freeAttempts: 0,
      history: const [],
    );
  }

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Auth Token
  String? get authToken => _prefs?.getString(_keyAuthToken);

  Future<void> setAuthToken(String? token) async {
    if (token != null) {
      await _prefs?.setString(_keyAuthToken, token);
    } else {
      await _prefs?.remove(_keyAuthToken);
    }
  }

  // User ID
  String? get userId => _prefs?.getString(_keyUserId);

  Future<void> setUserId(String? id) async {
    if (id != null) {
      await _prefs?.setString(_keyUserId, id);
    } else {
      await _prefs?.remove(_keyUserId);
    }
  }

  // Onboarding
  bool get onboardingCompleted =>
      _prefs?.getBool(_keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs?.setBool(_keyOnboardingCompleted, completed);
  }

  // User Data
  UserData? getUserData() {
    final String? data = _prefs?.getString(_keyUserData);
    if (data != null) {
      try {
        return UserData.fromJson(jsonDecode(data));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveUserData(UserData userData) async {
    await _prefs?.setString(_keyUserData, jsonEncode(userData.toJson()));
  }

  // Coin Balance
  int get coinBalance => getUserData()?.coinBalance ?? 0;

  Future<void> setCoinBalance(int balance) async {
    final userData = getUserData() ?? _defaultUserData();
    await saveUserData(userData.copyWith(coinBalance: balance));
  }

  Future<void> addCoins(int amount) async {
    final currentBalance = coinBalance;
    await setCoinBalance(currentBalance + amount);
  }

  Future<bool> spendCoins(int amount) async {
    final currentBalance = coinBalance;
    if (currentBalance >= amount) {
      await setCoinBalance(currentBalance - amount);
      return true;
    }
    return false;
  }

  // Free Attempts
  int get freeAttempts => getUserData()?.freeAttempts ?? 0;

  Future<void> setFreeAttempts(int attempts) async {
    final userData = getUserData() ?? _defaultUserData();
    await saveUserData(userData.copyWith(freeAttempts: attempts));
  }

  Future<bool> useFreeAttempt() async {
    final currentAttempts = freeAttempts;
    if (currentAttempts > 0) {
      await setFreeAttempts(currentAttempts - 1);
      return true;
    }
    return false;
  }

  Future<void> restoreFreeAttempt() async {
    final currentAttempts = freeAttempts;
    await setFreeAttempts(currentAttempts + 1);
  }

  // History
  List<HairstyleResult> getHistory() {
    return getUserData()?.history ?? [];
  }

  Future<void> addHistoryItem(HairstyleResult result) async {
    final userData = getUserData() ?? _defaultUserData();
    final history = [result, ...userData.history];
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    await saveUserData(userData.copyWith(history: history));
  }

  Future<void> deleteHistoryItem(String id) async {
    final userData = getUserData() ?? _defaultUserData();
    final history = userData.history.where((item) => item.id != id).toList();
    await saveUserData(userData.copyWith(history: history));
  }

  Future<void> clearHistory() async {
    final userData = getUserData() ?? _defaultUserData();
    await saveUserData(userData.copyWith(history: []));
  }

  // Clear All Data
  Future<void> clearAllData() async {
    await _prefs?.remove(_keyUserData);
    await _prefs?.remove(_keyAuthToken);
    await _prefs?.remove(_keyUserId);
    await _prefs?.remove(_keyOnboardingCompleted);
  }
}
