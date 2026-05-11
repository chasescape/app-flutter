import 'package:get/get.dart';

class NavLogic extends GetxController {
  final currentIndex = 0.obs;

  void setIndex(int index) {
    currentIndex.value = index;
  }
}
