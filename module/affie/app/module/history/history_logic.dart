import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// History item 目前支持两种类型：预置洞穴卡片 & AI 生成记录。
class HistoryItem {
  HistoryItem.cave({
    required this.id,
  })  : type = 'cave',
        title = null,
        imagePath = null,
        createdAt = null,
        aiData = null;

  HistoryItem.ai({
    required this.title,
    required this.imagePath,
    required this.createdAt,
    required this.aiData,
  }) : type = 'ai',
       id = null;

  final String type; // 'cave' or 'ai'
  final String? id; // 对应 HomeCave/HomeShare 的 id
  final String? title; // AI 结果标题
  final String? imagePath; // 本地图片路径
  final DateTime? createdAt;
  final Map<String, dynamic>? aiData;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (imagePath != null) 'imagePath': imagePath,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (aiData != null) 'aiData': aiData,
    };
  }

  static HistoryItem fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'ai';
    if (type == 'cave') {
      return HistoryItem.cave(id: (json['id'] as String?) ?? '');
    }

    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    final aiData = json['aiData'];
    return HistoryItem.ai(
      title: (json['title'] as String?) ?? 'AI Gear Check',
      imagePath: (json['imagePath'] as String?) ?? '',
      createdAt: createdAt ?? DateTime.now(),
      aiData: aiData is Map<String, dynamic> ? aiData : <String, dynamic>{},
    );
  }
}

class HistoryLogic extends GetxController {
  final historyList = <HistoryItem>[].obs;
  static const _storageKey = 'history_items_v1';
  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    _worker = ever<List<HistoryItem>>(historyList, (_) => _saveToStorage());
  }

  @override
  void onClose() {
    _worker?.dispose();
    super.onClose();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final items = decoded
          .whereType<Map>()
          .map((e) => HistoryItem.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v))))
          .toList();
      historyList.assignAll(items);
    } catch (_) {
      // ignore corrupted local data
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (historyList.isEmpty) {
        await prefs.remove(_storageKey);
        return;
      }
      final payload = jsonEncode(historyList.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, payload);
    } catch (_) {
      // ignore
    }
  }

  void addAiHistory(Map<String, dynamic> aiResult) {
    final title = (aiResult['routes'] is List &&
            (aiResult['routes'] as List).isNotEmpty &&
            (aiResult['routes'] as List).first is Map &&
            ((aiResult['routes'] as List).first)['name'] is String)
        ? ((aiResult['routes'] as List).first)['name'] as String
        : 'AI Gear Check';

    final createdAt = DateTime.tryParse(
          aiResult['createdAt'] as String? ?? '',
        ) ??
        DateTime.now();

    historyList.insert(
      0,
      HistoryItem.ai(
        title: title,
        imagePath: aiResult['imagePath'] as String? ?? '',
        createdAt: createdAt,
        aiData: aiResult,
      ),
    );
  }

  void removeHistory(int index) {
    historyList.removeAt(index);
  }

  void removeHistoryItem(HistoryItem item) {
    historyList.remove(item);
  }

  Future<void> clearAllHistory() async {
    historyList.clear();
    await _saveToStorage();
  }
}
