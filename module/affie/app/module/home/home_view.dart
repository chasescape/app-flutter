import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'home_logic.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../data/home_data.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeLogic logic = Get.put(HomeLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: _HomeBackground()),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                    child: _Header(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                    child: _HighlightHeroCard(
                      cave: HomeData.featuredAdventure,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 30, 16, 0),
                  child: _SectionTitle(
                    icon: Icons.trending_up_rounded,
                    title: 'Cave Exploration Picks',
                  ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _PopularSmallCard(
                                cave: HomeData.popularDestinations[0],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PopularSmallCard(
                                cave: HomeData.popularDestinations[1],
                              ),
                            ),
                          ],
                        ),
                        if (HomeData.popularDestinations.length > 2) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _PopularSmallCard(
                                  cave: HomeData.popularDestinations[2],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PopularSmallCard(
                                  cave: HomeData.popularDestinations[3],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 30, 16, 0),
                  child: _SectionTitle(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Featured Cave Routes',
                  ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _FeaturedLargeCard(cave: HomeData.featuredAdventure),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 30, 16, 0),
                  child: _SectionTitle(
                    icon: Icons.photo_camera_rounded,
                    title: 'Gear Recommendation',
                  ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _CommunityGrid(shares: HomeData.communityShares),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 30, 16, 0),
                  child: _SectionTitle(
                    icon: Icons.workspace_premium_rounded,
                    title: 'AI Gear Check Entry',
                  ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: _PickLargeCard(share: HomeData.explorersPick),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (!logic.showInitialSkeleton.value) {
              return const SizedBox.shrink();
            }
            return const Positioned.fill(
              child: IgnorePointer(
                child: _HomeSkeletonOverlay(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HomeSkeletonOverlay extends StatelessWidget {
  const _HomeSkeletonOverlay();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);
    final glowColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.14);

    return Stack(
      children: [
        Positioned.fill(child: _HomeBackground()),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 150, height: 36, color: skeletonColor),
                const SizedBox(height: 10),
                _SkeletonBox(width: double.infinity, height: 16, color: skeletonColor),
                const SizedBox(height: 32),
                _SkeletonBox(width: double.infinity, height: 520, radius: 30, color: glowColor),
                const SizedBox(height: 26),
                _SkeletonBox(width: 200, height: 22, color: skeletonColor),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _SkeletonBox(height: 180, radius: 24, color: skeletonColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _SkeletonBox(height: 180, radius: 24, color: skeletonColor)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _SkeletonBox(height: 180, radius: 24, color: skeletonColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _SkeletonBox(height: 180, radius: 24, color: skeletonColor)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width = double.infinity,
    required this.height,
    required this.color,
    this.radius = 14,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkBackground,
                  Color.lerp(AppColors.darkBackground, AppColors.primaryDark, 0.25)!,
                  Colors.black,
                ]
              : [
                  AppColors.background,
                  AppColors.primaryLight,
                  Colors.white,
                ],
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withOpacity(isDark ? 0.28 : 0.45),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Explore',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.primaryDark,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Cave routes, gear recommendations, and AI safety checks for your equipment.',
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.9)
                : AppColors.textSecondary.withValues(alpha: 0.95),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _HighlightHeroCard extends StatelessWidget {
  const _HighlightHeroCard({required this.cave});

  final HomeCave cave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.detail, arguments: {'id': cave.id, 'image': cave.image}),
      child: Container(
        height: 520,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  cave.image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(isDark ? 0.18 : 0.12),
                        Colors.black.withOpacity(isDark ? 0.88 : 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 18,
                top: 18,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFC857),
                        Color(0xFFFFA341),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    cave.difficulty,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 22,
                left: 18,
                right: 18,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cave.location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cave.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cave.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1.5–2 hours · 8–15 people',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      cave.description ??
                          'Step into a world of natural wonder, where thousands of stalactites and stalagmites have formed over millions of years. This accessible cave features calm underground pools and towering limestone formations, making it a perfect introduction to cave exploration.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.accent3 : AppColors.primaryDark,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.95)
                : AppColors.textPrimary.withOpacity(0.98),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _FeaturedLargeCard extends StatelessWidget {
  const _FeaturedLargeCard({required this.cave});

  final HomeCave cave;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.detail, arguments: {'id': cave.id, 'image': cave.image}),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  cave.image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.55),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cave.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: AppColors.accent3,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      cave.location,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _StatPill(
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFFFFC857),
                            text: cave.rating.toStringAsFixed(1),
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            icon: Icons.people_alt_rounded,
                            iconColor: Colors.white.withOpacity(0.85),
                            text: '${cave.explorersCount}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularSmallCard extends StatelessWidget {
  const _PopularSmallCard({required this.cave});

  final HomeCave cave;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.detail, arguments: {'id': cave.id, 'image': cave.image}),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  cave.image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.18),
                        Colors.black.withOpacity(0.72),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cave.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: AppColors.accent3,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            cave.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: const Color(0xFFFFC857),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          cave.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.people_alt_rounded,
                          size: 13,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${cave.explorersCount}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityGrid extends StatelessWidget {
  const _CommunityGrid({required this.shares});

  final List<HomeShare> shares;

  @override
  Widget build(BuildContext context) {
    final left = <HomeShare>[];
    final right = <HomeShare>[];

    for (var i = 0; i < shares.length; i++) {
      (i.isEven ? left : right).add(shares[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _CommunityColumn(items: left)),
        const SizedBox(width: 12),
        Expanded(child: _CommunityColumn(items: right)),
      ],
    );
  }
}

class _CommunityColumn extends StatelessWidget {
  const _CommunityColumn({required this.items});

  final List<HomeShare> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: entry.key == items.length - 1 ? 0 : 12),
              child: _CommunityCard(share: entry.value),
            ),
          )
          .toList(),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.share});

  final HomeShare share;

  @override
  Widget build(BuildContext context) {
    final tagColor =
        share.tag == 'Equipment' ? const Color(0xFFFFC857) : AppColors.secondary;
    final tagIcon =
        share.tag == 'Equipment' ? Icons.tune_rounded : Icons.photo_camera_rounded;

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.detail, arguments: {'id': share.id, 'image': share.image}),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  share.image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.76),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: _BadgeChip(
                  label: share.tag,
                  background: tagColor.withOpacity(0.95),
                  foreground: share.tag == 'Equipment' ? Colors.black : Colors.white,
                  icon: tagIcon,
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      share.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      share.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (share.isVerified) ...[
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: const Color(0xFFFFC857),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Verified',
                            style: TextStyle(
                              color: const Color(0xFFFFC857),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                        ] else ...[
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: AppColors.accent3,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              share.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.favorite_rounded,
                          size: 14,
                          color: Color(0xFFFF6B8A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${share.likes}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickLargeCard extends StatelessWidget {
  const _PickLargeCard({required this.share});

  final HomeShare share;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.detail, arguments: {'id': share.id, 'image': share.image}),
      child: Container(
        height: 480,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  share.image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.18),
                        Colors.black.withOpacity(0.88),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                top: 14,
                child: _BadgeChip(
                  label: "Explorer's Pick",
                  background: AppColors.secondary,
                  foreground: Colors.white,
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
              Positioned(
                right: 14,
                top: 14,
                child: _BadgeChip(
                  label: share.tag,
                  background: AppColors.accent2,
                  foreground: Colors.white,
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      share.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${share.author} · ${share.date ?? share.location}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if ((share.about ?? '').isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        share.about!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '${share.likes} likes',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              Get.toNamed(AppRoutes.detail, arguments: {'id': share.id, 'image': share.image}),
                          child: const Text('View Details  →'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF7A5C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

Color _difficultyColor(String value) {
  final v = value.toLowerCase();
  if (v.contains('beginner')) return const Color(0xFFFFC857);
  if (v.contains('intermediate')) return const Color(0xFFFF7A5C);
  return const Color(0xFFFF4D7D);
}
