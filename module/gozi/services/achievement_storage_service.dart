import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/achievement.dart';

/// Achievement Storage Service - Manages achievement history
class AchievementStorageService extends GetxService {
  static AchievementStorageService get to => Get.find();

  final RxList<Achievement> _achievements = <Achievement>[].obs;
  static const String _storageKey = 'achievements';
  static const int _maxStorage = 50;

  /// Get all achievements
  List<Achievement> get achievements => _achievements;

  /// Achievements stream
  RxList<Achievement> get achievementsStream => _achievements;

  @override
  void onInit() {
    super.onInit();
    _loadAchievements();
  }

  /// Load achievements from storage
  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_storageKey);

      if (jsonData != null && jsonData.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonData);
        _achievements.value = jsonList
            .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  /// Save achievements to storage
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData =
          jsonEncode(_achievements.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, jsonData);
    } catch (e) {
      print('Error saving achievements: $e');
    }
  }

  /// Add new achievement
  Future<void> addAchievement(Achievement achievement) async {
    _achievements.insert(0, achievement);

    // Keep only recent 50
    if (_achievements.length > _maxStorage) {
      _achievements.removeRange(_maxStorage, _achievements.length);
    }

    await _saveAchievements();
  }

  /// Delete achievement
  Future<void> deleteAchievement(String id) async {
    _achievements.removeWhere((a) => a.id == id);
    await _saveAchievements();
  }

  /// Update achievement
  Future<void> updateAchievement(Achievement achievement) async {
    final index = _achievements.indexWhere((a) => a.id == achievement.id);
    if (index != -1) {
      _achievements[index] = achievement;
      await _saveAchievements();
    }
  }

  /// Get achievement by id
  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get achievements by type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  /// Get all saved goal folders/categories.
  List<String> getCategories() {
    final categories = _achievements
        .map((achievement) => achievement.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return categories;
  }

  /// Get achievements inside a goal folder/category.
  List<Achievement> getAchievementsByCategory(String category) {
    return _achievements
        .where((achievement) => achievement.category == category)
        .toList();
  }

  /// Count cards inside a goal folder/category.
  int getCategoryCount(String category) {
    return _achievements
        .where((achievement) => achievement.category == category)
        .length;
  }

  /// Clear all achievements
  Future<void> clearAll() async {
    _achievements.clear();
    await _saveAchievements();
  }

  /// Get recent achievements (last 10)
  List<Achievement> getRecentAchievements({int count = 10}) {
    return _achievements.take(count).toList();
  }
}
