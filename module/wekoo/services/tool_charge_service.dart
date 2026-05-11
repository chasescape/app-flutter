import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'coins_manager.dart';
import '../routes/app_routes.dart';

class ToolChargeService {
  ToolChargeService._();

  static ToolChargeService? _instance;

  static ToolChargeService get instance {
    _instance ??= ToolChargeService._();
    return _instance!;
  }

  final CoinsManager _coinsManager = CoinsManager.instance;

  static const int defaultToolCost = 40;

  bool hasEnoughCoins({int cost = defaultToolCost}) {
    return _coinsManager.isEnough(cost);
  }

  Future<bool> chargeForTool({
    int cost = defaultToolCost,
    VoidCallback? onInsufficientCoins,
  }) async {
    final success = await _coinsManager.subCoins(cost);
    if (!success && onInsufficientCoins != null) {
      onInsufficientCoins();
    }
    return success;
  }

  void showInsufficientCoinsDialog({
    int requiredCoins = defaultToolCost,
    String? customMessage,
  }) {
    Get.defaultDialog(
      title: 'Insufficient Coins',
      middleText: customMessage ?? 'You need $requiredCoins coins to use this feature.',
      textConfirm: 'Get Coins',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        Get.back();
        AppRoutes.toCoinShop();
      },
    );
  }

  String getCostText({int cost = defaultToolCost}) {
    return 'Cost: $cost coins per use';
  }
}
