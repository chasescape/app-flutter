import 'dart:convert';
import '../core/storage/local_storage.dart';
import '../models/perfume_record.dart';

class RecordService {
  static final RecordService _instance = RecordService._internal();
  factory RecordService() => _instance;
  RecordService._internal();

  final LocalStorage _storage = LocalStorage.instance;

  List<PerfumeRecord> getAllRecords() {
    return _storage.recordJsonList
        .map((json) =>
            PerfumeRecord.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  void saveRecord(PerfumeRecord record) {
    _storage.saveRecord(record.toJson());
  }

  void deleteRecord(String id) {
    _storage.deleteRecord(id);
  }

  void clearAllRecords() {
    _storage.recordJsonList = [];
  }

  void updateRecord(PerfumeRecord record) {
    deleteRecord(record.id);
    _storage.saveRecord(record.toJson());
  }

  List<PerfumeRecord> filterRecords({String? scentFamily, String? occasion}) {
    var records = getAllRecords();
    if (scentFamily != null && scentFamily.isNotEmpty) {
      records = records.where((r) => r.scentFamily == scentFamily).toList();
    }
    if (occasion != null && occasion.isNotEmpty) {
      records = records.where((r) => r.occasion == occasion).toList();
    }
    return records;
  }

  int getWeeklyCount() {
    final now = DateTime.now();
    return getAllRecords()
        .where((r) => now.difference(r.createdAt).inDays <= 7)
        .length;
  }

  String? getMostUsedScent() {
    final records = getAllRecords();
    if (records.isEmpty) return null;
    final counts = <String, int>{};
    for (final r in records) {
      counts[r.scentFamily] = (counts[r.scentFamily] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}
