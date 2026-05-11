import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Emotion analysis result model
class EmotionResult {
  final String id;
  final String imageUrl;
  final String emotionText;
  final String emotionType;
  final int confidence;
  final DateTime createdAt;
  final List<String> tags;

  EmotionResult({
    required this.id,
    required this.imageUrl,
    required this.emotionText,
    required this.emotionType,
    required this.confidence,
    required this.createdAt,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'emotionText': emotionText,
      'emotionType': emotionType,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory EmotionResult.fromJson(Map<String, dynamic> json) {
    return EmotionResult(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      emotionText: json['emotionText'] as String,
      emotionType: json['emotionType'] as String,
      confidence: json['confidence'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags: List<String>.from(json['tags'] as List),
    );
  }
}

/// History Service - Manages user's emotion analysis history
class HistoryService extends GetxService {
  static HistoryService get to => Get.find();

  final RxList<EmotionResult> historyList = <EmotionResult>[].obs;
  SharedPreferences? _prefs;

  static const String _keyHistory = 'emotion_history';

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _loadHistory();
  }

  /// Load history from local storage
  Future<void> _loadHistory() async {
    if (_prefs == null) return;

    final historyJson = _prefs!.getString(_keyHistory);
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        historyList.value = decoded
            .map((item) => EmotionResult.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error loading history: $e');
      }
    }
  }

  /// Save history to local storage
  Future<void> _saveHistory() async {
    if (_prefs == null) return;

    final historyJson = jsonEncode(
      historyList.map((item) => item.toJson()).toList(),
    );
    await _prefs!.setString(_keyHistory, historyJson);
  }

  /// Add new emotion result to history
  Future<void> addResult(EmotionResult result) async {
    historyList.insert(0, result); // Add to beginning of list
    await _saveHistory();
  }

  /// Delete a specific result from history
  Future<void> deleteResult(String id) async {
    historyList.removeWhere((item) => item.id == id);
    await _saveHistory();
  }

  /// Clear all history
  Future<void> clearHistory() async {
    historyList.clear();
    if (_prefs != null) {
      await _prefs!.remove(_keyHistory);
    }
  }

  /// Get history list sorted by date (newest first)
  List<EmotionResult> get sortedHistory {
    final list = List<EmotionResult>.from(historyList);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Get filtered history by emotion type
  List<EmotionResult> getHistoryByType(String emotionType) {
    return historyList.where((item) => item.emotionType == emotionType).toList();
  }
}
