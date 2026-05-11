import 'package:get/get.dart';
import '../models/user_settings.dart';
import '../services/storage_service.dart';
import '../interface.dart';

class SettingsController extends GetxController {
  final StorageService _storage = StorageService.to;

  final Rx<UserSettings> settings = UserSettings().obs;
  final RxInt coins = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    settings.value = _storage.getSettings();
    coins.value = _storage.getCoins();
  }

  Future<void> updateDailyGoal(int goal) async {
    final newSettings = settings.value.copyWith(dailyGoal: goal);
    await _storage.saveSettings(newSettings);
    settings.value = newSettings;
  }

  Future<void> updateUnit(String unit) async {
    final newSettings = settings.value.copyWith(unit: unit);
    await _storage.saveSettings(newSettings);
    settings.value = newSettings;
  }

  Future<void> updateReminder(bool enabled) async {
    final newSettings = settings.value.copyWith(reminderEnabled: enabled);
    await _storage.saveSettings(newSettings);
    settings.value = newSettings;
  }

  Future<void> updateReminderInterval(int interval) async {
    final newSettings = settings.value.copyWith(reminderInterval: interval);
    await _storage.saveSettings(newSettings);
    settings.value = newSettings;
  }

  Future<void> updateSleepTime(String start, String end) async {
    final newSettings = settings.value.copyWith(
      sleepStartTime: start,
      sleepEndTime: end,
    );
    await _storage.saveSettings(newSettings);
    settings.value = newSettings;
  }

  Future<void> clearAllData() async {
    await _storage.clearAllData();
    Interface().authToken = null;
    Get.offAllNamed('/login');
  }
}
