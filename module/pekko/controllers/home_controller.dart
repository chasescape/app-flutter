import 'package:get/get.dart';
import '../data/models/perfume.dart';
import '../data/models/perfume_record.dart';
import '../data/services/storage_service.dart';
import 'main_controller.dart';

/// Home page controller
class HomeController extends GetxController {
  final StorageService _storage = StorageService.to;
  final MainController _mainController = Get.find<MainController>();
  late final Worker _dataSyncWorker;

  // Observables
  final RxList<PerfumeRecord> recentRecords = <PerfumeRecord>[].obs;
  final RxList<PerfumeRecord> allRecords = <PerfumeRecord>[].obs;
  final RxList<Perfume> ownedPerfumes = <Perfume>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    _dataSyncWorker = ever<int>(
      _mainController.dataVersion,
      (_) => loadDashboardData(),
    );
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      final records = await _storage.getRecords();
      final perfumes = await _storage.getPerfumes();
      allRecords.value = records;
      recentRecords.value = records.take(3).toList();
      ownedPerfumes.value = perfumes;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
    await _mainController.refreshUserData();
  }

  int get ownedBottleCount => ownedPerfumes.length;

  int get entriesThisMonth {
    final now = DateTime.now();
    return allRecords.where((record) {
      return record.createdAt.year == now.year &&
          record.createdAt.month == now.month;
    }).length;
  }

  String get favoriteNoteLabel {
    if (allRecords.isEmpty) return 'None';
    final counts = <PerfumeNote, int>{};
    for (final record in allRecords) {
      counts[record.noteType] = (counts[record.noteType] ?? 0) + 1;
    }
    final favorite = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return favorite.first.key.displayName;
  }

  String get favoriteSceneLabel {
    if (allRecords.isEmpty) return 'None';
    final counts = <UsageScene, int>{};
    for (final record in allRecords) {
      counts[record.scene] = (counts[record.scene] ?? 0) + 1;
    }
    final favorite = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return favorite.first.key.displayName;
  }

  String get latestEntryLabel {
    if (recentRecords.isEmpty) return 'No entries yet';
    final latest = recentRecords.first;
    return '${latest.brand} ${latest.perfumeName}';
  }

  @override
  void onClose() {
    _dataSyncWorker.dispose();
    super.onClose();
  }
}
