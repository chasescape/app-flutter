import 'package:get/get.dart';

import 'nav_logic.dart';

class NavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NavLogic());
  }
}

