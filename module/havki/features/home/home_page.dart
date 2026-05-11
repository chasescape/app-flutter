import 'package:flutter/material.dart';
import 'package:havki/gen_a/A.dart';
import 'package:havki/havki/app/routes/app_routes.dart';
import 'package:havki/havki/app/theme/app_theme.dart';
import 'package:havki/havki/data/models/quote/quote_card_data.dart';

final List<QuoteCardData> allQuoteMockData = [
  QuoteCardData(assetImg: A.assets_havki_1, quote: 'Life is what happens when you are busy making other plans.', author: 'John Lennon'),
  QuoteCardData(assetImg: A.assets_havki_2, quote: 'The only way to do great work is to love what you do.', author: 'Steve Jobs'),
  QuoteCardData(assetImg: A.assets_havki_3, quote: 'In the middle of difficulty lies opportunity.', author: 'Albert Einstein'),
  QuoteCardData(assetImg: A.assets_havki_4, quote: 'Believe you can and you are halfway there.', author: 'Theodore Roosevelt'),
  QuoteCardData(assetImg: A.assets_havki_5, quote: 'The future belongs to those who believe in the beauty of their dreams.', author: 'Eleanor Roosevelt'),
  QuoteCardData(assetImg: A.assets_havki_6, quote: 'It is during our darkest moments that we must focus to see the light.', author: 'Aristotle'),
  QuoteCardData(assetImg: A.assets_havki_7, quote: 'The only impossible journey is the one you never begin.', author: 'Tony Robbins'),
  QuoteCardData(assetImg: A.assets_havki_8, quote: 'Success is not final, failure is not fatal.', author: 'Winston Churchill'),
  QuoteCardData(assetImg: A.assets_havki_9, quote: 'Believe in yourself and all that you are.', author: 'Christian D. Larson'),
  QuoteCardData(assetImg: A.assets_havki_10, quote: 'Peace comes from within. Do not seek it without.', author: 'Buddha'),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = allQuoteMockData.first;
    final mosaicItems = allQuoteMockData.skip(1).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: AppNavigator.I.toCreate,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        label: const Text(
          'Create',
          style: TextStyle(fontWeight: AppFontWeights.semibold),
        ),
        icon: const Icon(Icons.add_a_photo_outlined),
      ),
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: AppSectionTitle(
                            eyebrow: 'Daily Curation',
                            title: 'Havki',
                          ),
                        ),
                        Row(
                          children: [
                            AppCircleIconButton(
                              icon: Icons.history,
                              onPressed: AppNavigator.I.toHistory,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            AppCircleIconButton(
                              icon: Icons.person_outline,
                              onPressed: AppNavigator.I.toProfile,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FeaturedCard(item: featured),
                    const SizedBox(height: AppSpacing.md),
                    const _CollectionStrip(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              sliver: SliverList.separated(
                itemCount: (mosaicItems.length / 2).ceil(),
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, rowIndex) {
                  final leftIndex = rowIndex * 2;
                  final rightIndex = leftIndex + 1;
                  final reverse = rowIndex.isOdd;
                  final leftFlex = reverse ? 4 : 5;
                  final rightFlex = reverse ? 5 : 4;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: leftFlex,
                        child: _MosaicCard(
                          item: mosaicItems[leftIndex],
                          compact: reverse,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: rightFlex,
                        child: rightIndex < mosaicItems.length
                            ? _MosaicCard(
                                item: mosaicItems[rightIndex],
                                compact: !reverse,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionStrip extends StatelessWidget {
  const _CollectionStrip();

  @override
  Widget build(BuildContext context) {
    return const AppGlassCard(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          _MiniPill(icon: Icons.auto_awesome_outlined, label: 'Soft'),
          SizedBox(width: AppSpacing.sm),
          _MiniPill(icon: Icons.photo_library_outlined, label: 'Visual'),
          SizedBox(width: AppSpacing.sm),
          _MiniPill(icon: Icons.wb_twilight_outlined, label: 'Mood'),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppFontSizes.small,
                  fontWeight: AppFontWeights.semibold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final QuoteCardData item;

  const _FeaturedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.I.toDetail(item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          boxShadow: AppShadows.lg,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.28,
                child: Hero(
                  tag: item.assetImg,
                  child: Image.asset(
                    item.assetImg,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.16),
                        Colors.black.withValues(alpha: 0.68),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.arrow_outward_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundOverlay,
                        borderRadius: BorderRadius.circular(AppBorderRadius.full),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          fontWeight: AppFontWeights.semibold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.quote,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: AppFontWeights.bold,
                        color: AppColors.textInverse,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppFontSizes.small,
                        fontWeight: AppFontWeights.medium,
                        color: Color(0xE6FFFFFF),
                        height: AppLineHeights.normal,
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

class _MosaicCard extends StatelessWidget {
  final QuoteCardData item;
  final bool compact;

  const _MosaicCard({
    required this.item,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.I.toDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          border: Border.all(color: AppColors.divider),
          boxShadow: AppShadows.md,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: AspectRatio(
                  aspectRatio: compact ? 0.82 : 1.12,
                  child: Hero(
                    tag: item.assetImg,
                    child: Image.asset(
                      item.assetImg,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppFontSizes.caption,
                  fontWeight: AppFontWeights.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.quote,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppFontSizes.small,
                    color: AppColors.textSecondary,
                    height: AppLineHeights.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
