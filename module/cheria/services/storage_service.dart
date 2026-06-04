import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/novel.dart';

/// Storage Service
/// Handles local data persistence
class StorageService {
  StorageService._();

  static const String _novelsKey = 'novels';
  static const String _coinBalanceKey = 'coin_balance';
  static const String _freeCountKey = 'free_count';
  static const String _achievementsKey = 'achievements';
  static const String _settingsKey = 'settings';
  static const String _authTokenKey = 'auth_token';

  static SharedPreferences? _prefs;

  /// Initialize storage
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save novels
  static Future<void> saveNovels(List<Novel> novels) async {
    await init();
    final jsonList = novels.map((n) => n.toJson()).toList();
    await _prefs!.setString(_novelsKey, jsonEncode(jsonList));
  }

  /// Load novels
  static Future<List<Novel>> loadNovels() async {
    await init();
    final jsonString = _prefs!.getString(_novelsKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => Novel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Save coin balance
  static Future<void> saveCoinBalance(int balance) async {
    await init();
    await _prefs!.setInt(_coinBalanceKey, balance);
  }

  /// Load coin balance
  static Future<int> loadCoinBalance() async {
    await init();
    return _prefs!.getInt(_coinBalanceKey) ?? 0;
  }

  /// Save free count
  static Future<void> saveFreeCount(int count) async {
    await init();
    await _prefs!.setInt(_freeCountKey, count.clamp(0, 1).toInt());
  }

  /// Load free count
  static Future<int> loadFreeCount() async {
    await init();
    final saved = _prefs!.getInt(_freeCountKey);
    if (saved != null) return saved.clamp(0, 1).toInt();
    return 1;
  }

  /// Save achievements
  static Future<void> saveAchievements(List<Achievement> achievements) async {
    await init();
    final jsonList = achievements.map((a) => a.toJson()).toList();
    await _prefs!.setString(_achievementsKey, jsonEncode(jsonList));
  }

  /// Load achievements
  static Future<List<Achievement>> loadAchievements() async {
    await init();
    final jsonString = _prefs!.getString(_achievementsKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
    await _prefs!.setInt(_coinBalanceKey, 0);
    await _prefs!.setInt(_freeCountKey, 0);
  }

  /// Clear specific key
  static Future<void> clearKey(String key) async {
    await init();
    await _prefs!.remove(key);
  }

  /// Save auth token (登录信息持久化)
  static Future<void> saveAuthToken(String token) async {
    await init();
    await _prefs!.setString(_authTokenKey, token);
  }

  /// Load auth token (读取登录信息)
  static Future<String?> loadAuthToken() async {
    await init();
    return _prefs!.getString(_authTokenKey);
  }

  /// Clear auth token (清除登录信息)
  static Future<void> clearAuthToken() async {
    await init();
    await _prefs!.remove(_authTokenKey);
  }

  /// Check if user is logged in (检查登录态)
  static Future<bool> isLoggedIn() async {
    await init();
    return _prefs!.containsKey(_authTokenKey);
  }
}
