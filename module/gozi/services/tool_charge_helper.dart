import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'coins_manager.dart';
import 'package:achievenote/gozi/routes/global_router.dart';

/// Tool Charge Helper - Utility class for tool service charging logic
///
/// This class enforces the correct charging pattern for tool-based services:
/// 1. Check balance before execution (no deduction)
/// 2. Only charge AFTER successful completion
/// 3. Show clear cost information to users
/// 4. Provide recharge option when insufficient
class ToolChargeHelper {
  ToolChargeHelper._();

  /// Check if user has enough balance for a tool execution
  ///
  /// Returns true if balance is sufficient, false otherwise.
  /// If insufficient, shows a dialog prompting user to recharge.
  ///
  /// Usage:
  /// ```dart
  /// if (!ToolChargeHelper.checkBalance(context, cost: 30)) return;
  /// // Proceed with tool execution
  /// ```
  static bool checkBalance(BuildContext context, {required int cost}) {
    final coinsManager = CoinsManager.instance;

    if (coinsManager.isEnough(cost)) {
      return true;
    }

    // Show insufficient balance dialog
    _showInsufficientDialog(context, cost: cost);
    return false;
  }

  /// Charge user after successful tool execution
  ///
  /// Only call this AFTER:
  /// 1. Tool service returns success
  /// 2. Result is validated and usable
  /// 3. Result is saved/entered into history chain
  ///
  /// Returns true if charge succeeded, false otherwise.
  ///
  /// Usage:
  /// ```dart
  /// final result = await toolService.execute();
  /// if (result.isSuccess) {
  ///   final charged = ToolChargeHelper.charge(context, cost: 30);
  ///   if (!charged) {
  ///     // Handle charge failure (should not happen if balance was checked)
  ///   }
  /// }
  /// ```
  static Future<bool> charge(BuildContext context, {required int cost}) async {
    final coinsManager = CoinsManager.instance;

    // Double-check balance (should not fail if checkBalance was called)
    if (!coinsManager.isEnough(cost)) {
      // This should not happen if checkBalance was used properly
      _showInsufficientDialog(context, cost: cost);
      return false;
    }

    // Deduct coins
    final success = await coinsManager.subCoins(cost);

    if (success && context.mounted) {
      // Show success message
      Get.snackbar(
        'Success',
        'Cost: $cost coins',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF009246),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    }

    return success;
  }

  /// Show insufficient balance dialog with recharge option
  static void _showInsufficientDialog(BuildContext context,
      {required int cost}) {
    Get.dialog(
      AlertDialog(
        title: const Text('Insufficient Balance'),
        content: Text('You need $cost coins to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              GlobalRouter.I.goToStore();
            },
            child: const Text('Get Coins'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Build cost display widget for tool UI
  ///
  /// Shows friendly cost information like "Cost: 30 coins per use"
  static Widget buildCostDisplay({required int cost}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF009246).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF009246).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            size: 16,
            color: Color(0xFF009246),
          ),
          const SizedBox(width: 6),
          Text(
            'Cost: $cost coins',
            style: const TextStyle(
              color: Color(0xFF009246),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
