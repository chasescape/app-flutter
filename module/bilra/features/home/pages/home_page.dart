import 'package:flutter/material.dart';
import 'package:bilra/bilra/data/mock/mock_data.dart';
import 'package:bilra/bilra/data/models/makeup_analysis.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/widgets/bilra_ui.dart';
import 'package:bilra/bilra/features/home/widgets/history_content.dart';
import 'package:bilra/bilra/features/home/widgets/profile_content.dart';
import 'package:get/get.dart';
import 'package:bilra/bilra/controllers/history_controller.dart';
import 'package:bilra/gen_a/A.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.initialTabIndex,
  });

  final int? initialTabIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static int _lastVisitedTabIndex = 0;
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = _resolveTabIndex(widget.initialTabIndex);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = _resolveTabIndex(widget.initialTabIndex);
    if (nextIndex == _currentIndex) return;

    _currentIndex = nextIndex;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(nextIndex);
    }
    setState(() {});
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _lastVisitedTabIndex = index;
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  int _resolveTabIndex(int? requestedIndex) {
    return (requestedIndex ?? _lastVisitedTabIndex).clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: BilraBackdrop(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const [
            HomeContent(),
            HistoryContent(embeddedInHome: true),
            ProfileContent(embeddedInHome: true),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: BilraGlassCard(
          radius: 30,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _NavItem(
                label: 'Home',
                icon: Icons.home_rounded,
                active: _currentIndex == 0,
                onTap: () => _onNavTap(0),
              ),
              _NavItem(
                label: 'History',
                icon: Icons.grid_view_rounded,
                active: _currentIndex == 1,
                onTap: () => _onNavTap(1),
              ),
              _NavItem(
                label: 'Profile',
                icon: Icons.person_rounded,
                active: _currentIndex == 2,
                onTap: () => _onNavTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final historyController = Get.find<HistoryController>();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BilraTopBar(
              title: 'Bilra',
              subtitle: 'Soft glam inspiration',
              trailing: BilraIconChipButton(
                icon: Icons.add_a_photo_rounded,
                label: 'Create',
                onTap: () => AppRoutes.pushNamed(context, AppRoutes.create),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _HeroPanel(
                  onTap: () => AppRoutes.pushNamed(context, AppRoutes.create)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Looks for today',
                      style: AppTextStyles.h3.copyWith(fontSize: 22),
                    ),
                  ),
                  Obx(() {
                    final feedItems = _buildHomeFeed(historyController);
                    return BilraPill(
                      label: '${feedItems.length} curated looks',
                      color: AppColors.surfaceSecondary,
                    );
                  }),
                ],
              ),
            ),
          ),
          Obx(() {
            final feedItems = _buildHomeFeed(historyController);
            final rowCount = (feedItems.length / 2).ceil();

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                120,
              ),
              sliver: SliverList.builder(
                itemCount: rowCount,
                itemBuilder: (context, rowIndex) {
                  final leftIndex = rowIndex * 2;
                  final rightIndex = leftIndex + 1;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: rowIndex == rowCount - 1 ? 0 : AppSpacing.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 252,
                            child: _LookCard(
                              item: feedItems[leftIndex],
                              displayIndex: leftIndex,
                              onTap: () => AppRoutes.toDetail(
                                context,
                                feedItems[leftIndex].detailIndex,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: rightIndex < feedItems.length
                              ? SizedBox(
                                  height: 252,
                                  child: _LookCard(
                                    item: feedItems[rightIndex],
                                    displayIndex: rightIndex,
                                    onTap: () => AppRoutes.toDetail(
                                      context,
                                      feedItems[rightIndex].detailIndex,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  List<_HomeFeedItem> _buildHomeFeed(HistoryController historyController) {
    final historyItems = historyController.historyItems
        .asMap()
        .entries
        .map(
          (entry) => _HomeFeedItem(
            analysis: entry.value,
            detailIndex: entry.key,
          ),
        )
        .toList();

    final remainingSlots = allMockMakeupAnalysis.length - historyItems.length;
    if (remainingSlots <= 0) {
      return historyItems;
    }

    final mockItems = allMockMakeupAnalysis
        .take(remainingSlots)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => _HomeFeedItem(
            analysis: entry.value,
            detailIndex: historyItems.length + entry.key,
          ),
        )
        .toList();

    return [
      ...historyItems,
      ...mockItems,
    ];
  }
}

class _HomeFeedItem {
  const _HomeFeedItem({
    required this.analysis,
    required this.detailIndex,
  });

  final MakeupAnalysis analysis;
  final int detailIndex;
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BilraGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              BilraPill(
                label: 'AI image analysis',
                color: AppColors.surfaceTertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Make every look feel editorial, soft, and photo-first.',
            style: AppTextStyles.h2.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Upload a selfie, get a refined makeup direction, and explore visual references with lighter text and stronger imagery.',
            style: AppTextStyles.caption.copyWith(fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 162,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: BilraImageFrame(
                    imagePath: A.assets_bilra_3,
                    fallbackIndex: 2,
                    preferIndexedGalleryForBundledAssets: true,
                    borderRadius: 28,
                    height: double.infinity,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: BilraImageFrame(
                          imagePath: A.assets_bilra_5,
                          fallbackIndex: 4,
                          preferIndexedGalleryForBundledAssets: true,
                          borderRadius: 24,
                          height: double.infinity,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: BilraImageFrame(
                          imagePath: A.assets_bilra_9,
                          fallbackIndex: 8,
                          preferIndexedGalleryForBundledAssets: true,
                          borderRadius: 24,
                          height: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BilraPrimaryButton(
            label: 'Start analysis',
            icon: Icons.arrow_forward_rounded,
            expanded: true,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _LookCard extends StatelessWidget {
  const _LookCard({
    required this.item,
    required this.displayIndex,
    required this.onTap,
  });

  final _HomeFeedItem item;
  final int displayIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final analysis = item.analysis;
    final title = analysis.makeupRecommendation.primaryStyle.replaceAll('_', ' ');
    final keywordCount = analysis.makeupRecommendation.keywords.length;

    return GestureDetector(
      onTap: onTap,
      child: BilraGlassCard(
        padding: const EdgeInsets.all(10),
        radius: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: BilraImageFrame(
                      imagePath: analysis.assetImg,
                      fallbackIndex: displayIndex,
                      preferIndexedGalleryForBundledAssets: true,
                      borderRadius: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _toTitleCase(title),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                BilraPill(
                  label: '$keywordCount cues',
                  color: AppColors.surfaceSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _toTitleCase(String value) {
    return value
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryMain : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: active ? AppColors.textInverse : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  color:
                      active ? AppColors.textInverse : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
