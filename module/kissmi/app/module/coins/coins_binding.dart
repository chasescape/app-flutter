import 'package:get/get.dart';

import 'coins_logic.dart';

class CoinsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CoinsLogic());
  }
}