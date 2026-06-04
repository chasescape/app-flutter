import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme.dart';
import '../../router/app_router.dart';

/// Show insufficient balance dialog
///
/// Displays when user doesn't have enough coins to use a tool
/// Provides "Get Coins" button to navigate to coin store
Future<void> showInsufficientBalanceDialog({
  required BuildContext context,
  required int requiredCoins,
  required int currentBalance,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => InsufficientBalanceDialog(
      requiredCoins: requiredCoins,
      currentBalance: currentBalance,
    ),
  );
}

/// Insufficient Balance Dialog
///
/// Shows user-friendly message when balance is insufficient
/// with option to navigate to coin store
class InsufficientBalanceDialog extends StatelessWidget {
  final int requiredCoins;
  final int currentBalance;

  const InsufficientBalanceDialog({
    super.key,
    required this.requiredCoins,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.allLG,
      ),
      title: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: const Color(AppColors.warning),
            size: 28,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Insufficient Balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(AppColors.backgroundTertiary),
              borderRadius: AppBorderRadius.allMD,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Required:',
                      style: AppTypography.getBodyTextStyle(
                        const Color(AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      '$requiredCoins coins',
                      style: AppTypography.getBodyTextStyle(
                        const Color(AppColors.error),
                      ).copyWith(
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your balance:',
                      style: AppTypography.getBodyTextStyle(
                        const Color(AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      '$currentBalance coins',
                      style: AppTypography.getBodyTextStyle(
                        const Color(AppColors.textPrimary),
                      ).copyWith(
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                const Divider(),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Need more:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      '${requiredCoins - currentBalance} coins',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(AppColors.error),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Purchase coins to continue using this feature.',
            style: AppTypography.getSmallTextStyle(
              const Color(AppColors.textSecondary),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            // Navigate in next frame after dialog is closed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.push(AppRoutes.coinStore);
              }
            });
          },
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Get Coins'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.primaryMain),
            foregroundColor: const Color(AppColors.textInverse),
          ),
        ),
      ],
    );
  }
}
