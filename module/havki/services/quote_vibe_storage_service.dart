import 'dart:convert';

import 'package:havki/havki/data/models/quote/quote_vibe_analysis_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// QuoteVibe Storage Service - Manages QuoteVibe analysis history
class QuoteVibeStorageService {
  QuoteVibeStorageService._();

  static QuoteVibeStorageService? _instance;
  static QuoteVibeStorageService get instance {
    _instance ??= QuoteVibeStorageService._();
    return _instance!;
  }

  SharedPreferences? _prefs;
  static const String _keyHistory = 'quote_vibe_history';
  final List<QuoteVibeAnalysisData> _historyList = [];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_prefs == null) {
      await initialize();
    }
    if (_prefs == null) {
      return;
    }

    final historyJson = _prefs!.getString(_keyHistory);
    if (historyJson == null || historyJson.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(historyJson) as List<dynamic>;
      _historyList
        ..clear()
        ..addAll(
          decoded.map(
            (item) => QuoteVibeAnalysisData.fromJson(item as Map<String, dynamic>),
          ),
        );
    } catch (_) {
      _historyList.clear();
    }
  }

  Future<void> _saveHistory() async {
    if (_prefs == null) {
      return;
    }

    final historyJson = jsonEncode(
      _historyList.map((item) => item.toJson()).toList(),
    );
    await _prefs!.setString(_keyHistory, historyJson);
  }

  Future<void> addResult(QuoteVibeAnalysisData result) async {
    _historyList.insert(0, result);
    await _saveHistory();
  }

  Future<void> deleteResult(String id) async {
    _historyList.removeWhere((item) => item.id == id);
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _historyList.clear();
    if (_prefs != null) {
      await _prefs!.remove(_keyHistory);
    }
  }

  List<QuoteVibeAnalysisData> get history {
    final list = List<QuoteVibeAnalysisData>.from(_historyList);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<QuoteVibeAnalysisData> getHistoryByStyle(QuoteVibeStyle style) {
    return _historyList
        .where((item) => item.styleSignature.contains(style.value))
        .toList();
  }

  List<QuoteVibeAnalysisData> getHistoryByMood(String mood) {
    return _historyList
        .where((item) => item.sceneAnalysis.primaryMood == mood)
        .toList();
  }

  int get count => _historyList.length;

  bool get isEmpty => _historyList.isEmpty;

  bool get isNotEmpty => _historyList.isNotEmpty;
}
