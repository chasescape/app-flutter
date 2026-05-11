import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'photo_scene_models.dart';

class PhotoSceneStorage {
  static const String _key = 'photo_scene_items_v1';

  Future<List<AnalyzedPhoto>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<dynamic>();
      final items = list
          .map((e) => AnalyzedPhoto.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      // If a local image file was removed, drop it from our local catalog.
      final existing =
          items.where((e) => File(e.path).existsSync()).toList(growable: false);
      if (existing.length != items.length) {
        await prefs.setString(
          _key,
          jsonEncode(existing.map((e) => e.toJson()).toList()),
        );
      }
      return existing;
    } catch (_) {
      return const [];
    }
  }

  Future<void> upsertMany(List<AnalyzedPhoto> items) async {
    final existing = await loadAll();
    final byPath = <String, AnalyzedPhoto>{
      for (final it in existing) it.path: it,
    };
    for (final it in items) {
      byPath[it.path] = it;
    }
    final merged = byPath.values.toList()
      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(merged.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removePaths(
    List<String> paths, {
    bool deleteFiles = false,
  }) async {
    if (paths.isEmpty) return;
    final existing = await loadAll();
    final remove = paths.toSet();
    final kept = existing.where((e) => !remove.contains(e.path)).toList();

    if (deleteFiles) {
      for (final p in paths) {
        try {
          final f = File(p);
          if (await f.exists()) {
            await f.delete();
          }
        } catch (_) {}
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(kept.map((e) => e.toJson()).toList()),
    );
  }
}
