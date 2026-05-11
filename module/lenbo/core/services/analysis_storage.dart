import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lenbo/lenbo/data/models/plant_analysis.dart';
import 'package:lenbo/lenbo/core/utils/constants.dart';

/// Storage service for plant analysis history using SharedPreferences.
class AnalysisStorage {
  static const int maxHistoryCount = 50;

  /// Notifier for history changes (used by HistoryPage to refresh).
  static final ValueNotifier<int> historyNotifier = ValueNotifier(0);

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Load all analysis history, sorted by creation time (newest first).
  static Future<List<PlantAnalysis>> loadHistory() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(AppConstants.historyKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      final items = jsonList.whereType<Map<String, dynamic>>().toList();

      // Sort by _created_at descending (newest first)
      items.sort((a, b) {
        final aTime = a['_created_at'] as String? ?? '';
        final bTime = b['_created_at'] as String? ?? '';
        return bTime.compareTo(aTime);
      });

      final validItems = <Map<String, dynamic>>[];
      var removedMissingImage = false;

      for (final item in items) {
        final assetImg = item['assetImg'] as String? ?? '';
        final isBundledAsset = assetImg.startsWith('assets/');
        final shouldCheckLocalFile = assetImg.isNotEmpty && !isBundledAsset;

        if (shouldCheckLocalFile && !await File(assetImg).exists()) {
          removedMissingImage = true;
          continue;
        }

        validItems.add(item);
      }

      if (removedMissingImage) {
        await prefs.setString(AppConstants.historyKey, jsonEncode(validItems));
      }

      return validItems.map((e) => PlantAnalysis.fromJson(e)).toList();
    } catch (e) {
      print('[AnalysisStorage] Failed to load history: $e');
      return [];
    }
  }

  /// Save a new analysis result to history.
  static Future<void> saveAnalysis(PlantAnalysis analysis) async {
    final prefs = await _getPrefs();

    // Load existing history
    List<Map<String, dynamic>> existing = [];
    final jsonStr = prefs.getString(AppConstants.historyKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        existing = jsonList.whereType<Map<String, dynamic>>().toList();
      } catch (_) {
        // Corrupted data, start fresh
      }
    }

    // Create new item with timestamp
    final itemMap = analysis.toJson();
    itemMap['_created_at'] = DateTime.now().toIso8601String();
    existing.insert(0, itemMap);

    // Limit to max records
    while (existing.length > maxHistoryCount) {
      existing.removeLast();
    }

    await prefs.setString(AppConstants.historyKey, jsonEncode(existing));
    historyNotifier.value++;
    print('[AnalysisStorage] Analysis saved. Total records: ${existing.length}');
  }

  /// Clear all analysis history.
  static Future<void> clearHistory() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.historyKey);
    historyNotifier.value++;
    print('[AnalysisStorage] History cleared');
  }
}
