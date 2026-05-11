import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/velise_ui.dart';
import '../../../data/models/thingtale_item.dart';
import '../controllers/history_controller.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VeliseScaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: AppColors.primaryMain,
            backgroundColor: AppColors.surfacePrimary,
            child: controller.historyItems.isEmpty
                ? CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildEmptyState(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      ...controller.historyItems.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: _buildHistoryCard(entry.value, entry.key),
                            ),
                          ),
                      const SizedBox(height: 80),
                    ],
                  ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: VeliseActionButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: Get.back,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 96),
              child: Text(
                'history',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h3Style.copyWith(
                  fontWeight: AppTextStyles.semibold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: VelisePill(
              label: '${controller.historyItems.length} saved',
              icon: Icons.collections_bookmark_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return VeliseSurfaceCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VeliseSectionHeading(
            title: 'Nothing here yet',
            subtitle:
                'Start with a single photo and the archive will begin to fill out beneath this violet backdrop.',
          ),
          const SizedBox(height: 24),
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: AppColors.lavenderGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Icon(
                Icons.photo_library_outlined,
                color: Colors.white,
                size: 52,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ThingTaleItem item, int index) {
    return VeliseSurfaceCard(
      light: true,
      padding: const EdgeInsets.all(12),
      onTap: () => controller.onItemTap(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                Positioned.fill(
                  child: VeliseAdaptiveImage(
                    imagePath: item.assetImg,
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: VelisePill(
                    label: item.sceneCard.mood,
                    icon: Icons.nights_stay_outlined,
                    light: true,
                    compact: true,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: VeliseActionButton(
                    icon: Icons.delete_outline_rounded,
                    onTap: () => controller.deleteItem(item.assetImg, index),
                    light: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.primaryItem.nameHint,
            style: AppTextStyles.surfaceTitleStyle.copyWith(fontSize: 22),
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
                label: item.primaryItem.category.replaceAll('_', ' '),
                icon: Icons.category_outlined,
                light: true,
                compact: true,
              ),
              VelisePill(
                label: item.primaryItem.style,
                icon: Icons.texture_outlined,
                light: true,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
