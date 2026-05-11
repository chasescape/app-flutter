import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shadows.dart';

/// Dialog to show when user has insufficient coins for tool execution
///
/// This dialog:
/// - Shows the required coin amount (NOT user's current balance)
/// - Provides a "Go to Recharge" button
/// - Has a cancel button
///
/// Usage:
/// ```dart
/// InsufficientBalanceDialog.show(
///   requiredCoins: 50,
///   onRecharge: () {
///     Get.toNamed(RouteHelper.toCoinStore());
///   },
/// );
/// ```
class InsufficientBalanceDialog extends StatelessWidget {
  /// The required coins for this operation
  final int requiredCoins;

  /// Optional custom message
  final String? customMessage;

  /// Callback when user clicks "Go to Recharge"
  final VoidCallback? onRecharge;

  /// Callback when user clicks "Cancel"
  final VoidCallback? onCancel;

  const InsufficientBalanceDialog({
    super.key,
    required this.requiredCoins,
    this.customMessage,
    this.onRecharge,
    this.onCancel,
  });

  /// Show the insufficient balance dialog
  ///
  /// [requiredCoins] The coins needed for the operation
  /// [onRecharge] Callback when user clicks "Go to Recharge"
  /// [customMessage] Optional custom message to display
  static Future<void> show({
    required int requiredCoins,
    VoidCallback? onRecharge,
    String? customMessage,
  }) {
    return Get.dialog<bool>(
      InsufficientBalanceDialog(
        requiredCoins: requiredCoins,
        customMessage: customMessage,
        onRecharge: onRecharge,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.allLarge,
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: AppSpacing.paddingXL,
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.allLarge,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Insufficient Coins',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Message
            Text(
              customMessage ??
                  'You need $requiredCoins coins to use this feature.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Cost info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppBorderRadius.allMedium,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Cost: $requiredCoins coins per use',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back(result: false);
                      onCancel?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      side: BorderSide(
                        color: AppColors.textDisabled.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Recharge button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(result: true);
                      onRecharge?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Recharge',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple confirmation dialog for charging coins
///
/// This dialog can be shown before executing a paid tool
/// to confirm the user wants to proceed
class ChargeConfirmDialog extends StatelessWidget {
  /// The coins that will be charged
  final int chargeAmount;

  /// Description of what the user will get
  final String featureDescription;

  /// Callback when user confirms
  final VoidCallback onConfirm;

  /// Callback when user cancels
  final VoidCallback? onCancel;

  const ChargeConfirmDialog({
    super.key,
    required this.chargeAmount,
    required this.featureDescription,
    required this.onConfirm,
    this.onCancel,
  });

  /// Show charge confirmation dialog
  ///
  /// [chargeAmount] The coins to be charged
  /// [featureDescription] What the user will receive
  /// [onConfirm] Callback when confirmed
  static Future<bool> show({
    required int chargeAmount,
    required String featureDescription,
  }) {
    return Get.dialog<bool>(
      ChargeConfirmDialog(
        chargeAmount: chargeAmount,
        featureDescription: featureDescription,
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      ),
      barrierDismissible: true,
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.allLarge,
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payments_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text('Confirm Purchase'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            featureDescription,
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppBorderRadius.allMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cost',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$chargeAmount coins',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
