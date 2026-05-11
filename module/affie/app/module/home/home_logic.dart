import 'dart:async';

import 'package:get/get.dart';

class HomeLogic extends GetxController {
  static bool _hasShownInitialSkeleton = false;

  final showInitialSkeleton = false.obs;
  Timer? _skeletonTimer;

  @override
  void onInit() {
    super.onInit();
    if (_hasShownInitialSkeleton) return;

    showInitialSkeleton.value = true;
    _skeletonTimer = Timer(const Duration(milliseconds: 1000), () {
      showInitialSkeleton.value = false;
      _hasShownInitialSkeleton = true;
    });
  }

  @override
  void onClose() {
    _skeletonTimer?.cancel();
    super.onClose();
  }
}
