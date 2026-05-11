import 'package:flira/flira/app/modules/nav/flira_state.dart';
import 'package:get/get.dart';

class HistoryLogic extends GetxController {
  List<DiaryEntry> get entries => FliraState.entries;
}
