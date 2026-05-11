import 'package:get/get.dart';

import 'date_logic.dart';

class DateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DateLogic());
  }
}