import 'package:get/get.dart';
import 'flira_state.dart';

class NavLogic extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化FliraState，加载持久化数据
    FliraState.init();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
