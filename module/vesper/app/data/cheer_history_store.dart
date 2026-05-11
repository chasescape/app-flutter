import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vesper/vesper/app/network/cheer_ai_service.dart';

class CheerHistoryItem {
  final String imagePath;
  final CheerAnalysisResult result;
  final DateTime createdAt;

  CheerHistoryItem({
    required this.imagePath,
    required this.result,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'result': result.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CheerHistoryItem.fromJson(Map<String, dynamic> json) {
    return CheerHistoryItem(
      imagePath: (json['imagePath'] ?? '').toString(),
      result: CheerAnalysisResult.fromJson(
        (json['result'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class CheerHistoryStore extends GetxController {
  static const String _key = 'cheer_history_items';

  final List<CheerHistoryItem> items = [];

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void addItem(CheerHistoryItem item) {
    items.insert(0, item);
    update();
    _save();
  }

  Future<void> removeItem(CheerHistoryItem item) async {
    items.remove(item);
    update();
    final file = File(item.imagePath);
    if (file.existsSync()) {
      try {
        await file.delete();
      } catch (_) {}
    }
    await _save();
  }

  Future<void> clearAll() async {
    for (final item in items) {
      final file = File(item.imagePath);
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
    items.clear();
    update();
    await _save();
  }

  Future<void> clear() async {
    items.clear();
    update();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return;
    }
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        items
          ..clear()
          ..addAll(
            list
                .whereType<Map>()
                .map((e) => CheerHistoryItem.fromJson(
                      e.cast<String, dynamic>(),
                    ))
                .toList(),
          );
        update();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(data));
  }
}
