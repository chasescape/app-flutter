import 'package:get/get.dart';

import '../../data/daily_tip_store.dart';
import '../../data/mood_store.dart';

class DateLogic extends GetxController {
  Map<String, String> tipMap = <String, String>{};
  Map<String, String> moodMap = <String, String>{};

  @override
  void onInit() {
    _loadTips();
    _loadMoods();
    super.onInit();
  }

  Future<void> _loadTips() async {
    await DailyTipStore.loadAll();
    tipMap = DailyTipStore.cacheSnapshot;
    update();
  }

  Future<void> _loadMoods() async {
    await MoodStore.loadAll();
    moodMap = MoodStore.cacheSnapshot;
    update();
  }

  String? tipForDate(DateTime date) {
    return tipMap[DailyTipStore.keyForDate(date)];
  }

  String? moodForDate(DateTime date) {
    return moodMap[MoodStore.keyForDate(date)];
  }

  void refreshTip(DateTime date, String tip) {
    tipMap[DailyTipStore.keyForDate(date)] = tip;
    update();
  }

  void refreshMood(DateTime date, String emoji) {
    moodMap[MoodStore.keyForDate(date)] = emoji;
    update();
  }
}
