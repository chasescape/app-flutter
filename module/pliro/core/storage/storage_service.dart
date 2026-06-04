import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';
import 'dart:convert';

/// Storage service for local data persistence
class StorageService extends GetxService {
  static late final StorageService _instance = StorageService._internal();

  late final SharedPreferences _prefs;

  StorageService._internal();

  static StorageService get instance => _instance;

  /// Initialize storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Token
  static const String _keyAuthToken = 'auth_token';
  Future<void> setAuthToken(String token) async {
    await _prefs.setString(_keyAuthToken, token);
  }

  Future<String?> getAuthToken() async {
    return _prefs.getString(_keyAuthToken);
  }

  Future<void> removeAuthToken() async {
    await _prefs.remove(_keyAuthToken);
  }

  // User Coins
  static const String _keyCoins = 'user_coins';
  Future<void> setCoins(int coins) async {
    await _prefs.setInt(_keyCoins, coins);
  }

  Future<int> getCoins() async {
    return _prefs.getInt(_keyCoins) ?? 0;
  }

  Future<void> addCoins(int amount) async {
    final current = await getCoins();
    await setCoins(current + amount);
  }

  // Free Usage Count
  static const String _keyFreeCount = 'free_usage_count';
  Future<void> setFreeCount(int count) async {
    await _prefs.setInt(_keyFreeCount, count);
  }

  Future<int> getFreeCount() async {
    return _prefs.getInt(_keyFreeCount) ?? (1 + (DateTime.now().millisecond % 3));
  }

  // Bead Records
  static const String _keyRecords = 'bead_records';
  Future<void> saveRecords(List<BeadRecord> records) async {
    final jsonList = records.map((r) => r.toJson()).toList();
    await _prefs.setString(_keyRecords, jsonEncode(jsonList));
  }

  Future<List<BeadRecord>> getRecords() async {
    final jsonStr = _prefs.getString(_keyRecords);
    if (jsonStr == null) return [];

    try {
      final jsonList = jsonDecode(jsonStr) as List;
      return jsonList
          .map((json) => BeadRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addRecord(BeadRecord record) async {
    final records = await getRecords();
    records.insert(0, record);
    await saveRecords(records);
  }

  Future<void> deleteRecord(String recordId) async {
    final records = await getRecords();
    records.removeWhere((r) => r.id == recordId);
    await saveRecords(records);
  }

  // User Profile
  static const String _keyUsername = 'username';
  static const String _keyAvatar = 'avatar';
  static const String _keyBio = 'bio';

  Future<void> setUserProfile({
    String? username,
    String? avatar,
    String? bio,
  }) async {
    if (username != null) {
      await _prefs.setString(_keyUsername, username);
    }
    if (avatar != null) {
      await _prefs.setString(_keyAvatar, avatar);
    }
    if (bio != null) {
      await _prefs.setString(_keyBio, bio);
    }
  }

  Future<Map<String, String?>> getUserProfile() async {
    return {
      'username': _prefs.getString(_keyUsername),
      'avatar': _prefs.getString(_keyAvatar),
      'bio': _prefs.getString(_keyBio),
    };
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
