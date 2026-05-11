import 'package:get/get.dart';

import 'guides_logic.dart';

class GuidesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GuidesLogic());
  }
}