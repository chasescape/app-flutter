import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Custom perfume icon (since Icons.perfume_outlined may not exist)
class PerfumeIcon extends IconData {
  const PerfumeIcon() : super(0xe1a5, fontFamily: 'MaterialIcons');
}

/// Export common icons
class AppIcons {
  AppIcons._();

  static const IconData perfume = Icons.local_florist;
  static const IconData perfumeOut = Icons.local_florist_outlined;
}

/// Global loading dialog utility
class AppLoading {
  AppLoading._();

  static bool _isShowing = false;

  /// Show loading dialog
  static void show() {
    if (!_isShowing) {
      _isShowing = true;
      Get.dialog(
        const Center(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  /// Hide loading dialog
  static void hide() {
    if (_isShowing) {
      _isShowing = false;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }
}
