import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/makeup_analysis.dart';

class StorageService {
  static StorageService? _instance;
  factory StorageService() => _instance ??= StorageService._internal();
  StorageService._internal();

  static const String _makeupHistoryKey = 'makeup_analysis_history';
  static const int _maxHistoryItems = 50;

  Future<List<MakeupAnalysis>> getMakeupHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_makeupHistoryKey) ?? [];

      return historyJson.map((jsonStr) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return MakeupAnalysis.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMakeupAnalysis(MakeupAnalysis analysis, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();

    final history = await getMakeupHistory();

    final analysisWithImage = analysis.copyWith(
      assetImg: imagePath,
    );

    history.insert(0, analysisWithImage);

    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    final historyJson = history.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_makeupHistoryKey, historyJson);
  }

  Future<void> clearMakeupHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_makeupHistoryKey);
  }

  Future<void> deleteMakeupAnalysis(int index) async {
    final history = await getMakeupHistory();

    if (index >= 0 && index < history.length) {
      history.removeAt(index);

      final prefs = await SharedPreferences.getInstance();
      final historyJson = history.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_makeupHistoryKey, historyJson);
    }
  }

  Future<int> getHistoryCount() async {
    final history = await getMakeupHistory();
    return history.length;
  }
}

extension MakeupAnalysisCopyWith on MakeupAnalysis {
  MakeupAnalysis copyWith({
    String? assetImg,
    FaceAnalysis? faceAnalysis,
    MakeupRecommendation? makeupRecommendation,
    SearchGuidance? searchGuidance,
    OccasionMatch? occasionMatch,
    QualityCheck? qualityCheck,
  }) {
    return MakeupAnalysis(
      assetImg: assetImg ?? this.assetImg,
      faceAnalysis: faceAnalysis ?? this.faceAnalysis,
      makeupRecommendation: makeupRecommendation ?? this.makeupRecommendation,
      searchGuidance: searchGuidance ?? this.searchGuidance,
      occasionMatch: occasionMatch ?? this.occasionMatch,
      qualityCheck: qualityCheck ?? this.qualityCheck,
    );
  }
}
