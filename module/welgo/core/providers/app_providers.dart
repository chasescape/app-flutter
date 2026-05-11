import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ingredient_analysis.dart';
import '../models/user_data.dart';
import '../managers/coins_manager.dart';

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final userDataProvider =
    StateNotifierProvider<UserDataNotifier, UserData>((ref) {
  return UserDataNotifier();
});

class UserDataNotifier extends StateNotifier<UserData> {
  UserDataNotifier() : super(const UserData()) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt(CoinsManager.storageKey) ??
        prefs.getInt('user_coins') ??
        0;
    final freeUses = prefs.getInt('free_uses') ?? (1 + (coins % 3));
    final nickname = prefs.getString('nickname') ?? 'Guest';
    final avatar = prefs.getString('avatar') ?? '';

    state = UserData(
      coins: coins,
      freeUses: freeUses,
      nickname: nickname,
      avatar: avatar,
    );
  }

  Future<void> setCoins(int coins) async {
    await CoinsManager.instance.setCoins(coins);
    state = state.copyWith(coins: coins);
  }

  Future<void> setFreeUses(int freeUses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('free_uses', freeUses);
    state = state.copyWith(freeUses: freeUses);
  }

  Future<void> setNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
    state = state.copyWith(nickname: nickname);
  }

  Future<void> setAvatar(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar', avatar);
    state = state.copyWith(avatar: avatar);
  }

  Future<void> consumeAnalysis(int cost) async {
    if (state.freeUses > 0) {
      await setFreeUses(state.freeUses - 1);
    } else {
      await CoinsManager.instance.subCoins(cost);
      state = state.copyWith(coins: CoinsManager.instance.currentCoins);
    }
  }

  Future<void> addCoins(int coins) async {
    await CoinsManager.instance.addCoins(coins);
    state = state.copyWith(coins: CoinsManager.instance.currentCoins);
  }

  Future<void> clearAll() async {
    await CoinsManager.instance.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const UserData();
  }

  void resetState() {
    state = const UserData();
  }
}

final analysisHistoryProvider =
    StateNotifierProvider<AnalysisHistoryNotifier, List<IngredientAnalysis>>(
        (ref) {
  return AnalysisHistoryNotifier();
});

class AnalysisHistoryNotifier extends StateNotifier<List<IngredientAnalysis>> {
  AnalysisHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('analysis_history');
    if (historyJson == null || historyJson.isEmpty) {
      state = [];
      return;
    }
    final List<dynamic> jsonList = [];
    try {
      final decoded = jsonDecode(historyJson) as List<dynamic>;
      jsonList.addAll(decoded);
    } catch (e) {
      state = [];
      return;
    }
    final history = jsonList
        .map(
            (json) => IngredientAnalysis.fromJson(json as Map<String, dynamic>))
        .toList();
    state = history;
  }

  Future<void> addAnalysis(IngredientAnalysis analysis) async {
    final newHistory = [analysis, ...state];
    state = newHistory;
    await _saveHistory();
  }

  Future<void> deleteAnalysis(String id) async {
    state = state.where((a) => a.id != id).toList();
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    state = [];
    await _saveHistory();
  }

  void resetState() {
    state = [];
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = state.map((a) => a.toJson()).toList();
    final jsonString = jsonEncode(historyJson);
    await prefs.setString('analysis_history', jsonString);
  }
}

final analysisCostProvider = Provider<int>((ref) {
  return 50 + (DateTime.now().millisecond % 51);
});

final hasFreeUsesProvider = Provider<bool>((ref) {
  final userData = ref.watch(userDataProvider);
  return userData.freeUses > 0;
});

final canAnalyzeProvider = Provider<bool>((ref) {
  final userData = ref.watch(userDataProvider);
  final cost = ref.watch(analysisCostProvider);
  return userData.freeUses > 0 || userData.coins >= cost;
});
