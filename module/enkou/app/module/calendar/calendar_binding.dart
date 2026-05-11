import 'package:get/get.dart';

import 'calendar_logic.dart';

class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CalendarLogic());
  }
}