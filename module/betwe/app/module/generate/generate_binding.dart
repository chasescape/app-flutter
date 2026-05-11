import 'package:get/get.dart';

import 'generate_logic.dart';

class GenerateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GenerateLogic());
  }
}
