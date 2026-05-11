import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdviceStore {
  AdviceStore._();

  static const String _keyHistory = 'advice_history';
  static final ValueNotifier<AdvicePayload?> latest =
      ValueNotifier<AdvicePayload?>(null);
  static final ValueNotifier<List<AdvicePayload>> history =
      ValueNotifier<List<AdvicePayload>>(<AdvicePayload>[]);

  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHistory);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final items = decoded
            .whereType<Map>()
            .map((e) => AdvicePayload.fromJson(e.cast<String, dynamic>()))
            .toList();
        history.value = items;
        latest.value = items.isNotEmpty ? items.first : null;
      }
    } catch (_) {}
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = history.value.map((e) => e.toJson()).toList();
    await prefs.setString(_keyHistory, jsonEncode(data));
  }

  static void set(AdvicePayload payload) {
    latest.value = payload;
    history.value = <AdvicePayload>[payload, ...history.value];
    _persist();
  }

  static void removeById(String id) {
    final updated = history.value
        .where(
          (item) => item.createdAt.millisecondsSinceEpoch.toString() != id,
        )
        .toList();
    history.value = updated;
    latest.value = updated.isNotEmpty ? updated.first : null;
    _persist();
  }

  static void removeMany(Set<String> ids) {
    final updated = history.value
        .where(
          (item) =>
              !ids.contains(item.createdAt.millisecondsSinceEpoch.toString()),
        )
        .toList();
    history.value = updated;
    latest.value = updated.isNotEmpty ? updated.first : null;
    _persist();
  }

  static void clearAll() {
    history.value = <AdvicePayload>[];
    latest.value = null;
    _persist();
  }

  static Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
    history.value = <AdvicePayload>[];
    latest.value = null;
  }
}

class AdvicePayload {
  final String content;
  final String? imagePath;
  final DateTime createdAt;

  AdvicePayload({
    required this.content,
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AdvicePayload.fromJson(Map<String, dynamic> json) {
    return AdvicePayload(
      content: (json['content'] ?? '').toString(),
      imagePath: json['imagePath']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
