import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorage {
  static LocalStorage? _ins;
  late SharedPreferences _prefs;
  static const _initialCoins = 30;
  static const _authTokenKey = 'auth_token';
  static const _recordStorageKey = 'perfume_records';
  static const _coinBalanceKey = 'glace_coin_balance';

  LocalStorage._internal();

  static LocalStorage get instance {
    _ins ??= LocalStorage._internal();
    return _ins!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_prefs.containsKey(_coinBalanceKey)) {
      _prefs.setInt(_coinBalanceKey, _initialCoins);
    }
  }

  // Auth
  String? get authToken => _prefs.getString(_authTokenKey);
  set authToken(String? v) {
    if (v == null) {
      _prefs.remove(_authTokenKey);
    } else {
      _prefs.setString(_authTokenKey, v);
    }
  }

  // Perfume records (JSON string list)
  List<String> get recordJsonList =>
      _prefs.getStringList(_recordStorageKey) ?? [];
  set recordJsonList(List<String> v) =>
      _prefs.setStringList(_recordStorageKey, v);

  // Save a record
  void saveRecord(Map<String, dynamic> record) {
    final list = recordJsonList;
    list.insert(0, jsonEncode(record));
    if (list.length > 200) list.removeRange(200, list.length);
    recordJsonList = list;
  }

  // Delete a record by id
  void deleteRecord(String id) {
    final list = recordJsonList;
    list.removeWhere((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map['id'] == id;
    });
    recordJsonList = list;
  }

  // Get all records as maps
  List<Map<String, dynamic>> getAllRecords() {
    return recordJsonList
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  int get coins => _prefs.getInt(_coinBalanceKey) ?? _initialCoins;
  set coins(int value) => _prefs.setInt(_coinBalanceKey, value);

  Future<void> clearDeleteAccountLocalData() async {
    await _prefs.remove(_recordStorageKey);

    final keysToRemove = _prefs.getKeys().where((key) {
      final normalized = key.toLowerCase();
      return normalized == 'coins' ||
          normalized == 'coin' ||
          normalized == 'coin_balance' ||
          normalized == 'glace_coin_balance' ||
          normalized.startsWith('coin_') ||
          normalized.contains('_coin') ||
          normalized.contains('wallet');
    }).toList();

    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
