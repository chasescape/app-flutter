import 'package:get/get.dart';

enum MainTab {
  home,
  generate,
  profile,
}

class MainTabController extends GetxController {
  final RxInt currentIndex = MainTab.home.index.obs;

  MainTab get currentTab => MainTab.values[currentIndex.value];

  void changeTab(MainTab tab) {
    currentIndex.value = tab.index;
  }

  void changeByIndex(int index) {
    if (index < 0 || index >= MainTab.values.length) {
      return;
    }
    currentIndex.value = index;
  }
}
