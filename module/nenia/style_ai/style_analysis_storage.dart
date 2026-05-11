import 'dart:convert';

import 'package:get/get.dart';

import '../data/models/style_analysis.dart';
import '../services/storage_service.dart';

class StyleAnalysisStorage {
  static const String _listKey = 'style_analysis_history_list';
  static const int _maxItems = 100;

  /// Save one analysis result into local history.
  static Future<StyleAnalysisHistoryItem> save(
    StyleAnalysis data, {
    String? imagePath,
  }) async {
    final storage = Get.find<StorageService>();
    final list = await getList();
    final now = DateTime.now();
    final item = StyleAnalysisHistoryItem(
      id: now.millisecondsSinceEpoch.toString(),
      data: _cloneAnalysis(data, imagePath: imagePath),
      createdAt: now,
      imagePath: imagePath,
    );

    list.insert(0, item);
    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }

    await _saveList(storage, list);
    return item;
  }

  static Future<List<StyleAnalysisHistoryItem>> getList() async {
    final storage = Get.find<StorageService>();
    final jsonString = await storage.getString(_listKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .whereType<Map<String, dynamic>>()
          .map(StyleAnalysisHistoryItem.fromJsonCompatible)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> delete(String id) async {
    final storage = Get.find<StorageService>();
    final list = await getList();
    final initialLength = list.length;
    list.removeWhere((item) => item.id == id);

    if (list.length == initialLength) {
      return false;
    }

    await _saveList(storage, list);
    return true;
  }

  static Future<void> clear() async {
    final storage = Get.find<StorageService>();
    await storage.remove(_listKey);
  }

  static Future<void> _saveList(
    StorageService storage,
    List<StyleAnalysisHistoryItem> list,
  ) async {
    final jsonList = list.map((item) => item.toJson()).toList();
    await storage.setString(_listKey, jsonEncode(jsonList));
  }

  static StyleAnalysis _cloneAnalysis(
    StyleAnalysis data, {
    String? imagePath,
  }) {
    final cloned = StyleAnalysis.fromJson(data.toJson());
    cloned.assetImg = imagePath ?? data.assetImg;
    return cloned;
  }
}

class StyleAnalysisHistoryItem {
  final String id;
  final StyleAnalysis data;
  final DateTime createdAt;
  final String? imagePath;

  StyleAnalysisHistoryItem({
    required this.id,
    required this.data,
    required this.createdAt,
    this.imagePath,
  });

  factory StyleAnalysisHistoryItem.fromJson(Map<String, dynamic> json) {
    final imagePath = json['imagePath'] as String?;
    final analysis = StyleAnalysis.fromJson(
      json['data'] as Map<String, dynamic>,
    );
    analysis.assetImg = imagePath ?? '';

    return StyleAnalysisHistoryItem(
      id: json['id'] as String,
      data: analysis,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imagePath: imagePath,
    );
  }

  factory StyleAnalysisHistoryItem.fromJsonCompatible(
    Map<String, dynamic> json,
  ) {
    if (json.containsKey('data')) {
      return StyleAnalysisHistoryItem.fromJson(json);
    }

    final imagePath =
        json['imagePath'] as String? ?? json['assetImg'] as String?;
    final analysis = StyleAnalysis.fromJson(json);
    analysis.assetImg = imagePath ?? '';

    final createdAtRaw = json['createdAt'] ?? json['timestamp'];
    final createdAt = DateTime.tryParse(createdAtRaw?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return StyleAnalysisHistoryItem(
      id: json['id']?.toString() ?? createdAt.millisecondsSinceEpoch.toString(),
      data: analysis,
      createdAt: createdAt,
      imagePath: imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }
}
