import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';

/// Cost Badge - Display tool cost to users
///
/// Shows "Cost: XX coins per use" near tool execution buttons
/// Follows UX principle: inform user of cost before action
class CostBadge extends StatelessWidget {
  /// Cost in coins
  final int cost;

  /// Optional custom label
  /// If null, uses default "Cost: {cost} coins per use"
  final String? label;

  /// Badge style variant
  final CostBadgeStyle style;

  const CostBadge({
    super.key,
    required this.cost,
    this.label,
    this.style = CostBadgeStyle.standard,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? 'Cost: $cost coins per use';

    switch (style) {
      case CostBadgeStyle.standard:
        return _buildStandardBadge(displayLabel);
      case CostBadgeStyle.compact:
        return _buildCompactBadge(displayLabel);
      case CostBadgeStyle.outlined:
        return _buildOutlinedBadge(displayLabel);
      case CostBadgeStyle.minimal:
        return _buildMinimalBadge();
    }
  }

  /// Standard badge with icon
  Widget _buildStandardBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color(AppColors.backgroundTertiary),
        borderRadius: AppBorderRadius.allSM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            size: 16,
            color: Color(AppColors.accentMain),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.getSmallTextStyle(
              const Color(AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// Compact badge without icon
  Widget _buildCompactBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color(AppColors.backgroundTertiary),
        borderRadius: AppBorderRadius.allSM,
      ),
      child: Text(
        label,
        style: AppTypography.getSmallTextStyle(
          const Color(AppColors.textSecondary),
        ),
      ),
    );
  }

  /// Outlined badge with border
  Widget _buildOutlinedBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(AppColors.accentMain),
          width: 1,
        ),
        borderRadius: AppBorderRadius.allSM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline,
            size: 14,
            color: Color(AppColors.accentMain),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.getSmallTextStyle(
              const Color(AppColors.accentMain),
            ),
          ),
        ],
      ),
    );
  }

  /// Minimal badge showing just icon and number
  Widget _buildMinimalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color(AppColors.accentMain).withOpacity(0.1),
        borderRadius: AppBorderRadius.allSM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            size: 14,
            color: Color(AppColors.accentMain),
          ),
          const SizedBox(width: 4),
          Text(
            '$cost',
            style: AppTypography.getSmallTextStyle(
              const Color(AppColors.accentMain),
            ).copyWith(
              fontWeight: AppTypography.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cost badge style variants
enum CostBadgeStyle {
  /// Standard with icon and full label
  standard,

  /// Compact without icon
  compact,

  /// Outlined with border
  outlined,

  /// Minimal showing just icon and number
  minimal,
}

/// Cost text widget for inline display
class CostText extends StatelessWidget {
  final int cost;
  final String? prefix;
  final String? suffix;

  const CostText({
    super.key,
    required this.cost,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          if (prefix != null)
            TextSpan(
              text: prefix,
              style: AppTypography.getSmallTextStyle(
                const Color(AppColors.textSecondary),
              ),
            ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.monetization_on,
              size: 14,
              color: const Color(AppColors.accentMain),
            ),
          ),
          TextSpan(
            text: ' $cost',
            style: AppTypography.getBodyTextStyle(
              const Color(AppColors.accentMain),
            ).copyWith(
              fontWeight: AppTypography.bold,
            ),
          ),
          if (suffix != null)
            TextSpan(
              text: suffix,
              style: AppTypography.getSmallTextStyle(
                const Color(AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

/// Cost label for button subtitles
class CostButtonLabel extends StatelessWidget {
  final int cost;

  const CostButtonLabel({
    super.key,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.monetization_on,
          size: 12,
          color: Color(AppColors.accentMain),
        ),
        const SizedBox(width: 4),
        Text(
          '$cost coins',
          style: AppTypography.getSmallTextStyle(
            const Color(AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
