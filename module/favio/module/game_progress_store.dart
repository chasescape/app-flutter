import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProgressStore extends ChangeNotifier {
  GameProgressStore._();

  static final GameProgressStore instance = GameProgressStore._();

  static const int _startingCoins = 220;
  static const int clearScoreTarget = 1000;
  static const String _bestScoreKey = 'game_progress_best_score_v1';
  static const String _lastScoreKey = 'game_progress_last_score_v1';
  static const String _totalRunsKey = 'game_progress_total_runs_v1';
  static const String _highestDangerLevelKey =
      'game_progress_highest_danger_level_v1';
  static const String _coinsKey = 'game_progress_coins_v1';
  static const String _totalRevivesKey = 'game_progress_total_revives_v1';

  int _bestScore = 0;
  int _lastScore = 0;
  int _totalRuns = 0;
  int _highestDangerLevel = 1;
  int _coins = _startingCoins;
  int _totalRevives = 0;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  int get bestScore => _bestScore;
  int get lastScore => _lastScore;
  int get totalRuns => _totalRuns;
  int get highestDangerLevel => _highestDangerLevel;
  int get coins => _coins;
  int get totalRevives => _totalRevives;
  double get clearProgress =>
      (_bestScore / clearScoreTarget).clamp(0.0, 1.0).toDouble();
  int get clearPercent => (clearProgress * 100).floor();
  bool get isCleared => _bestScore >= clearScoreTarget;

  String get rankLabel {
    if (isCleared) {
      return 'FAVIO MASTER';
    }
    if (_bestScore >= 700) {
      return 'FAVIO ELITE';
    }
    if (_bestScore >= 450) {
      return 'FAVIO ACE';
    }
    if (_bestScore >= 250) {
      return 'FAVIO RUNNER';
    }
    if (_totalRuns > 0) {
      return 'FAVIO START';
    }
    return 'NEW TO FAVIO';
  }

  String get statusLabel {
    if (isCleared) {
      return '100% clear achieved';
    }
    if (_totalRuns == 0) {
      return 'Tap start to begin your first run';
    }
    if (_lastScore == _bestScore && _bestScore > 0) {
      return 'New best score recorded';
    }
    if (_lastScore >= (_bestScore * 0.8).round()) {
      return 'Close to your best run';
    }
    return 'Best run sets your clear progress';
  }

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    _lastScore = prefs.getInt(_lastScoreKey) ?? 0;
    _totalRuns = prefs.getInt(_totalRunsKey) ?? 0;
    _highestDangerLevel = prefs.getInt(_highestDangerLevelKey) ?? 1;
    _coins = prefs.getInt(_coinsKey) ?? _startingCoins;
    _totalRevives = prefs.getInt(_totalRevivesKey) ?? 0;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> clearAll() async {
    _bestScore = 0;
    _lastScore = 0;
    _totalRuns = 0;
    _highestDangerLevel = 1;
    _coins = _startingCoins;
    _totalRevives = 0;
    _isLoaded = true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bestScoreKey);
    await prefs.remove(_lastScoreKey);
    await prefs.remove(_totalRunsKey);
    await prefs.remove(_highestDangerLevelKey);
    await prefs.remove(_coinsKey);
    await prefs.remove(_totalRevivesKey);
    notifyListeners();
  }

  void recordRun({
    required int score,
    required int coins,
    required int dangerLevel,
    bool countRun = true,
  }) {
    _lastScore = score;
    _coins = math.max(0, coins);
    if (countRun) {
      _totalRuns += 1;
    }
    _bestScore = math.max(_bestScore, score);
    _highestDangerLevel = math.max(_highestDangerLevel, dangerLevel);
    _save();
    notifyListeners();
  }

  void setCoins(int value) {
    final int normalizedValue = math.max(0, value);
    if (_coins == normalizedValue) {
      return;
    }
    _coins = normalizedValue;
    _save();
    notifyListeners();
  }

  void recordRevive({
    required int coins,
  }) {
    _coins = math.max(0, coins);
    _totalRevives += 1;
    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, _bestScore);
    await prefs.setInt(_lastScoreKey, _lastScore);
    await prefs.setInt(_totalRunsKey, _totalRuns);
    await prefs.setInt(_highestDangerLevelKey, _highestDangerLevel);
    await prefs.setInt(_coinsKey, _coins);
    await prefs.setInt(_totalRevivesKey, _totalRevives);
  }
}
