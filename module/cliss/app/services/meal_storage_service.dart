import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cliss/cliss/data/models/meal_analysis.dart';

class MealStorageService {
  MealStorageService._();

  static late final MealStorageService _instance = MealStorageService._internal();
  static MealStorageService get instance => _instance;

  MealStorageService._internal();

  static const String _mealHistoryKey = 'meal_analysis_history';
  static const int _maxHistoryItems = 100;

  Future<void> saveMealAnalysis(MealAnalysis meal) async {
    final prefs = await SharedPreferences.getInstance();

    final List<dynamic> historyList = prefs.getStringList(_mealHistoryKey)?.map((e) => jsonDecode(e)).toList() ?? [];
    historyList.insert(0, meal.toJson());

    if (historyList.length > _maxHistoryItems) {
      historyList.removeRange(_maxHistoryItems, historyList.length);
    }

    final jsonStringList = historyList.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(_mealHistoryKey, jsonStringList);
  }

  Future<List<MealAnalysis>> getMealHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyStrings = prefs.getStringList(_mealHistoryKey);

    if (historyStrings == null || historyStrings.isEmpty) {
      return [];
    }

    try {
      return historyStrings.map(( jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return MealAnalysis.fromJson(json);
      }).toList();
    } catch (e) {
      print('[MealStorageService] Error parsing history: $e');
      return [];
    }
  }

  Future<void> clearMealHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mealHistoryKey);
  }

  Future<int> getHistoryCount() async {
    final prefs = await SharedPreferences.getInstance();
    final historyStrings = prefs.getStringList(_mealHistoryKey);
    return historyStrings?.length ?? 0;
  }

  Future<void> deleteMealAnalysis(String assetImg) async {
    final prefs = await SharedPreferences.getInstance();
    final historyStrings = prefs.getStringList(_mealHistoryKey);

    if (historyStrings == null) return;

    final filteredList = historyStrings.where((itemString) {
      try {
        final json = jsonDecode(itemString) as Map<String, dynamic>;
        return json['asset_img'] != assetImg;
      } catch (e) {
        return true;
      }
    }).toList();

    await prefs.setStringList(_mealHistoryKey, filteredList);
  }

  Future<MealAnalysis?> getLatestMeal() async {
    final history = await getMealHistory();
    if (history.isEmpty) return null;
    return history.first;
  }
}
