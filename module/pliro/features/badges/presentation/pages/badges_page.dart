import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/features/badges/presentation/controllers/badges_controller.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';
import 'package:pliro/pliro/shared/widgets/loading_state.dart';

/// Badges page - shows earned badges and progress.
class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BadgesController());

    return DreamScaffold(
      appBar: AppBar(title: const Text('Badges')),
      body: GetBuilder<BadgesController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return const LoadingIndicator(message: 'Polishing badges...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMD,
              AppTheme.spacingSM,
              AppTheme.spacingMD,
              AppTheme.spacingXXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsSummary(ctrl),
                const SizedBox(height: AppTheme.spacingXL),
                _buildBadgesSection(ctrl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSummary(BadgesController ctrl) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.workspace_premium_outlined,
              label: 'Badges',
              value: '${ctrl.earnedBadgeCount}',
              color: AppColors.rose,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_outline,
              label: 'Works',
              value: '${ctrl.completedCount}',
              color: AppColors.mint,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.collections_bookmark_outlined,
              label: 'Saved',
              value: '${ctrl.savedRecordCount}',
              color: AppColors.lilac,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(icon, color: AppColors.roseDeep, size: 23),
        ),
        const SizedBox(height: AppTheme.spacingSM),
        Text(value, style: AppTextStyles.h3),
        Text(
          label,
          style: AppTextStyles.small,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBadgesSection(BadgesController ctrl) {
    final badges = ctrl.allBadges;
    final earned = badges.where((badge) => badge.isEarned).toList();
    final locked = badges.where((badge) => !badge.isEarned).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All badges', style: AppTextStyles.h3),
        const SizedBox(height: AppTheme.spacingMD),
        if (earned.isNotEmpty) ...[
          Text('Earned', style: AppTextStyles.captionMedium),
          const SizedBox(height: AppTheme.spacingSM),
          ...earned.map(_buildBadgeCard),
          const SizedBox(height: AppTheme.spacingLG),
        ],
        if (locked.isNotEmpty) ...[
          Text('Locked', style: AppTextStyles.captionMedium),
          const SizedBox(height: AppTheme.spacingSM),
          ...locked.map(_buildBadgeCard),
        ],
      ],
    );
  }

  Widget _buildBadgeCard(BadgeModel badge) {
    final iconColor =
        badge.isEarned ? AppColors.textInverse : AppColors.roseDeep;
    final iconBackground = badge.isEarned
        ? AppColors.primaryGradient
        : LinearGradient(
            colors: [
              AppColors.surfaceMint.withOpacity(0.90),
              AppColors.blushMist.withOpacity(0.70),
            ],
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      child: NeonCard(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: iconBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Icon(badge.icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.name,
                    style: AppTextStyles.bodySemiBold.copyWith(
                      color: badge.isEarned
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    badge.description,
                    style: AppTextStyles.caption,
                  ),
                  if (!badge.isEarned && badge.progress != null) ...[
                    const SizedBox(height: AppTheme.spacingSM),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      child: LinearProgressIndicator(
                        value: badge.progress! / badge.maxProgress,
                        minHeight: 7,
                        backgroundColor: AppColors.blushMist.withOpacity(0.72),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.roseDeep,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      '${badge.progress}/${badge.maxProgress}',
                      style: AppTextStyles.small,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Icon(
              badge.isEarned ? Icons.check_circle : Icons.lock_outline,
              color: badge.isEarned
                  ? AppColors.successGreen
                  : AppColors.textDisabled,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge model.
class BadgeModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isEarned;
  final int? progress;
  final int maxProgress;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isEarned,
    this.progress,
    this.maxProgress = 1,
  });
}
