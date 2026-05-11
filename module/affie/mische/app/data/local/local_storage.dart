import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/emotion/emotion_models.dart';

class LocalStorage {
  static const String _coinsKey = 'coins_balance_v1';
  static const String _emotionEntriesKey = 'emotion_entries_v1';

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      print('SharedPreferences unavailable: $e');
      return null;
    }
  }

  static Future<int> loadCoins({int defaultValue = 299}) async {
    final prefs = await _prefs();
    if (prefs == null) return defaultValue;
    return prefs.getInt(_coinsKey) ?? defaultValue;
  }

  static Future<void> saveCoins(int value) async {
    final prefs = await _prefs();
    if (prefs == null) return;
    await prefs.setInt(_coinsKey, value);
  }

  static Future<List<EmotionEntry>> loadEmotionEntries() async {
    final prefs = await _prefs();
    if (prefs == null) return [];
    final raw = prefs.getString(_emotionEntriesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => EmotionEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Failed to decode emotion entries: $e');
      return [];
    }
  }

  static Future<void> saveEmotionEntries(List<EmotionEntry> entries) async {
    final prefs = await _prefs();
    if (prefs == null) return;
    final data = entries.map((entry) => entry.toJson()).toList();
    await prefs.setString(_emotionEntriesKey, jsonEncode(data));
  }

  static Future<void> clearUserData() async {
    final prefs = await _prefs();
    if (prefs == null) return;
    await prefs.remove(_coinsKey);
    await prefs.remove(_emotionEntriesKey);
  }
}
