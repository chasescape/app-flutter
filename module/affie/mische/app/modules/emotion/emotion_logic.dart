import 'package:get/get.dart';

import '../../data/local/local_storage.dart';
import 'emotion_models.dart';

class EmotionLogic extends GetxController {
  final entries = <EmotionEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final stored = await LocalStorage.loadEmotionEntries();
    if (stored.isNotEmpty) {
      entries.assignAll(stored);
    }
  }

  void addEntry(EmotionEntry entry) {
    entries.insert(0, entry);
    LocalStorage.saveEmotionEntries(entries.toList());
  }

  void deleteEntry(String id) {
    entries.removeWhere((entry) => entry.id == id);
    LocalStorage.saveEmotionEntries(entries.toList());
  }

  Future<void> clearEntries() async {
    entries.clear();
    await LocalStorage.saveEmotionEntries([]);
  }

  List<WeekMoodData> getWeekData() {
    if (entries.isEmpty) return [];

    final today = DateTime.now();
    final List<WeekMoodData> weekData = [];

    for (var i = 6; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      final nextDate = date.add(const Duration(days: 1));

      final dayEntries = entries.where((entry) {
        return entry.timestamp.isAfter(date.subtract(const Duration(milliseconds: 1))) &&
            entry.timestamp.isBefore(nextDate);
      }).toList();

      if (dayEntries.isEmpty) continue;

      final average = dayEntries.map((e) => e.intensity).reduce((a, b) => a + b) / dayEntries.length;
      MoodTrend trend = MoodTrend.stable;
      if (weekData.isNotEmpty) {
        final prevAvg = weekData.last.average;
        if (average > prevAvg + 0.5) {
          trend = MoodTrend.up;
        } else if (average < prevAvg - 0.5) {
          trend = MoodTrend.down;
        }
      }

      weekData.add(
        WeekMoodData(
          label: _weekdayLabel(date),
          average: double.parse(average.toStringAsFixed(1)),
          trend: trend,
          entries: dayEntries.length,
        ),
      );
    }

    return weekData;
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }
}
