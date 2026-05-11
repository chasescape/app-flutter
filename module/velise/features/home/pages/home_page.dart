import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/velise_ui.dart';
import '../../../data/models/thingtale_item.dart';
import '../../../services/coins/coins_manager.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return VeliseScaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(
          () {
            final galleryItems = controller.contentItems.length > 1
                ? controller.contentItems.skip(1).toList()
                : controller.contentItems.toList();
            final topGridItems = galleryItems.take(6).toList();
            final horizontalItems = galleryItems.skip(6).take(3).toList();
            final bottomGridItems = galleryItems.skip(9).take(6).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopRow(),
                        const SizedBox(height: 24),
                        _buildHeroText(),
                        const SizedBox(height: 20),
                        if (controller.contentItems.isNotEmpty)
                          _buildFeaturedCard(controller.contentItems.first),
                        const SizedBox(height: 28),
                        const VeliseSectionHeading(
                          title: 'Gallery',
                        ),
                      ],
                    ),
                  ),
                ),
                if (topGridItems.isNotEmpty)
                  _buildGridSection(
                    items: topGridItems,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  ),
                if (horizontalItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGalleryBreak(),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 220,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: horizontalItems.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) =>
                                  _buildHorizontalCard(horizontalItems[index]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (bottomGridItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
                      child: _buildArchiveBreak(),
                    ),
                  ),
                if (bottomGridItems.isNotEmpty)
                  _buildGridSection(
                    items: bottomGridItems,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  )
                else
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridSection({
    required List<ThingTaleItem> items,
    required EdgeInsets padding,
  }) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildGridCard(items[index]),
          childCount: items.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: CoinsManager.instance,
          builder: (context, balance, child) {
            return VelisePill(
              label: '$balance coins',
              icon: Icons.auto_awesome_rounded,
            );
          },
        ),
        const Spacer(),
        Row(
          children: [
            VeliseActionButton(
              icon: Icons.add_a_photo_rounded,
              onTap: controller.onCreateTap,
            ),
            const SizedBox(width: 10),
            VeliseActionButton(
              icon: Icons.collections_bookmark_outlined,
              onTap: controller.onHistoryTap,
            ),
            const SizedBox(width: 10),
            VeliseActionButton(
              icon: Icons.tune_rounded,
              onTap: controller.onProfileTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Velise', style: AppTextStyles.displayStyle),
        const SizedBox(height: 6),
        Text(
          'Photo-led archive.',
          style: AppTextStyles.accentStyle.copyWith(fontSize: 22),
        ),
      ],
    );
  }

  Widget _buildGalleryBreak() {
    return const VeliseSectionHeading(
      title: 'Little stories',
      subtitle:
          'A softer run of keepsakes and quiet objects, tucked into the middle of the gallery.',
    );
  }

  Widget _buildArchiveBreak() {
    return const VeliseSectionHeading(
      title: 'Collected corners',
      subtitle:
          'Smaller fragments, brighter accents, and the kind of objects that make a shelf feel personal.',
    );
  }

  Widget _buildFeaturedCard(ThingTaleItem item) {
    return VeliseSurfaceCard(
      light: true,
      padding: const EdgeInsets.all(14),
      onTap: () => controller.onItemTap(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              VeliseAdaptiveImage(
                imagePath: item.assetImg,
                height: 260,
                width: double.infinity,
              ),
              const Positioned(
                top: 12,
                left: 12,
                child: VelisePill(
                  label: 'Featured',
                  icon: Icons.star_rounded,
                  light: true,
                  compact: true,
                  textColor: AppColors.textOnSurface,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: VeliseActionButton(
                  icon: Icons.arrow_outward_rounded,
                  onTap: () => controller.onItemTap(item),
                  light: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.primaryItem.nameHint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.surfaceTitleStyle,
          ),
          const SizedBox(height: 8),
          Text(
            item.description.storyFeeling,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.surfaceBodyStyle,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              VelisePill(
                label: item.sceneCard.mood,
                icon: Icons.nights_stay_outlined,
                light: true,
                compact: true,
              ),
              VelisePill(
                label: item.primaryItem.category.replaceAll('_', ' '),
                icon: Icons.photo_outlined,
                light: true,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(ThingTaleItem item) {
    return VeliseSurfaceCard(
      light: true,
      padding: const EdgeInsets.all(10),
      onTap: () => controller.onItemTap(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: VeliseAdaptiveImage(
                    imagePath: item.assetImg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: VelisePill(
                    label: item.primaryItem.quantity.toString(),
                    icon: Icons.layers_outlined,
                    light: true,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.primaryItem.nameHint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.surfaceTitleStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.sceneCard.mood,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.surfaceMetaStyle,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: AppColors.textOnSurfaceSoft,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCard(ThingTaleItem item) {
    return SizedBox(
      width: 252,
      child: VeliseSurfaceCard(
        light: true,
        padding: const EdgeInsets.all(10),
        onTap: () => controller.onItemTap(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: VeliseAdaptiveImage(
                      imagePath: item.assetImg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: VelisePill(
                      label: item.sceneCard.mood,
                      icon: Icons.nights_stay_outlined,
                      light: true,
                      compact: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.primaryItem.nameHint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.surfaceTitleStyle.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
