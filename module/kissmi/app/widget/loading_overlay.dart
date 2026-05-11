import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../gen_a/A.dart';

class LoadingOverlay {
  LoadingOverlay._();

  static bool _showing = false;

  static void show() {
    if (_showing) return;

    _showing = true;

    Get.dialog(
      const _LoadingDialog(),
      barrierDismissible: false,
      barrierColor: const Color(0x66000000),
    );
  }

  static void hide() {
    if (!_showing) return;

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    _showing = false;
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Lottie.asset(
          A.assets_loading_loading,
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}