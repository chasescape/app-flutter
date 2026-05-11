import 'package:flira/flira/app/modules/nav/flira_state.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController {
  List<DiaryEntry> get entries => FliraState.entries;

  DiaryEntry? get todayEntry => entries.isEmpty ? null : entries.first;

  List<DiaryEntry> get recentPhotos => entries.take(5).toList();

  List<DiaryEntry> get diaryFeed => entries.length <= 1 ? <DiaryEntry>[] : entries.sublist(1);
}
