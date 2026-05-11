import 'package:get/get.dart';

class NavLogic extends GetxController {
  final RxInt tabIndex = 0.obs;

  void changeTab(int index) {
    tabIndex.value = index;
  }
}
