import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/velise_ui.dart';
import '../../../data/models/thingtale_item.dart';
import '../controllers/detail_controller.dart';

class DetailPage extends GetView<DetailController> {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VeliseScaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final item = controller.itemData.value;
          if (item == null) {
            return const Center(
              child: VeliseSurfaceCard(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textPrimary,
                      size: 42,
                    ),
                    SizedBox(height: 12),
                    Text('Archive unavailable', style: AppTextStyles.h2Style),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageHeader(item),
                      const SizedBox(height: 20),
                      _buildHeadlineCard(item),
                      const SizedBox(height: 18),
                      _buildSceneCard(item),
                      const SizedBox(height: 18),
                      _buildStoryCard(item),
                      const SizedBox(height: 18),
                      _buildMaterialCard(item),
                      const SizedBox(height: 18),
                      _buildDiscoveryCard(item),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildImageHeader(ThingTaleItem item) {
    return SizedBox(
      height: 430,
      child: Stack(
        children: [
          Positioned.fill(
            child: VeliseAdaptiveImage(
              imagePath: item.assetImg,
              borderRadius: BorderRadius.circular(34),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: AppColors.photoScrimGradient,
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: VeliseActionButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: Get.back,
              light: true,
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: VeliseActionButton(
              icon: Icons.share_rounded,
              onTap: controller.onShare,
              light: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadlineCard(ThingTaleItem item) {
    return VeliseSurfaceCard(
      light: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTO STORY',
              style: AppTextStyles.eyebrowStyle
                  .copyWith(color: AppColors.textOnSurfaceSoft)),
          const SizedBox(height: 10),
          Text(item.primaryItem.nameHint,
              style: AppTextStyles.surfaceTitleStyle),
          const SizedBox(height: 8),
          Text(
            item.description.storyFeeling,
            style: AppTextStyles.surfaceBodyStyle,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              VelisePill(
                label: item.primaryItem.category.replaceAll('_', ' '),
                icon: Icons.photo_library_outlined,
                light: true,
              ),
              VelisePill(
                label: item.primaryItem.style,
                icon: Icons.auto_awesome_outlined,
                light: true,
              ),
              VelisePill(
                label: item.primaryItem.condition,
                icon: Icons.stars_rounded,
                light: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.tags
                .map(
                  (tag) => VelisePill(
                    label: tag.startsWith('#') ? tag : '#$tag',
                    light: true,
                    compact: true,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneCard(ThingTaleItem item) {
    return VeliseSurfaceCard(
      light: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VeliseSectionHeading(
            title: 'Scene',
            subtitle:
                'Context, mood, and the visual temperature around the object.',
            light: true,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Location', item.sceneCard.location),
          _buildInfoRow('Time', item.sceneCard.timeContext),
          _buildInfoRow('Mood', item.sceneCard.mood),
          _buildInfoRow('Lighting', item.sceneCard.lighting),
        ],
      ),
    );
  }

  Widget _buildStoryCard(ThingTaleItem item) {
    return VeliseSurfaceCard(
      light: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VeliseSectionHeading(
            title: 'Reading',
            subtitle:
                'The descriptive and emotional layer stays beneath the photo.',
            light: true,
          ),
          const SizedBox(height: 16),
          _buildNarrativeBlock('Appearance', item.description.appearance),
          const SizedBox(height: 14),
          _buildNarrativeBlock('Character', item.description.character),
          const SizedBox(height: 14),
          _buildNarrativeBlock('Memory', item.memoryReflection.reflection),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(ThingTaleItem item) {
    return VeliseSurfaceCard(
      light: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VeliseSectionHeading(
            title: 'Object Notes',
            subtitle:
                'Materials, craftsmanship, and color cues pulled from the image.',
            light: true,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...item.primaryItem.materials.map(
                (material) => VelisePill(
                  label: material,
                  icon: Icons.texture_outlined,
                  light: true,
                  compact: true,
                ),
              ),
              ...item.primaryItem.colors.map(
                (color) => VelisePill(
                  label: color,
                  icon: Icons.palette_outlined,
                  light: true,
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.primaryItem.craftsmanshipNotes,
            style: AppTextStyles.surfaceBodyStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryCard(ThingTaleItem item) {
    return VeliseSurfaceCard(
      light: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VeliseSectionHeading(
            title: 'AI Discovery',
            subtitle:
                'Loose associations and companion cues, kept clean and readable.',
            light: true,
          ),
          const SizedBox(height: 16),
          _buildNarrativeBlock(
              'Possible origin', item.discovery.possibleOrigin),
          const SizedBox(height: 16),
          Text(
            'Special details',
            style: AppTextStyles.surfaceMetaStyle.copyWith(
              fontWeight: AppTextStyles.semibold,
            ),
          ),
          const SizedBox(height: 10),
          ...item.discovery.specialDetails.map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.textOnSurfaceSoft,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      detail,
                      style: AppTextStyles.surfaceBodyStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.discovery.companionItems
                .map(
                  (entry) => VelisePill(
                    label: entry,
                    icon: Icons.link_rounded,
                    light: true,
                    compact: true,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTextStyles.surfaceMetaStyle.copyWith(
                fontWeight: AppTextStyles.semibold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.surfaceBodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrativeBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.surfaceMetaStyle.copyWith(
            fontWeight: AppTextStyles.semibold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.surfaceBodyStyle,
        ),
      ],
    );
  }
}
