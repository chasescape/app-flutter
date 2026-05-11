import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/widgets/glass_card.dart';
import '../../app/widgets/bounce_in_animation.dart';
import '../../app/router/app_router.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/snap_analysis.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: BounceInAnimation(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Discover',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        height: 1.15,
                      ),
                ),
              ),
            ),
          ),

          // Photo analysis cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = allSnapData[index];
                  return BounceInAnimation(
                    delay: Duration(milliseconds: 100 + index * 60),
                    child: _SnapCard(
                      item: item,
                      onTap: () => AppRouter.toDetail(context, data: item),
                    ),
                  );
                },
                childCount: allSnapData.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _SnapCard extends StatelessWidget {
  final SnapAnalysis item;
  final VoidCallback onTap;

  const _SnapCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        borderRadius: AppSpacing.borderRadiusXl,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              child: Image.asset(
                item.assetImg,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Scene tags row
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildChip(item.sceneCard.scene.value),
                _buildChip(item.sceneCard.lighting.value),
                _buildChip(item.sceneCard.colorTone.value),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Summary
            Text(
              item.diagnosis.oneLineSummary,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: item.tags.take(3).map((tag) => Text(
                tag,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondaryMain.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accentMain,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
