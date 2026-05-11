import 'package:get/get.dart';

import 'day_journal_logic.dart';

class DayJournalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DayJournalLogic());
  }
}

