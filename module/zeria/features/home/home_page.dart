import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_routes.dart';
import 'package:zeria/zeria/constants/app_strings.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/data/mock/spark_mock_data.dart';
import 'package:zeria/zeria/data/models/spark_result.dart';
import 'package:zeria/zeria/services/coins_manager.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = allSparkMockData.first;
    final galleryItems = allSparkMockData.skip(1).toList();

    return ZeriaScreen(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _buildHeader(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFeaturedCard(context, featured),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.auto_awesome_rounded,
                          title: AppStrings.create,
                          subtitle: 'Start from a photo or a prompt',
                          onTap: () => context.go(AppRoutes.buildMainTabUrl(1)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.collections_bookmark_rounded,
                          title: AppStrings.history,
                          subtitle: 'Revisit saved idea paths',
                          onTap: () => context.go(AppRoutes.buildMainTabUrl(2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ZeriaSectionTitle(
                  title: 'Idea sparks',
                  subtitle: 'CURATED FOR YOU',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildGalleryCard(
                    context,
                    galleryItems[index],
                    '${index + 1}',
                  ),
                  childCount: galleryItems.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 130)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const ZeriaBrandMark(size: 54),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zeria',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.brandInk,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'Upload a photo or prompt, get 3 useful next moves.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<int>(
          valueListenable: CoinsManager.instance.coinsNotifier,
          builder: (context, coins, child) {
            return ZeriaPill(
              label: '$coins coins',
              icon: Icons.auto_awesome_rounded,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.brandInk,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context, SparkResult data) {
    return Hero(
      tag: 'item_0',
      child: ZeriaSurfaceCard(
        onTap: () => context.push('/detail/0'),
        padding: EdgeInsets.zero,
        radius: 34,
        child: SizedBox(
          height: 320,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ZeriaAdaptiveImage(
                assetPath: data.assetImg,
                borderRadius: BorderRadius.circular(33),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: ZeriaPill(
                  label: 'Spark pick',
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: ZeriaPill(
                  label: data.tags.isNotEmpty ? data.tags.first : 'Curated',
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.26),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.oneLineSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h3Inverse.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ZeriaPill(
                        label: data.sceneCard.atmosphere.value,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        foregroundColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ZeriaSurfaceCard(
      onTap: onTap,
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(BuildContext context, SparkResult data, String id) {
    final pillLabel = data.tags.isNotEmpty
        ? data.tags.first
        : data.sceneCard.atmosphere.value;

    return Hero(
      tag: 'item_$id',
      child: ZeriaSurfaceCard(
        onTap: () => context.push('/detail/$id'),
        padding: EdgeInsets.zero,
        radius: 28,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ZeriaAdaptiveImage(
              assetPath: data.assetImg,
              borderRadius: BorderRadius.circular(27),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: ZeriaPill(
                label: pillLabel,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  data.oneLineSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
