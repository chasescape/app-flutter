import 'package:get/get.dart';
import 'package:pliro/pliro/core/routes/app_routes.dart';
import 'package:pliro/pliro/core/managers/coins_manager.dart';
import 'package:pliro/pliro/core/storage/storage_service.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';

/// Home page controller
class HomeController extends GetxController {
  final StorageService _storage = StorageService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;

  bool isLoading = true;
  int coinBalance = 0;
  int completedCount = 0;
  int totalRecords = 0;
  List<BeadRecord> recentRecords = [];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    update();

    // Load coins from CoinsManager
    coinBalance = _coinsManager.currentCoins;

    // Load records
    final records = await _storage.getRecords();
    totalRecords = records.length;
    completedCount = records.where((r) => r.isFinished).length;
    recentRecords = records.take(5).toList();

    isLoading = false;
    update(['content']);
  }

  Future<void> onCreateRecord() async {
    final saved = await Get.toNamed(AppRoutes.recordEditor);
    if (saved == true) {
      await loadData();
    }
  }
}
