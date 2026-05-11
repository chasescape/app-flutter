import 'package:get/get.dart';
import '../models/drink_record.dart';
import '../models/user_settings.dart';
import '../services/coins_manager.dart';
import '../services/storage_service.dart';

class MainController extends GetxController {
  final StorageService _storage = StorageService.to;
  final CoinsManager _coinsManager = CoinsManager.instance;

  final RxList<DrinkRecord> records = <DrinkRecord>[].obs;
  final Rx<UserSettings> settings = UserSettings().obs;
  final RxInt todayAmount = 0.obs;
  final RxInt todayCount = 0.obs;
  final RxInt coins = 0.obs;
  final RxInt freeResults = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    records.value = _storage.getRecords();
    settings.value = _storage.getSettings();
    _updateTodayData();
    coins.value = _storage.getCoins();
    freeResults.value = _storage.getFreeResults();
  }

  void _updateTodayData() {
    todayAmount.value = _storage.getTodayAmount();
    todayCount.value = _storage.getTodayCount();
  }

  Future<void> addDrink(int amount, {String? note}) async {
    final bool deducted = await _coinsManager.subCoins(1);
    if (!deducted) {
      Get.snackbar(
        'Not enough coins',
        'You need 1 coin to record a drink.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final record = DrinkRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      amount: amount,
      note: note,
    );

    await _storage.addRecord(record);
    records.value = _storage.getRecords();
    _updateTodayData();
    coins.value = _storage.getCoins();
  }

  Future<void> deleteRecord(String id) async {
    await _storage.deleteRecord(id);
    records.value = _storage.getRecords();
    _updateTodayData();
  }

  Future<void> clearRecords() async {
    await _storage.clearRecords();
    records.clear();
    _updateTodayData();
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    await _storage.saveSettings(newSettings);
    settings.value = newSettings;
  }

  int getProgress() {
    final goal = settings.value.dailyGoal;
    if (goal == 0) return 0;
    return ((todayAmount.value / goal) * 100).clamp(0, 100).toInt();
  }

  String getProgressText() {
    return '${todayAmount.value} / ${settings.value.dailyGoal} ${settings.value.unit}';
  }

  Map<String, int> getWeekData() {
    return _storage.getWeekData();
  }

  int getStreak() {
    return _storage.getStreak();
  }
}
