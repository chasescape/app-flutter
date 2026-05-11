import 'package:get/get.dart';

import 'tools_logic.dart';

class ToolsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ToolsLogic());
  }
}
