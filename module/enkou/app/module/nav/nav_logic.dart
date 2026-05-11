import 'package:get/get.dart';

class NavLogic extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }
}
