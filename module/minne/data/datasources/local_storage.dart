import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local Storage - Handles data persistence using SharedPreferences
class LocalStorage {
  LocalStorage._();

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyCreations = 'creations_data';
  static const String _keyCherishCards = 'cherish_cards_data';
  static const String _keyCoins = 'user_coins';
  static const int _defaultCoins = 100;

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // Auth Token
  static Future<void> setToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyToken);
  }

  static Future<void> removeToken() async {
    final prefs = await _prefs;
    await prefs.remove(_keyToken);
  }

  // User Data
  static Future<void> setUserData(Map<String, dynamic> data) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUser, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _prefs;
    final data = prefs.getString(_keyUser);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> removeUserData() async {
    final prefs = await _prefs;
    await prefs.remove(_keyUser);
  }

  // Creations Data
  static Future<void> setCreationsData(List<Map<String, dynamic>> data) async {
    final prefs = await _prefs;
    await prefs.setString(_keyCreations, jsonEncode(data));
  }

  static Future<List<Map<String, dynamic>>> getCreationsData() async {
    final prefs = await _prefs;
    final data = prefs.getString(_keyCreations);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> removeCreationsData() async {
    final prefs = await _prefs;
    await prefs.remove(_keyCreations);
  }

  // Clear All Data
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  // CherishCards Data - For storing CherishCard objects
  static Future<void> setCherishCardsData(List<String> cardsJson) async {
    final prefs = await _prefs;
    await prefs.setStringList(_keyCherishCards, cardsJson);
  }

  static Future<List<String>> getCherishCardsData() async {
    final prefs = await _prefs;
    return prefs.getStringList(_keyCherishCards) ?? [];
  }

  static Future<void> addCherishCard(String cardJson) async {
    final cards = await getCherishCardsData();
    cards.insert(0, cardJson); // Add to beginning
    await setCherishCardsData(cards);
  }

  // Coins Data - For storing user coin balance
  static Future<void> setCoins(int coins) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyCoins, coins);
  }

  static Future<int> getCoins() async {
    final prefs = await _prefs;
    // First install: seed the wallet with a default balance.
    if (!prefs.containsKey(_keyCoins)) {
      await prefs.setInt(_keyCoins, _defaultCoins);
      return _defaultCoins;
    }
    return prefs.getInt(_keyCoins) ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    final currentCoins = await getCoins();
    await setCoins(currentCoins + amount);
  }

  static Future<void> subCoins(int amount) async {
    final currentCoins = await getCoins();
    await setCoins(currentCoins > amount ? currentCoins - amount : 0);
  }

  static Future<bool> isEnoughCoins(int required) async {
    final currentCoins = await getCoins();
    return currentCoins >= required;
  }
}
