import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../models/perfume_record.dart';
import '../models/perfume.dart';
import '../models/user_data.dart';

/// Local storage service using SharedPreferences
class StorageService extends GetxService {
  static StorageService get to => Get.find();

  static const String _keyRecords = 'perfume_records';
  static const String _keyPerfumes = 'perfumes';
  static const String _keyUserData = 'user_data';
  static const String _keyFirstLaunch = 'first_launch';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ========== Records ==========

  Future<List<PerfumeRecord>> getRecords() async {
    final jsonString = _prefs.getString(_keyRecords);
    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => PerfumeRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveRecord(PerfumeRecord record) async {
    final records = await getRecords();
    records.insert(0, record);
    await _saveRecords(records);
  }

  Future<void> updateRecord(PerfumeRecord record) async {
    final records = await getRecords();
    final index = records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      records[index] = record;
      await _saveRecords(records);
    }
  }

  Future<void> deleteRecord(String recordId) async {
    final records = await getRecords();
    records.removeWhere((r) => r.id == recordId);
    await _saveRecords(records);
  }

  Future<void> _saveRecords(List<PerfumeRecord> records) async {
    final jsonString = json.encode(
      records.map((r) => r.toJson()).toList(),
    );
    await _prefs.setString(_keyRecords, jsonString);
  }

  // ========== Perfumes ==========

  Future<List<Perfume>> getPerfumes() async {
    final jsonString = _prefs.getString(_keyPerfumes);
    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => Perfume.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePerfume(Perfume perfume) async {
    final perfumes = await getPerfumes();
    final existingIndex = perfumes.indexWhere((p) => p.id == perfume.id);

    if (existingIndex != -1) {
      perfumes[existingIndex] = perfume;
    } else {
      perfumes.add(perfume);
    }

    await _savePerfumes(perfumes);
  }

  Future<void> deletePerfume(String perfumeId) async {
    final perfumes = await getPerfumes();
    perfumes.removeWhere((p) => p.id == perfumeId);
    await _savePerfumes(perfumes);
  }

  Future<void> _savePerfumes(List<Perfume> perfumes) async {
    final jsonString = json.encode(
      perfumes.map((p) => p.toJson()).toList(),
    );
    await _prefs.setString(_keyPerfumes, jsonString);
  }

  // ========== User Data ==========

  Future<UserData> getUserData() async {
    final jsonString = _prefs.getString(_keyUserData);
    if (jsonString == null) {
      return UserData(
        coins: 0,
        freeUses: 1 + (DateTime.now().millisecond % 3),
      );
    }

    try {
      return UserData.fromJson(json.decode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return UserData(coins: 0, freeUses: 1);
    }
  }

  Future<void> saveUserData(UserData userData) async {
    final jsonString = json.encode(userData.toJson());
    await _prefs.setString(_keyUserData, jsonString);
  }

  Future<void> updateCoins(int amount) async {
    final userData = await getUserData();
    final updated = userData.copyWith(coins: userData.coins + amount);
    await saveUserData(updated);
  }

  Future<void> useFreeUse() async {
    final userData = await getUserData();
    if (userData.freeUses > 0) {
      final updated = userData.copyWith(freeUses: userData.freeUses - 1);
      await saveUserData(updated);
    }
  }

  // ========== First Launch ==========

  Future<bool> isFirstLaunch() async {
    return _prefs.getBool(_keyFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunch(bool value) async {
    await _prefs.setBool(_keyFirstLaunch, value);
  }

  // ========== Clear All Data ==========

  Future<void> clearAllData() async {
    await _prefs.remove(_keyRecords);
    await _prefs.remove(_keyPerfumes);
    await _prefs.remove(_keyUserData);
  }
}
