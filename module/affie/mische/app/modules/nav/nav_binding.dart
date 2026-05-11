import 'package:get/get.dart';

import '../emotion/emotion_binding.dart';
import '../home/home_binding.dart';
import '../journal/journal_binding.dart';
import '../profile/profile_binding.dart';
import '../tools/tools_binding.dart';
import '../coins/coins_binding.dart';
import 'nav_logic.dart';

class NavBinding extends Bindings {
  @override
  void dependencies() {
    EmotionBinding().dependencies();
    Get.lazyPut(() => NavLogic());
    HomeBinding().dependencies();
    CoinsBinding().dependencies();
    JournalBinding().dependencies();
    ToolsBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
