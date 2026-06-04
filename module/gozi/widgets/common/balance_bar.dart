import 'package:flutter/material.dart';
import 'package:achievenote/gozi/services/coins_manager.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

/// Balance Bar Widget - Displays coin balance at top of page with real-time updates
class BalanceBar extends StatelessWidget {
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const BalanceBar({
    super.key,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final coinsManager = CoinsManager.instance;

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppTheme.md,
            vertical: AppTheme.sm,
          ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.lg,
        vertical: AppTheme.md,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.softSurfaceGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border:
            Border.all(color: AppTheme.primaryWhite.withValues(alpha: 0.74)),
        boxShadow: AppTheme.buttonShadow,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Row(
          children: [
            // Coin Icon
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryButtonGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monetization_on,
                color: AppTheme.primaryWhite,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.md),

            // Balance with ValueListenableBuilder for real-time updates
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: coinsManager.balanceNotifier,
                builder: (context, balance, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: AppTheme.small.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$balance coins',
                        style: AppTheme.h3.copyWith(
                          color: AppTheme.textInverse,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Arrow Icon
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.accentRed,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
