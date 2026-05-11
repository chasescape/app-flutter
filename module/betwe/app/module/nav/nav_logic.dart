import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavLogic extends GetxController {
  final RxInt currentIndex = 0.obs;
  final PageController pageController = PageController();

  void onTap(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
