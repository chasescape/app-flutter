import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ai_service.dart';

class HistoryEntry {
  HistoryEntry({required this.result, required this.imagePath});

  final AiResult result;
  final String imagePath;

  Map<String, dynamic> toJson() {
    return {
      'result': result.toJson(),
      'imagePath': imagePath,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      result: AiResult.fromJson((json['result'] as Map).cast<String, dynamic>()),
      imagePath: json['imagePath']?.toString() ?? '',
    );
  }
}

class HistoryService {
  static const String _key = 'ai_history_records';

  static Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .whereType<Map>()
        .map((e) => HistoryEntry.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  static Future<void> save(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
