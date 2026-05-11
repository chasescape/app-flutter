import 'package:get/get.dart';

enum NavViewType { home, upload, profile }

class NavLogic extends GetxController {
  final Rx<NavViewType> currentView = NavViewType.home.obs;

  void setView(NavViewType view) {
    if (currentView.value == view) return;
    currentView.value = view;
  }
}

