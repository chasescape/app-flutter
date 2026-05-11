import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/style_analysis.dart';
import '../../routes/app_pages.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/soft_ui.dart';

class HomeController extends GetxController {
  static const int heroCount = 3;
  static const int curatedCount = 4;

  final RxList<StyleAnalysis> discoverItems = <StyleAnalysis>[].obs;
  final RxList<StyleAnalysis> allItems = <StyleAnalysis>[].obs;
  final RxBool isLoading = false.obs;

  List<StyleAnalysis> get heroItems => allItems.take(heroCount).toList();

  List<StyleAnalysis> get curatedItems =>
      allItems.skip(heroItems.length).take(curatedCount).toList();

  List<StyleAnalysis> get galleryItems =>
      allItems.skip(heroItems.length + curatedItems.length).toList();

  @override
  void onInit() {
    super.onInit();
    _loadStyleData();
  }

  void _loadStyleData() {
    isLoading.value = true;
    allItems.value = allStyleMockData;
    discoverItems.value = curatedItems;
    isLoading.value = false;
  }

  void refreshPosts() {
    _loadStyleData();
  }

  void goToDetail(StyleAnalysis item) {
    Routes.toDetail(item);
  }

  void goToStyleUpload() {
    Routes.toUpload();
  }

  void goToStyleHistory() {
    Routes.toAnalysisHistory();
  }

  void goToProfile() {
    Routes.toProfile();
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NeniaBackdrop(
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            final heroItems = controller.heroItems;
            final curatedItems = controller.curatedItems;
            final galleryItems = controller.galleryItems;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Column(
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 18),
                        _buildHeroCard(heroItems),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          label: 'Curated',
                          title: 'Picture-first picks',
                          subtitle:
                              'A softer gallery view with just enough context.',
                          onAction: controller.goToStyleHistory,
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                if (curatedItems.isNotEmpty)
                  SliverToBoxAdapter(child: _buildDiscoverStrip()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: _buildSectionHeader(
                      label: 'Gallery',
                      title: 'Recent analyses',
                      subtitle: 'Large visuals first, detail on tap.',
                      onAction: controller.goToStyleUpload,
                    ),
                  ),
                ),
                if (controller.isLoading.value)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadingWidget(message: 'Loading inspiration'),
                  )
                else
                  galleryItems.isEmpty
                      ? const SliverToBoxAdapter(child: SizedBox(height: 12))
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = galleryItems[index];
                                return NeniaPhotoCard(
                                  onTap: () => controller.goToDetail(item),
                                  label: item.styleTags.isNotEmpty
                                      ? '#${item.styleTags.first}'
                                      : 'Style',
                                  title: item.styleVibe.value,
                                  subtitle: item.photoMood.value,
                                  image:
                                      NeniaAdaptiveImage(path: item.assetImg),
                                );
                              },
                              childCount: galleryItems.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.68,
                            ),
                          ),
                        ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NENIA',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.secondaryDark,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Find your image mood', style: AppTextStyles.h2),
            ],
          ),
        ),
        NeniaCircleButton(
          icon: Icons.person_outline_rounded,
          onTap: controller.goToProfile,
        ),
      ],
    );
  }

  Widget _buildHeroCard(List<StyleAnalysis> items) {
    return NeniaSurface(
      radius: 32,
      gradient: AppColors.spotlightGradient,
      boxShadow: AppShadows.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeniaPageHeader(
            label: 'Moodboard',
            title: 'A polished feed that lets the imagery lead',
            subtitle:
                'Inspired by the soft-pastel launch direction and rebuilt around airy cards.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCopy(),
                  const SizedBox(height: 16),
                  _buildHeroCollage(
                    items,
                    height: compact ? 196 : 206,
                    gap: compact ? 10 : 12,
                  ),
                  const SizedBox(height: 16),
                  _buildHeroActions(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeniaTagChip(
          label: '${controller.heroItems.length} curated looks',
          background: Colors.white.withOpacity(0.74),
        ),
        const SizedBox(height: 12),
        Text(
          'Keep copy light. Let photo quality, color mood and crop do the storytelling.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildHeroActions() {
    return NeniaPrimaryButton(
      label: 'Start analysis',
      trailingIcon: Icons.arrow_forward_rounded,
      onPressed: controller.goToStyleUpload,
    );
  }

  Widget _buildHeroCollage(
    List<StyleAnalysis> items, {
    required double height,
    required double gap,
  }) {
    final safeItems = items.take(3).toList();
    if (safeItems.isEmpty) {
      return const SizedBox.shrink();
    }
    final primary = safeItems.isNotEmpty ? safeItems[0] : null;
    final secondary = safeItems.length > 1 ? safeItems[1] : primary;
    final tertiary = safeItems.length > 2 ? safeItems[2] : secondary;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox(
              child: _buildFramedPhoto(
                item: primary ?? safeItems.first,
                height: height,
                alignment: Alignment.center,
              ),
            ),
          ),
          SizedBox(width: gap),
          SizedBox(
            width: height * 0.34,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFramedPhoto(
                  item: secondary ?? safeItems.first,
                  height: height * 0.38,
                  alignment: Alignment.center,
                  circular: true,
                ),
                _buildFramedPhoto(
                  item: tertiary ?? safeItems.first,
                  height: height * 0.38,
                  alignment: Alignment.center,
                  circular: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFramedPhoto({
    required StyleAnalysis item,
    required double height,
    Alignment alignment = Alignment.topCenter,
    bool circular = false,
  }) {
    final radius = circular ? height / 2 : 22.0;
    return Container(
      height: height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(circular ? height / 2 : 16),
        child: NeniaAdaptiveImage(
          path: item.assetImg,
          alignment: alignment,
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String label,
    required String title,
    required String subtitle,
    required VoidCallback onAction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: NeniaPageHeader(
            label: label,
            title: title,
            subtitle: subtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverStrip() {
    return SizedBox(
      height: 350,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Curating images');
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final item = controller.curatedItems[index];
            return SizedBox(
              width: 248,
              child: NeniaPhotoCard(
                onTap: () => controller.goToDetail(item),
                label: item.styleTags.isNotEmpty
                    ? '#${item.styleTags.first}'
                    : 'Featured',
                title: item.styleVibe.value,
                subtitle: item.outfitStyle.value,
                image: NeniaAdaptiveImage(path: item.assetImg),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemCount: controller.curatedItems.length,
        );
      }),
    );
  }
}
