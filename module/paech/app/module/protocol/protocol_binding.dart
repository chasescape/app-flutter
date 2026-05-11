import 'package:get/get.dart';

import 'protocol_logic.dart';

class ProtocolBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProtocolLogic());
  }
}