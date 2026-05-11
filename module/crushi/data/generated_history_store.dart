import 'package:flutter/foundation.dart';
import 'package:crushi/crushi/data/models/stoic_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GeneratedHistoryStore {
  GeneratedHistoryStore._();

  static final GeneratedHistoryStore I = GeneratedHistoryStore._();

  final ValueNotifier<List<StoicCard>> items = ValueNotifier<List<StoicCard>>([]);

  static const String _key = 'generated_history_v1';
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw);
      if (list is! List) return;
      final parsed = <StoicCard>[];
      for (final item in list) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final assetImg = map['asset_img'] as String?;
        if (assetImg == null) continue;
        parsed.add(StoicCard.fromJson(map, assetImg: assetImg));
      }
      items.value = parsed.take(50).toList();
    } catch (_) {
      // ignore corrupted cache
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.value.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> clearPersisted() async {
    items.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  void add(StoicCard card) {
    final next = [card, ...items.value];
    items.value = next.take(50).toList();
    // fire-and-forget
    _persist();
  }

  void removeAt(int index) {
    final next = [...items.value]..removeAt(index);
    items.value = next;
    _persist();
  }

  void clear() {
    items.value = [];
    _persist();
  }
}
