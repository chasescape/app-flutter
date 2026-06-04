import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'coins_manager.dart';
import '../router/app_router.dart';
import '../widgets/dialogs/insufficient_balance_dialog.dart';

/// Tool Charge Service
/// Unified charging logic for tool-based features
///
/// Core principles:
/// 1. Fixed cost per tool use (constant, not dynamic)
/// 2. Charge only AFTER tool service succeeds
/// 3. Check balance before service call
/// 4. Show cost to user upfront
class ToolChargeService {
  ToolChargeService._internal();

  static final ToolChargeService _instance = ToolChargeService._internal();

  /// Singleton instance
  static ToolChargeService get instance => _instance;

  final CoinsManager _coinsManager = CoinsManager.instance;

  /// Check if user has enough balance for a tool use
  /// Returns true if balance is sufficient
  bool hasEnoughBalance(int cost) {
    return _coinsManager.isEnough(cost);
  }

  /// Get current coin balance
  int get currentBalance => _coinsManager.coins;

  /// Validate balance before tool execution
  ///
  /// Returns true if balance is sufficient and user can proceed
  /// Shows dialog and returns false if balance is insufficient
  ///
  /// [cost]: Required coin amount for this tool use
  /// [context]: BuildContext for navigation
  Future<bool> validateBalanceBeforeUse({
    required int cost,
    required BuildContext context,
  }) async {
    if (hasEnoughBalance(cost)) {
      return true;
    }

    // Balance insufficient - show dialog
    await showInsufficientBalanceDialog(
      context: context,
      requiredCoins: cost,
      currentBalance: currentBalance,
    );

    return false;
  }

  /// Charge coins after successful tool execution
  ///
  /// Only call this AFTER the tool service has succeeded and result is saved
  /// Returns true if charge successful, false if insufficient balance
  ///
  /// [cost]: Coin amount to charge
  bool chargeAfterSuccess(int cost) {
    if (cost <= 0) return true;

    final success = _coinsManager.subCoins(cost);
    if (success) {
      // SmartDialog.showToast('Charged: $cost coins');
    }
    return success;
  }

  /// Execute tool use with automatic charging
  ///
  /// This is a convenience method that combines:
  /// 1. Balance check
  /// 2. Tool execution
  /// 3. Charging after success
  ///
  /// [cost]: Coin cost for this tool use
  /// [context]: BuildContext for dialogs/navigation
  /// [toolExecutor]: Function that executes the tool, returns true on success
  /// [onInsufficientBalance]: Optional callback when balance is insufficient
  /// [onSuccess]: Optional callback after successful charge
  /// [onFailure]: Optional callback when tool execution fails
  Future<bool> executeWithCharge({
    required int cost,
    required BuildContext context,
    required Future<bool> Function() toolExecutor,
    VoidCallback? onInsufficientBalance,
    VoidCallback? onSuccess,
    VoidCallback? onFailure,
  }) async {
    // Step 1: Validate balance
    final hasBalance = await validateBalanceBeforeUse(
      cost: cost,
      context: context,
    );

    if (!hasBalance) {
      onInsufficientBalance?.call();
      return false;
    }

    // Step 2: Execute tool
    SmartDialog.showLoading(msg: 'Processing...');

    try {
      final success = await toolExecutor();
      SmartDialog.dismiss();

      if (!success) {
        onFailure?.call();
        // SmartDialog.showToast('Tool execution failed');
        return false;
      }

      // Step 3: Charge after success
      final charged = chargeAfterSuccess(cost);

      if (!charged) {
        // This should not happen as we checked balance earlier,
        // but handle it gracefully
        // SmartDialog.showToast('Charge failed');
        return false;
      }

      onSuccess?.call();
      return true;
    } catch (e) {
      SmartDialog.dismiss();
      onFailure?.call();
      // SmartDialog.showToast('Error: $e');
      return false;
    }
  }

  /// Show charge confirmation dialog (optional, for expensive tools)
  Future<bool> showChargeConfirmation({
    required BuildContext context,
    required int cost,
    String? toolName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('Confirm Tool Use${toolName != null ? ' - $toolName' : ''}'),
        content: Text('This will cost $cost coins. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

/// Extension for easy access to ToolChargeService
extension ToolChargeServiceExtension on BuildContext {
  ToolChargeService get toolCharge => ToolChargeService.instance;
}
