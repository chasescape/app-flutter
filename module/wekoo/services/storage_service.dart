import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../models/drink_record.dart';
import '../models/user_settings.dart';
import '../models/result_card.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  late final SharedPreferences _prefs;

  static const String _keyRecords = 'drink_records';
  static const String _keySettings = 'user_settings';
  static const String _keyCoins = 'user_coins';
  static const String _keyFreeResults = 'free_results';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyResultCards = 'result_cards';

  SharedPreferences get prefs => _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  List<DrinkRecord> getRecords() {
    final String? recordsJson = _prefs.getString(_keyRecords);
    if (recordsJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      return decoded.map((e) => DrinkRecord.fromJson(e)).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      return [];
    }
  }

  Future<void> saveRecords(List<DrinkRecord> records) async {
    final String encoded = jsonEncode(
      records.map((e) => e.toJson()).toList(),
    );
    await _prefs.setString(_keyRecords, encoded);
  }

  Future<void> addRecord(DrinkRecord record) async {
    final records = getRecords();
    records.add(record);
    await saveRecords(records);
  }

  Future<void> deleteRecord(String id) async {
    final records = getRecords();
    records.removeWhere((r) => r.id == id);
    await saveRecords(records);
  }

  Future<void> clearRecords() async {
    await _prefs.remove(_keyRecords);
  }

  UserSettings getSettings() {
    final String? settingsJson = _prefs.getString(_keySettings);
    if (settingsJson == null) return UserSettings();

    try {
      return UserSettings.fromJson(jsonDecode(settingsJson));
    } catch (e) {
      return UserSettings();
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    final String encoded = jsonEncode(settings.toJson());
    await _prefs.setString(_keySettings, encoded);
  }

  int getCoins() {
    return _prefs.getInt(_keyCoins) ?? 10;
  }

  Future<void> setCoins(int amount) async {
    await _prefs.setInt(_keyCoins, amount);
  }

  Future<void> addCoins(int amount) async {
    final current = getCoins();
    await setCoins(current + amount);
  }

  Future<bool> deductCoins(int amount) async {
    final current = getCoins();
    if (current < amount) return false;
    await setCoins(current - amount);
    return true;
  }

  int getFreeResults() {
    return _prefs.getInt(_keyFreeResults) ?? 3;
  }

  Future<void> setFreeResults(int count) async {
    await _prefs.setInt(_keyFreeResults, count);
  }

  Future<bool> useFreeResult() async {
    final current = getFreeResults();
    if (current <= 0) return false;
    await setFreeResults(current - 1);
    return true;
  }

  Future<void> clearAllData() async {
    await _prefs.remove(_keyRecords);
    await _prefs.remove(_keySettings);
    await _prefs.remove(_keyCoins);
    await _prefs.remove(_keyFreeResults);
    await _prefs.remove(_keyResultCards);
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyUserId);
  }

  int getTodayAmount() {
    final records = getRecords();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return records
        .where((r) => r.dateTime.isAfter(today))
        .fold(0, (sum, r) => sum + r.amount);
  }

  int getTodayCount() {
    final records = getRecords();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return records.where((r) => r.dateTime.isAfter(today)).length;
  }

  Map<String, int> getWeekData() {
    final records = getRecords();
    final now = DateTime.now();
    final result = <String, int>{};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayStart = date;
      final dayEnd = date.add(const Duration(days: 1));

      final amount = records
          .where((r) => r.dateTime.isAfter(dayStart) && r.dateTime.isBefore(dayEnd))
          .fold(0, (sum, r) => sum + r.amount);

      result[date.toIso8601String().split('T')[0]] = amount;
    }

    return result;
  }

  int getStreak() {
    final records = getRecords();
    if (records.isEmpty) return 0;

    final settings = getSettings();
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final dayStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final hasRecord = records.any((r) =>
          r.dateTime.isAfter(dayStart) && r.dateTime.isBefore(dayEnd));

      if (!hasRecord) {
        if (streak == 0) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          if (checkDate.day == DateTime.now().day) break;
          continue;
        }
        break;
      }

      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));

      if (streak > 365) break;
    }

    return streak;
  }

  List<ResultCard> getResultCards() {
    final String? cardsJson = _prefs.getString(_keyResultCards);
    if (cardsJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(cardsJson);
      return decoded.map((e) => ResultCard.fromJson(e)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  Future<void> saveResultCards(List<ResultCard> cards) async {
    final String encoded = jsonEncode(
      cards.map((e) => e.toJson()).toList(),
    );
    await _prefs.setString(_keyResultCards, encoded);
  }

  Future<void> addResultCard(ResultCard card) async {
    final cards = getResultCards();
    cards.add(card);
    await saveResultCards(cards);
  }

  Future<void> deleteResultCard(String id) async {
    final cards = getResultCards();
    cards.removeWhere((c) => c.id == id);
    await saveResultCards(cards);
  }

  Future<void> clearResultCards() async {
    await _prefs.remove(_keyResultCards);
  }
}
