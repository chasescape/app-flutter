import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.date,
    required this.photoUrl,
    required this.userInput,
    required this.aiDiary,
    required this.mood,
  });

  final String id;
  final DateTime date;
  final String photoUrl;
  final String userInput;
  final String aiDiary;
  final String mood;

  // 转换为JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'photoUrl': photoUrl,
        'userInput': userInput,
        'aiDiary': aiDiary,
        'mood': mood,
      };

  // 从JSON创建
  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'],
        date: DateTime.parse(json['date']),
        photoUrl: json['photoUrl'],
        userInput: json['userInput'],
        aiDiary: json['aiDiary'],
        mood: json['mood'],
      );
}

class FliraState {
  static const int initialCoins = 120;
  static const String _coinsKey = 'flira_coins';
  static const String _entriesKey = 'flira_entries';

  static final RxInt coins = initialCoins.obs;
  static final RxList<DiaryEntry> entries = <DiaryEntry>[].obs;

  /// 初始化 - 从持久化加载数据
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载金币
    final savedCoins = prefs.getInt(_coinsKey);
    if (savedCoins != null) {
      coins.value = savedCoins;
      print('加载金币: $savedCoins');
    } else {
      coins.value = initialCoins;
      await _saveCoins();
    }

    // 加载日记列表
    final savedEntries = prefs.getString(_entriesKey);
    if (savedEntries != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(savedEntries);
        entries.value = jsonList.map((json) => DiaryEntry.fromJson(json)).toList();
        print('加载日记: ${entries.length}条');
      } catch (e) {
        print('加载日记失败: $e');
      }
    }
  }

  /// 保存金币到持久化
  static Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins.value);
  }

  /// 保存日记列表到持久化
  static Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((entry) => entry.toJson()).toList();
    await prefs.setString(_entriesKey, jsonEncode(jsonList));
  }

  static Future<bool> spendCoins(int amount) async {
    if (coins.value < amount) return false;
    coins.value -= amount;
    await _saveCoins();
    return true;
  }

  static Future<void> addCoins(int amount) async {
    coins.value += amount;
    await _saveCoins();
  }

  static Future<void> addEntry(DiaryEntry entry) async {
    entries.insert(0, entry);
    await _saveEntries();
  }

  /// 注销账号时清理本地用户数据（金币、生成记录）
  static Future<void> clearUserDataForDeleteAccount() async {
    coins.value = 0;
    entries.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coinsKey);
    await prefs.remove(_entriesKey);
  }
}
