import 'package:get/get.dart';

import 'listings_logic.dart';

class ListingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ListingsLogic());
  }
}