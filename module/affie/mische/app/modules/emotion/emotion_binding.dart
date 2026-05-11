import 'package:get/get.dart';

import 'emotion_logic.dart';

class EmotionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(EmotionLogic(), permanent: true);
  }
}
