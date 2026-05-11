import 'package:intl/intl.dart';
import '../core/mixin/singleton_mixin.dart';
import '../core/utils/date_utils.dart';
import '../models/checkin_model.dart';
import '../models/achievement_model.dart';
import '../models/coin_package.dart';
import 'storage_service.dart';
import 'coins_manager.dart';

class CheckInService with SingletonMixin<CheckInService> {
  CheckInService._();

  static CheckInService get instance =>
      SingletonMixin.getInstance(() => CheckInService._());

  final StorageService _storage = StorageService.instance;
  CoinsManager get _coinsManager => CoinsManager.instance;

  static const List<String> morningQuotes = [
    "Good morning! Rise and shine!",
    "Every morning brings new potential.",
    "Today is a new beginning.",
    "Wake up with determination, go to bed with satisfaction.",
    "The way to get started is to quit talking and begin doing.",
    "Don't watch the clock; do what it does. Keep going.",
    "The secret of getting ahead is getting started.",
    "Your future is created by what you do today, not tomorrow.",
    "Morning is wonderful. Its only drawback is that it comes at such an inconvenient time of day.",
    "Be willing to be a beginner every single morning.",
  ];

  CheckInRecord? getTodayRecord() {
    final records = _storage.getCheckInRecords();
    final today = AppDateUtils.todayStart();
    for (final record in records) {
      if (AppDateUtils.isSameDay(record.checkInTime, today)) {
        return record;
      }
    }
    return null;
  }

  List<CheckInRecord> getAllRecords() {
    return _storage.getCheckInRecords()..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
  }

  int getCurrentStreak() {
    final records = _storage.getCheckInRecords();
    if (records.isEmpty) return 0;

    records.sort((a, b) => a.checkInTime.compareTo(b.checkInTime));
    int streak = 0;
    for (int i = records.length - 1; i >= 0; i--) {
      final recordDate = AppDateUtils.todayStart().subtract(
        Duration(days: records.length - 1 - i),
      );
      if (AppDateUtils.isSameDay(records[i].checkInTime, recordDate)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<CheckInRecord> performCheckIn() async {
    final now = DateTime.now();
    final targetTimeStr = _storage.targetWakeTime ?? '07:00';
    final targetTime = DateFormat('HH:mm').parse(targetTimeStr);
    final targetDateTime = DateTime(now.year, now.month, now.day, targetTime.hour, targetTime.minute);

    final earlyThreshold = targetDateTime.subtract(const Duration(minutes: 30));
    final lateThreshold = targetDateTime.add(const Duration(minutes: 30));

    CheckInStatus status;
    if (now.isBefore(earlyThreshold)) {
      status = CheckInStatus.earlyBird;
    } else if (now.isBefore(lateThreshold)) {
      status = CheckInStatus.onTime;
    } else {
      status = CheckInStatus.lateNightOwl;
    }

    final currentStreak = getCurrentStreak() + 1;
    final quote = morningQuotes[now.millisecond % morningQuotes.length];

    final record = CheckInRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      checkInTime: now,
      streak: currentStreak,
      motivationalQuote: quote,
      status: status,
    );

    final records = _storage.getCheckInRecords();
    records.add(record);
    await _storage.saveCheckInRecords(records);
    await _storage.setLastCheckInDate(AppDateUtils.formatDate(now));

    await _checkAndUnlockAchievements();

    return record;
  }

  Future<void> _checkAndUnlockAchievements() async {
    final achievements = _storage.getAchievements();
    final records = _storage.getCheckInRecords();
    final streak = getCurrentStreak();

    bool updated = false;

    for (var i = 0; i < achievements.length; i++) {
      if (achievements[i].isUnlocked) continue;

      bool shouldUnlock = false;
      switch (achievements[i].id) {
        case 'first_step':
          shouldUnlock = records.isNotEmpty;
          break;
        case 'streak_3':
          shouldUnlock = streak >= 3;
          break;
        case 'streak_7':
          shouldUnlock = streak >= 7;
          break;
        case 'early_bird':
          final earlyCount = records.where((r) => r.status == CheckInStatus.earlyBird).length;
          shouldUnlock = earlyCount >= 5;
          break;
        case 'morning_master':
          shouldUnlock = records.length >= 30;
          break;
      }

      if (shouldUnlock) {
        achievements[i] = achievements[i].copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        updated = true;
      }
    }

    if (updated) {
      await _storage.saveAchievements(achievements);
    }
  }

  Future<int> getCoins() async {
    return _coinsManager.currentCoins;
  }

  Future<bool> hasFreeAttempts() async {
    return false;
  }

  Future<int> getFreeAttempts() async {
    return 0;
  }

  Future<bool> canCheckIn() async {
    final todayRecord = getTodayRecord();
    if (todayRecord != null) return false;

    final coins = await getCoins();
    final cost = CoinPackages.getCheckInCost();
    return coins >= cost;
  }

  Future<CheckInResult> attemptCheckIn() async {
    final todayRecord = getTodayRecord();
    if (todayRecord != null) {
      return CheckInResult(
        success: false,
        message: 'You have already checked in today!',
        record: todayRecord,
      );
    }

    final coins = await getCoins();
    final cost = CoinPackages.getCheckInCost();

    if (coins < cost) {
      return CheckInResult(
        success: false,
        message: 'Not enough coins! You need $cost coin${cost > 1 ? 's' : ''}.',
        requiredCoins: cost,
      );
    }

    await _coinsManager.subCoins(cost);
    final record = await performCheckIn();
    return CheckInResult(
      success: true,
      message: 'Check-in successful! -$cost coin${cost > 1 ? 's' : ''}',
      record: record,
      coinsUsed: cost,
    );
  }

  Future<List<Achievement>> getAchievements() async {
    return _storage.getAchievements();
  }

  Future<Map<String, int>> getStats() async {
    final records = _storage.getCheckInRecords();
    final totalCheckIns = records.length;
    final streak = getCurrentStreak();

    int earlyCount = 0;
    int onTimeCount = 0;
    int lateCount = 0;

    for (final record in records) {
      switch (record.status) {
        case CheckInStatus.earlyBird:
          earlyCount++;
          break;
        case CheckInStatus.onTime:
          onTimeCount++;
          break;
        case CheckInStatus.lateNightOwl:
          lateCount++;
          break;
      }
    }

    return {
      'total': totalCheckIns,
      'streak': streak,
      'early': earlyCount,
      'onTime': onTimeCount,
      'late': lateCount,
    };
  }
}

class CheckInResult {
  final bool success;
  final String message;
  final CheckInRecord? record;
  final int? coinsUsed;
  final int? requiredCoins;

  CheckInResult({
    required this.success,
    required this.message,
    this.record,
    this.coinsUsed,
    this.requiredCoins,
  });
}
