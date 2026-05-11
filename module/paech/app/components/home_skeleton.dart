import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

/// Home 页面骨架屏
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Care Tips 标题
          const SkeletonText(width: 180, height: 24),
          const SizedBox(height: 12),
          
          // Featured Card
          _SkeletonFeaturedCard(),
          
          const SizedBox(height: 22),
          
          // Quick Tips 标题
          const SkeletonText(width: 100, height: 18),
          const SizedBox(height: 12),
          
          // Quick Tips 卡片行
          Row(
            children: [
              Expanded(child: _SkeletonQuickTipCard()),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonQuickTipCard()),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonQuickTipCard()),
            ],
          ),
          
          const SizedBox(height: 22),
          
          // Popular Styles 标题
          const SkeletonText(width: 150, height: 24),
          const SizedBox(height: 12),
          
          // Popular Styles Card
          _SkeletonPopularStylesCard(),
          
          const SizedBox(height: 22),
          
          // Quick Tips 标题
          const SkeletonText(width: 100, height: 18),
          const SizedBox(height: 12),
          
          // Quick Tips 卡片行
          Row(
            children: [
              Expanded(child: _SkeletonQuickTipCard()),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonQuickTipCard()),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonQuickTipCard()),
            ],
          ),
          
          const SizedBox(height: 18),
          
          // Editor's Pick 标题
          const SkeletonText(width: 130, height: 24),
          const SizedBox(height: 12),
          
          // Editor's Pick Card
          _SkeletonEditorsPickCard(),
          
          const SizedBox(height: 22),
          
          // Explore More 标题
          const SkeletonText(width: 140, height: 24),
          const SizedBox(height: 12),
          
          // Explore More Grid
          _SkeletonExploreGrid(),
        ],
      ),
    );
  }
}

/// Featured Card 骨架屏
class _SkeletonFeaturedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SkeletonLoader(
            width: 128,
            height: 160,
            borderRadius: BorderRadius.circular(14),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonText(width: double.infinity, height: 20),
                const SizedBox(height: 8),
                const SkeletonText(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                const SkeletonText(width: 150, height: 14),
                const SizedBox(height: 4),
                const SkeletonText(width: 120, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Tip Card 骨架屏
class _SkeletonQuickTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
            width: double.infinity,
            height: 130,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(
                  width: double.infinity,
                  height: 14,
                ),
                const SizedBox(height: 4),
                SkeletonText(
                  width: double.infinity,
                  height: 12,
                ),
                const SizedBox(height: 2),
                const SkeletonText(
                  width: 80,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Popular Styles Card 骨架屏
class _SkeletonPopularStylesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SkeletonLoader(
            width: 125,
            height: 160,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonText(width: double.infinity, height: 18),
                const SizedBox(height: 8),
                const SkeletonText(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                const SkeletonText(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                const SkeletonText(width: 140, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Editor's Pick Card 骨架屏
class _SkeletonEditorsPickCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 560,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFE4E0DA),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: SkeletonLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC000000),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonLoader(
                    width: double.infinity,
                    height: 24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 10),
                  SkeletonLoader(
                    width: double.infinity,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoader(
                    width: 200,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Explore Grid 骨架屏
class _SkeletonExploreGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SkeletonExploreCard()),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonExploreCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SkeletonExploreCard()),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonExploreCard()),
          ],
        ),
      ],
    );
  }
}

/// Explore Card 骨架屏
class _SkeletonExploreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
            width: double.infinity,
            height: 180,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(
                  width: double.infinity,
                  height: 16,
                ),
                const SizedBox(height: 6),
                SkeletonText(
                  width: double.infinity,
                  height: 12,
                ),
                const SizedBox(height: 3),
                const SkeletonText(
                  width: 100,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
