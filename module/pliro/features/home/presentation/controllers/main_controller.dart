import 'package:get/get.dart';

/// Main controller for bottom navigation
class MainController extends GetxController {
  int currentIndex = 0;

  void changePage(int index) {
    currentIndex = index;
    update();
  }
}
