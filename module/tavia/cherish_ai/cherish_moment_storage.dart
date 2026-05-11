import 'dart:io';
import 'dart:convert';

import '../data/models/cherish_moment.dart';
import '../interface.dart';
import '../shared/models/content_model.dart';

class CherishMomentHistoryItem {
  final String id;
  final CherishMoment data;
  final DateTime createdAt;
  final String? imagePath;

  const CherishMomentHistoryItem({
    required this.id,
    required this.data,
    required this.createdAt,
    this.imagePath,
  });

  factory CherishMomentHistoryItem.fromJson(Map<String, dynamic> json) {
    return CherishMomentHistoryItem(
      id: json['id'] as String,
      data: CherishMoment.fromJson(json['data'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      imagePath: json['image_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data.toJson(),
      'created_at': createdAt.toIso8601String(),
      'image_path': imagePath,
    };
  }

  ContentModel toContentModel() {
    return ContentModel.fromCherishMoment(
      id: id,
      moment: data,
      imagePath: imagePath,
      createdAt: createdAt,
    );
  }
}

/// CherishMoment persistence using the project Interface.prefs entrypoint.
class CherishMomentStorage {
  static const String _listKey = 'cherish_moment_history_list';

  static Future<CherishMomentHistoryItem> save(
    CherishMoment data, {
    String? imagePath,
  }) async {
    final list = await getList();
    final item = CherishMomentHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: data,
      createdAt: DateTime.now(),
      imagePath: imagePath,
    );

    list.insert(0, item);
    await _writeList(list);
    return item;
  }

  static Future<List<CherishMomentHistoryItem>> getList() async {
    final raw = Interface.prefs.getStringList(_listKey) ?? const <String>[];
    return raw
        .map((item) => CherishMomentHistoryItem.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            ))
        .toList();
  }

  static Future<void> remove(String id) async {
    final list = await getList();
    list.removeWhere((item) => item.id == id);
    await _writeList(list);
  }

  static Future<void> clear() {
    return Interface.prefs.remove(_listKey);
  }

  static Future<List<ContentModel>> getContentHistory() async {
    final list = await getList();
    return list.map((item) => item.toContentModel()).toList();
  }

  static Future<List<ContentModel>> getContentHistoryPruned() async {
    final list = await getList();
    final validItems = list.where(_hasAvailableImage).toList();

    if (validItems.length != list.length) {
      await _writeList(validItems);
    }

    return validItems.map((item) => item.toContentModel()).toList();
  }

  static bool _hasAvailableImage(CherishMomentHistoryItem item) {
    final source = (item.imagePath ?? item.data.assetImg).trim();
    if (source.isEmpty) {
      return false;
    }
    if (source.startsWith('http') || source.startsWith('assets/')) {
      return true;
    }
    return File(source).existsSync();
  }

  static Future<void> _writeList(List<CherishMomentHistoryItem> list) {
    final encoded = list.map((item) => jsonEncode(item.toJson())).toList();
    return Interface.prefs.setStringList(_listKey, encoded);
  }
}
