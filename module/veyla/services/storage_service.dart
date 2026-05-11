import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/mixin/singleton_mixin.dart';
import '../models/checkin_model.dart';
import '../models/achievement_model.dart';
import '../models/coin_package.dart';

class StorageKeys {
  static const String authToken = 'auth_token';
  static const String checkInRecords = 'check_in_records';
  static const String achievements = 'achievements';
  static const String coins = 'coins';
  static const String freeAttempts = 'free_attempts';
  static const String targetWakeTime = 'target_wake_time';
  static const String targetSleepTime = 'target_sleep_time';
  static const String notificationEnabled = 'notification_enabled';
  static const String lastCheckInDate = 'last_check_in_date';
}

class StorageService with SingletonMixin<StorageService> {
  StorageService._();

  static StorageService get instance =>
      SingletonMixin.getInstance(() => StorageService._());

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
  }

  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    return await _prefs!.setString(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    return await _prefs!.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    return await _prefs!.setBool(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    return await _prefs!.setStringList(key, value);
  }

  String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }

  int? getInt(String key) {
    _ensureInitialized();
    return _prefs!.getInt(key);
  }

  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs!.getBool(key);
  }

  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  Future<bool> remove(String key) async {
    _ensureInitialized();
    return await _prefs!.remove(key);
  }

  Future<bool> clear() async {
    _ensureInitialized();
    return await _prefs!.clear();
  }

  String? get authToken => getString(StorageKeys.authToken);
  Future<bool> setAuthToken(String token) => setString(StorageKeys.authToken, token);
  Future<bool> removeAuthToken() => remove(StorageKeys.authToken);

  List<CheckInRecord> getCheckInRecords() {
    final recordsJson = getStringList(StorageKeys.checkInRecords);
    if (recordsJson == null) return [];
    return recordsJson
        .map((json) => CheckInRecord.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<bool> saveCheckInRecords(List<CheckInRecord> records) {
    final recordsJson = records.map((r) => jsonEncode(r.toJson())).toList();
    return setStringList(StorageKeys.checkInRecords, recordsJson);
  }

  List<Achievement> getAchievements() {
    final achievementsJson = getStringList(StorageKeys.achievements);
    if (achievementsJson == null) return AchievementDefinitions.all;
    return achievementsJson
        .map((json) => Achievement.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<bool> saveAchievements(List<Achievement> achievements) {
    final achievementsJson =
        achievements.map((a) => jsonEncode(a.toJson())).toList();
    return setStringList(StorageKeys.achievements, achievementsJson);
  }

  int get coins => getInt(StorageKeys.coins) ?? CoinPackages.initialCoins;
  Future<bool> setCoins(int value) => setInt(StorageKeys.coins, value);

  int get freeAttempts => getInt(StorageKeys.freeAttempts) ?? 0;
  Future<bool> setFreeAttempts(int value) => setInt(StorageKeys.freeAttempts, value);

  String? get targetWakeTime => getString(StorageKeys.targetWakeTime);
  Future<bool> setTargetWakeTime(String time) => setString(StorageKeys.targetWakeTime, time);

  String? get targetSleepTime => getString(StorageKeys.targetSleepTime);
  Future<bool> setTargetSleepTime(String time) => setString(StorageKeys.targetSleepTime, time);

  bool get notificationEnabled => getBool(StorageKeys.notificationEnabled) ?? true;
  Future<bool> setNotificationEnabled(bool value) => setBool(StorageKeys.notificationEnabled, value);

  String? get lastCheckInDate => getString(StorageKeys.lastCheckInDate);
  Future<bool> setLastCheckInDate(String date) => setString(StorageKeys.lastCheckInDate, date);

  Future<bool> hasCheckedInToday() async {
    final lastDate = lastCheckInDate;
    if (lastDate == null) return false;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return lastDate == today;
  }

  Future<void> clearAllUserData() async {
    await remove(StorageKeys.authToken);
    await remove(StorageKeys.checkInRecords);
    await remove(StorageKeys.achievements);
    await remove(StorageKeys.coins);
    await remove(StorageKeys.freeAttempts);
    await remove(StorageKeys.lastCheckInDate);
  }
}
