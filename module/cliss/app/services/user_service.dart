import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cliss/cliss/interface.dart';
import 'package:cliss/cliss/app/services/coins_manager.dart';

class UserService {
  UserService._();

  static late final UserService _instance = UserService._internal();
  static UserService get instance => _instance;

  UserService._internal();

  static const String _keyLiked = 'user_liked';
  static const String _keyCreated = 'user_created';

  ValueNotifier<int> get coinsV => CoinsManager.instance.coinsV;
  final ValueNotifier<int> likedV = ValueNotifier<int>(0);
  final ValueNotifier<int> createdV = ValueNotifier<int>(0);

  Future<void> init() async {
    await CoinsManager.instance.init();
    final prefs = await SharedPreferences.getInstance();
    likedV.value = prefs.getInt(_keyLiked) ?? 0;
    createdV.value = prefs.getInt(_keyCreated) ?? 0;
  }

  Future<void> addCoins(int amount) async {
    await CoinsManager.instance.addCoins(amount);
  }

  Future<void> spendCoins(int amount) async {
    await CoinsManager.instance.subCoins(amount);
  }

  bool hasEnoughCoins(int amount) {
    return CoinsManager.instance.isEnough(amount);
  }

  Future<void> incrementLiked() async {
    final prefs = await SharedPreferences.getInstance();
    likedV.value++;
    await prefs.setInt(_keyLiked, likedV.value);
  }

  Future<void> incrementCreated() async {
    final prefs = await SharedPreferences.getInstance();
    createdV.value++;
    await prefs.setInt(_keyCreated, createdV.value);
  }

  Future<void> clear() async {
    await CoinsManager.instance.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLiked);
    await prefs.remove(_keyCreated);
    likedV.value = 0;
    createdV.value = 0;
  }
}
