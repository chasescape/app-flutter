import 'package:get/get.dart';
import '../data/models/perfume.dart';
import '../data/models/perfume_record.dart';
import '../data/services/storage_service.dart';
import 'main_controller.dart';

class PerfumeUsageStat {
  final String key;
  final String name;
  final String brand;
  final String? imageUrl;
  final PerfumeNote noteType;
  final int wearCount;
  final double wearShare;
  final double averageMood;
  final double averageLongevity;
  final int compliments;
  final DateTime? lastWornAt;
  final bool inCollection;

  const PerfumeUsageStat({
    required this.key,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.noteType,
    required this.wearCount,
    required this.wearShare,
    required this.averageMood,
    required this.averageLongevity,
    required this.compliments,
    required this.lastWornAt,
    required this.inCollection,
  });

  String get fullName => '$brand $name';
}

/// Insights controller for local fragrance patterns and recap summaries.
class AnalysisController extends GetxController {
  final StorageService _storage = StorageService.to;
  final MainController _mainController = Get.find<MainController>();

  final RxList<PerfumeRecord> allRecords = <PerfumeRecord>[].obs;
  final RxList<Perfume> allPerfumes = <Perfume>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<PerfumeNote> filterNote = Rxn<PerfumeNote>();
  final Rxn<UsageScene> filterScene = Rxn<UsageScene>();

  late final Worker _dataSyncWorker;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _dataSyncWorker = ever<int>(
      _mainController.dataVersion,
      (_) => loadData(),
    );
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final records = await _storage.getRecords();
      final perfumes = await _storage.getPerfumes();
      allRecords.value = records;
      allPerfumes.value = perfumes;
    } finally {
      isLoading.value = false;
    }
  }

  List<PerfumeRecord> get filteredRecords {
    var records = List<PerfumeRecord>.from(allRecords);

    if (filterNote.value != null) {
      records =
          records.where((item) => item.noteType == filterNote.value).toList();
    }

    if (filterScene.value != null) {
      records =
          records.where((item) => item.scene == filterScene.value).toList();
    }

    return records;
  }

  void setNoteFilter(PerfumeNote? note) {
    filterNote.value = note;
  }

  void setSceneFilter(UsageScene? scene) {
    filterScene.value = scene;
  }

  void clearFilters() {
    filterNote.value = null;
    filterScene.value = null;
  }

  int get totalEntries => filteredRecords.length;

  int get collectionSize => allPerfumes.length;

  int get trackedPerfumeCount => perfumeUsageStats.length;

  int get entriesThisMonth {
    final now = DateTime.now();
    return filteredRecords.where((record) {
      return record.createdAt.year == now.year &&
          record.createdAt.month == now.month;
    }).length;
  }

  double get averageMood {
    if (filteredRecords.isEmpty) return 0;
    final total =
        filteredRecords.fold<int>(0, (sum, item) => sum + item.moodRating);
    return total / filteredRecords.length;
  }

  double get averageLongevity {
    if (filteredRecords.isEmpty) return 0;
    final total =
        filteredRecords.fold<int>(0, (sum, item) => sum + item.longevity);
    return total / filteredRecords.length;
  }

  int get totalCompliments {
    return filteredRecords.fold<int>(
        0, (sum, item) => sum + (item.compliments ?? 0));
  }

  String get favoriteNoteLabel => _topLabel<PerfumeNote>(
        items: filteredRecords,
        selector: (record) => record.noteType,
        label: (note) => note.displayName,
        fallback: 'None',
      );

  String get goToSceneLabel => _topLabel<UsageScene>(
        items: filteredRecords,
        selector: (record) => record.scene,
        label: (scene) => scene.displayName,
        fallback: 'None',
      );

  String get mostWornPerfumeLabel {
    final stat = mostWornStat;
    if (stat == null) return 'No data yet';
    return stat.fullName;
  }

  PerfumeRecord? get mostWornRecord {
    final targetKey = mostWornStat?.key;
    if (targetKey == null) return null;
    return filteredRecords.firstWhereOrNull(
      (record) => _perfumeKey(record.brand, record.perfumeName) == targetKey,
    );
  }

  PerfumeUsageStat? get mostWornStat {
    return perfumeUsageStats.firstWhereOrNull((item) => item.wearCount > 0);
  }

  double get mostWornShare => mostWornStat?.wearShare ?? 0;

  List<PerfumeUsageStat> get perfumeUsageStats {
    final stats = <String, PerfumeUsageStat>{};
    final totalLoggedWears = filteredRecords.length;

    for (final perfume in allPerfumes) {
      final key = _perfumeKey(perfume.brand, perfume.name);
      stats[key] = PerfumeUsageStat(
        key: key,
        name: perfume.name,
        brand: perfume.brand,
        imageUrl: perfume.imageUrl,
        noteType: perfume.primaryNote,
        wearCount: 0,
        wearShare: 0,
        averageMood: 0,
        averageLongevity: 0,
        compliments: 0,
        lastWornAt: null,
        inCollection: true,
      );
    }

    final groupedRecords = <String, List<PerfumeRecord>>{};
    for (final record in filteredRecords) {
      final key = _perfumeKey(record.brand, record.perfumeName);
      groupedRecords.putIfAbsent(key, () => <PerfumeRecord>[]).add(record);
    }

    for (final entry in groupedRecords.entries) {
      final records = List<PerfumeRecord>.from(entry.value)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final existing = stats[entry.key];
      final latest = records.first;
      final wearCount = records.length;
      final moodTotal =
          records.fold<int>(0, (sum, item) => sum + item.moodRating);
      final longevityTotal =
          records.fold<int>(0, (sum, item) => sum + item.longevity);
      final compliments =
          records.fold<int>(0, (sum, item) => sum + (item.compliments ?? 0));
      final dominantNote = _topValue<PerfumeNote>(
            items: records,
            selector: (record) => record.noteType,
          ) ??
          existing?.noteType ??
          latest.noteType;

      stats[entry.key] = PerfumeUsageStat(
        key: entry.key,
        name: existing?.name ?? latest.perfumeName,
        brand: existing?.brand ?? latest.brand,
        imageUrl: existing?.imageUrl ?? latest.imageUrl,
        noteType: dominantNote,
        wearCount: wearCount,
        wearShare: totalLoggedWears == 0 ? 0 : wearCount / totalLoggedWears,
        averageMood: moodTotal / wearCount,
        averageLongevity: longevityTotal / wearCount,
        compliments: compliments,
        lastWornAt: latest.createdAt,
        inCollection: existing?.inCollection ?? false,
      );
    }

    final sorted = stats.values.toList()
      ..sort((a, b) {
        final wearCompare = b.wearCount.compareTo(a.wearCount);
        if (wearCompare != 0) return wearCompare;
        final lastWornCompare = (b.lastWornAt?.millisecondsSinceEpoch ?? 0)
            .compareTo(a.lastWornAt?.millisecondsSinceEpoch ?? 0);
        if (lastWornCompare != 0) return lastWornCompare;
        final collectionCompare =
            (b.inCollection ? 1 : 0).compareTo(a.inCollection ? 1 : 0);
        if (collectionCompare != 0) return collectionCompare;
        return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
      });
    return sorted;
  }

  List<PerfumeUsageStat> get collectionBottleStats {
    if (allPerfumes.isNotEmpty) {
      return perfumeUsageStats.where((item) => item.inCollection).toList();
    }
    return perfumeUsageStats;
  }

  List<PerfumeUsageStat> get chartPerfumeStats {
    return perfumeUsageStats
        .where((item) => item.wearCount > 0)
        .take(5)
        .toList();
  }

  int get activeCollectionCount {
    return collectionBottleStats.where((item) => item.wearCount > 0).length;
  }

  int get idleCollectionCount {
    return collectionBottleStats.where((item) => item.wearCount == 0).length;
  }

  PerfumeRecord? get latestRecord {
    if (filteredRecords.isEmpty) return null;
    final records = List<PerfumeRecord>.from(filteredRecords)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records.first;
  }

  List<PerfumeRecord> get highlightRecords {
    final records = List<PerfumeRecord>.from(filteredRecords);
    records.sort((a, b) {
      final complimentCompare =
          (b.compliments ?? 0).compareTo(a.compliments ?? 0);
      if (complimentCompare != 0) return complimentCompare;
      return b.moodRating.compareTo(a.moodRating);
    });
    return records.take(3).toList();
  }

  Map<String, int> get noteDistribution {
    final distribution = <PerfumeNote, int>{};
    for (final record in filteredRecords) {
      distribution[record.noteType] = (distribution[record.noteType] ?? 0) + 1;
    }
    return distribution.map((key, value) => MapEntry(key.displayName, value));
  }

  Map<String, int> get sceneDistribution {
    final distribution = <UsageScene, int>{};
    for (final record in filteredRecords) {
      distribution[record.scene] = (distribution[record.scene] ?? 0) + 1;
    }
    return distribution.map((key, value) => MapEntry(key.displayName, value));
  }

  String get recapTitle {
    if (collectionSize == 0 && filteredRecords.isEmpty) {
      return 'Your perfume dashboard is ready for its first bottle.';
    }
    if (filteredRecords.isEmpty) {
      return 'Your collection is saved and waiting for wear history.';
    }
    if (averageMood >= 4.3) {
      return 'Your rotation looks polished, confident, and repeat-worthy.';
    }
    if (averageMood >= 3.5) {
      return 'Your scent habits feel balanced with a clear rotation pattern.';
    }
    return 'Your recent entries lean exploratory and mood-driven.';
  }

  String get recapBody {
    if (collectionSize == 0 && filteredRecords.isEmpty) {
      return 'Add a bottle or log a wear, and this page will turn into a private scent dashboard with usage charts, favorites, and seasonal patterns.';
    }

    if (filteredRecords.isEmpty) {
      return 'You currently have $collectionSize bottles in your collection. Log a few wears and this page will highlight your go-to perfume, usage share, and note preferences.';
    }

    final topPerfume = mostWornStat;
    final note = favoriteNoteLabel.toLowerCase();
    final scene = goToSceneLabel.toLowerCase();
    final perfume = topPerfume?.fullName ?? mostWornPerfumeLabel;
    final longevityText = averageLongevity.toStringAsFixed(1);
    final topShare = '${(mostWornShare * 100).round()}%';
    final trackedCount =
        collectionSize == 0 ? trackedPerfumeCount : collectionSize;
    return 'You are tracking $trackedCount perfumes and have logged $totalEntries wears. '
        '$perfume leads your rotation at $topShare of entries, while $note scents show up most often in $scene settings with an average wear length of $longevityText hours.';
  }

  String get dashboardSummary {
    if (collectionSize == 0 && filteredRecords.isEmpty) {
      return 'Track your bottles, compare usage, and see which scent leads your rotation.';
    }
    if (filteredRecords.isEmpty) {
      return 'You have $collectionSize bottles saved. Start logging wears to unlock your usage charts.';
    }

    final topPerfume = mostWornStat;
    if (topPerfume == null) {
      return 'Your diary is filling up with fragrance habits and favorite notes.';
    }

    final share = (mostWornShare * 100).round();
    return '${topPerfume.fullName} is your current leader with $share% of logged wears.';
  }

  String _topLabel<T>({
    required List<PerfumeRecord> items,
    required T Function(PerfumeRecord record) selector,
    required String Function(T value) label,
    required String fallback,
  }) {
    if (items.isEmpty) return fallback;
    final counts = <T, int>{};
    for (final item in items) {
      final key = selector(item);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return label(sorted.first.key);
  }

  T? _topValue<T>({
    required List<PerfumeRecord> items,
    required T Function(PerfumeRecord record) selector,
  }) {
    if (items.isEmpty) return null;
    final counts = <T, int>{};
    for (final item in items) {
      final key = selector(item);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  String _perfumeKey(String brand, String perfumeName) {
    return '${brand.trim().toLowerCase()}|${perfumeName.trim().toLowerCase()}';
  }

  @override
  void onClose() {
    _dataSyncWorker.dispose();
    super.onClose();
  }
}
