import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../interface.dart';
import '../models/nail_models.dart';

/// RecommendationResult 数据持久化工具
class RecommendationResultStorage {
  static const String _listKey = 'recommendation_history';
  static const int _maxHistory = 50;

  /// 保存数据到历史记录
  static Future<void> save(RecommendationResult data) async {
    await Interface.initPrefs();
    final prefs = Interface.prefs;
    final list = await getList();

    list.insert(0, data);
    if (list.length > _maxHistory) {
      list.removeRange(_maxHistory, list.length);
    }

    await _saveList(prefs, list);
  }

  /// 获取历史记录列表
  static Future<List<RecommendationResult>> getList() async {
    await Interface.initPrefs();
    final prefs = Interface.prefs;
    final jsonList = prefs.getStringList(_listKey);
    if (jsonList == null || jsonList.isEmpty) return [];

    try {
      return jsonList
          .map(
            (e) => RecommendationResult.fromJson(
              Map<String, dynamic>.from(
                jsonDecode(e) as Map,
              ),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('[RecommendationResultStorage] Failed to parse history: $e');
      return [];
    }
  }

  /// 删除指定记录
  static Future<bool> delete(String id) async {
    await Interface.initPrefs();
    final prefs = Interface.prefs;
    final list = await getList();
    final initialLength = list.length;

    list.removeWhere((item) => item.id == id);

    if (list.length < initialLength) {
      await _saveList(prefs, list);
      return true;
    }
    return false;
  }

  /// 清空所有记录
  static Future<void> clear() async {
    await Interface.initPrefs();
    final prefs = Interface.prefs;
    await prefs.remove(_listKey);
  }

  static Future<void> _saveList(
    dynamic prefs,
    List<RecommendationResult> list,
  ) async {
    final jsonList = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_listKey, jsonList);
  }
}
