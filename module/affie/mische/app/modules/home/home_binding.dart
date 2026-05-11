import 'package:get/get.dart';

import '../emotion/emotion_binding.dart';
import '../coins/coins_logic.dart';
import 'home_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    EmotionBinding().dependencies();
    Get.lazyPut(() => CoinsLogic(), fenix: true);
    Get.lazyPut(() => HomeLogic());
  }
}
