import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneratedDesignItem {
  GeneratedDesignItem({
    required this.pathOrUrl,
    required this.createdAtMs,
    required this.aiCopy,
  });

  final String pathOrUrl;
  final int createdAtMs;
  final String aiCopy;

  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(createdAtMs, isUtc: false);

  Map<String, dynamic> toJson() => {
        'path': pathOrUrl,
        'createdAtMs': createdAtMs,
        'aiCopy': aiCopy,
      };

  static GeneratedDesignItem? tryFromJson(dynamic v) {
    if (v is Map) {
      final path = (v['path'] as String?)?.trim() ?? '';
      if (path.isEmpty) return null;
      final createdAtMs = v['createdAtMs'];
      final ms = createdAtMs is int
          ? createdAtMs
          : int.tryParse('$createdAtMs') ??
              DateTime.now().millisecondsSinceEpoch;
      final aiCopy = (v['aiCopy'] as String?) ?? '';
      return GeneratedDesignItem(pathOrUrl: path, createdAtMs: ms, aiCopy: aiCopy);
    }
    if (v is String) {
      final path = v.trim();
      if (path.isEmpty) return null;
      return GeneratedDesignItem(
        pathOrUrl: path,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
        aiCopy: '',
      );
    }
    return null;
  }
}

class HomeLogic extends GetxController {
  static const String _kPrefsKey = 'rova.generated_images';

  final RxList<GeneratedDesignItem> generatedImages =
      <GeneratedDesignItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final items = <GeneratedDesignItem>[];
        for (final v in decoded) {
          final item = GeneratedDesignItem.tryFromJson(v);
          if (item != null) items.add(item);
        }
        generatedImages.assignAll(items);
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> addGeneratedImage(String pathOrUrl, {String? aiCopy}) async {
    final value = pathOrUrl.trim();
    if (value.isEmpty) return;
    generatedImages.removeWhere((e) => e.pathOrUrl.trim() == value);
    generatedImages.insert(
      0,
      GeneratedDesignItem(
        pathOrUrl: value,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
        aiCopy: (aiCopy ?? '').trim(),
      ),
    );
    await _persist();
  }

  Future<void> updateGeneratedCopy(String pathOrUrl, String aiCopy) async {
    final path = pathOrUrl.trim();
    if (path.isEmpty) return;
    final copy = aiCopy.trim();
    if (copy.isEmpty) return;

    final index =
        generatedImages.indexWhere((e) => e.pathOrUrl.trim() == path);
    if (index < 0) return;

    final old = generatedImages[index];
    if (old.aiCopy.trim() == copy) return;
    generatedImages[index] = GeneratedDesignItem(
      pathOrUrl: old.pathOrUrl,
      createdAtMs: old.createdAtMs,
      aiCopy: copy,
    );
    await _persist();
  }

  Future<void> removeGeneratedImage(String pathOrUrl) async {
    final path = pathOrUrl.trim();
    if (path.isEmpty) return;
    final oldLength = generatedImages.length;
    generatedImages.removeWhere((e) => e.pathOrUrl.trim() == path);
    if (generatedImages.length != oldLength) {
      await _persist();
    }
  }

  Future<void> clearGeneratedImages() async {
    generatedImages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefsKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPrefsKey,
      jsonEncode(generatedImages.map((e) => e.toJson()).toList()),
    );
  }
}
