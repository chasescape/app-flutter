import 'package:get/get.dart';

import 'deposit_logic.dart';

class DepositBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DepositLogic());
  }
}
