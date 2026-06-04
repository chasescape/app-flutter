import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../managers/coins_manager.dart';
import '../routes/app_routes.dart';

class ToolChargeHandler {
  final BuildContext context;
  final int cost;
  final String toolName;

  const ToolChargeHandler({
    required this.context,
    required this.cost,
    required this.toolName,
  });

  bool checkBalance() {
    return CoinsManager().isEnough(cost);
  }

  Future<bool> ensureBalanceBeforeExecution() async {
    if (checkBalance()) {
      return true;
    }

    final shouldRecharge = await _showInsufficientCoinsDialog();
    if (shouldRecharge == true) {
      if (context.mounted) {
        context.push(AppRoutes.coinStore);
      }
    }
    return false;
  }

  Future<bool> chargeAfterSuccess() async {
    final success = await CoinsManager().subCoins(cost);
    return success;
  }

  Future<bool?> _showInsufficientCoinsDialog() async {
    final currentBalance = CoinsManager().balance;
    final needed = cost - currentBalance;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Insufficient Coins'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost: $cost coins per use',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Current balance: $currentBalance coins',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Required: $cost coins',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Need $needed more coins',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Get Coins'),
          ),
        ],
      ),
    );
  }
}
