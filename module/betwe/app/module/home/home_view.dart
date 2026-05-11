import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_background.dart';
import '../../widgets/app_card.dart';
import '../../data/home_data.dart';
import '../details/details_view.dart';
import '../nav/nav_logic.dart';
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeLogic logic = Get.put(HomeLogic());

  @override
  Widget build(BuildContext context) {
    final details = HomeData.careDetails;
    final reminderItems = details.take(4).toList();
    final mainItem = details.length > 4 ? details[4] : details.first;
    final smallItems = details.length > 5 ? details.skip(5).take(4).toList() : <CareDetailData>[];
    final horizontalItems = details.length > 9 ? details.skip(9).take(2).toList() : <CareDetailData>[];
    final careTaglines = [
      'Gentle care for delicate fabrics',
      'Keep colors bright and fresh',
      'Soft touch, long-lasting wear',
      'Everyday care made easy',
      'Protect the texture and shape',
      'Keep your favorites looking new',
    ];

    String subtitleFor(CareDetailData item, int index) {
      if (item.category == 'Care') {
        return careTaglines[index % careTaglines.length];
      }
      return item.overview;
    }

    return AppBackground(
      useImageBackground: true,
      safeArea: false,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // 状态栏高度的占位
          SizedBox(height: MediaQuery.of(context).padding.top),
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // 顶部标题区域
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Wardrobe',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Your clothing care assistant',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  //
                  // // My Wardrobe 卡片
                  // AppCard(
                  //   borderRadius: 24,
                  //   backgroundColor: Colors.white.withValues(alpha: 0.95),
                  //   child: const Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         'My Wardrobe',
                  //         style: TextStyle(
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.w700,
                  //           color: Colors.black,
                  //         ),
                  //       ),
                  //       SizedBox(height: 20),
                  //
                  //       // 衣物分类列表
                  //       _WardrobeItem(
                  //         icon: Icons.checkroom_outlined,
                  //         label: 'Hanging',
                  //         count: '24 items',
                  //         color: Color(0xFFFF6B9D), // 粉色
                  //       ),
                  //       SizedBox(height: 12),
                  //       _WardrobeItem(
                  //         icon: Icons.inventory_2_outlined,
                  //         label: 'Folded',
                  //         count: '36 items',
                  //         color: Color(0xFF2E2E2E), // 深灰色
                  //       ),
                  //       SizedBox(height: 12),
                  //       _WardrobeItem(
                  //         icon: Icons.storage_outlined,
                  //         label: 'Storage',
                  //         count: '12 items',
                  //         color: Color(0xFF9C27B0), // 紫色
                  //       ),
                  //
                  //       SizedBox(height: 24),
                  //
                  //       // 统计数据
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //         children: [
                  //           _StatItem(value: '72', label: 'My Items'),
                  //           _StatItem(value: '12', label: 'Need Care'),
                  //           _StatItem(value: '94%', label: 'Organized'),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  //
                  // const SizedBox(height: 20),

                  // Upload Your Clothes 卡片
                  GestureDetector(
                    onTap: () {
                      if (Get.isRegistered<NavLogic>()) {
                        Get.find<NavLogic>().onTap(1);
                      } else {
                        Get.toNamed('/nav');
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B9D), Color(0xFF9C27B0)],
                          // 粉色到紫色渐变
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Upload Your Clothes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Take a photo or upload images to get personalized care tips and organize your wardrobe',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Today's Care Reminder
                  const Text(
                    'Today\'s Care Reminder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 护理提醒卡片
                  SizedBox(
                    height: 120, // 增加高度从120到140以适应更大的卡片
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: reminderItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = reminderItems[index];
                        final image = HomeData.imageCycle[index % HomeData.imageCycle.length];
                        return _CareReminderCard(
                          image: image,
                          title: item.title,
                          subtitle: subtitleFor(item, index),
                          progress: 0.65,
                          detailIndex: index,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Care Inspirations 标题
                  const Text(
                    'Care Highlights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 大的护理灵感卡片
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => DetailsPage(
                          title: mainItem.title,
                          subtitle: mainItem.overview,
                          progress: 0.7,
                          image: HomeData.imageCycle[4],
                          category: mainItem.category,
                          overview: mainItem.overview,
                          steps: mainItem.steps,
                          proTips: mainItem.proTips,
                        ),
                      );
                    },
                    child: _CareInspirationLargeCard(
                      image: HomeData.imageCycle[4 % HomeData.imageCycle.length],
                      category: mainItem.category,
                      title: mainItem.title,
                      subtitle: mainItem.overview,
                      categoryColor: _categoryColor(mainItem.category),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Quick Care Picks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Flow layout (2 columns)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(smallItems.length, (index) {
                          final item = smallItems[index];
                          final imageIndex = 5 + index;
                          final image = HomeData.imageCycle[
                              imageIndex % HomeData.imageCycle.length];
                          return SizedBox(
                            width: itemWidth,
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => DetailsPage(
                                    title: item.title,
                                    subtitle: item.overview,
                                    progress: 0.6,
                                    image: image,
                                    category: item.category,
                                    overview: item.overview,
                                    steps: item.steps,
                                    proTips: item.proTips,
                                  ),
                                );
                              },
                              child: _CareInspirationSmallCard(
                                image: image,
                                category: item.category,
                                title: item.title,
                                subtitle: subtitleFor(item, 5 + index),
                                duration: '—',
                                difficulty: 'Easy',
                                difficultyColor: const Color(0xFFFF6B9D),
                                categoryColor: _categoryColor(item.category),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Style & Care',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 横向卡片行
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: horizontalItems.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = horizontalItems[index];
                        final imageIndex = 9 + index;
                        final image = HomeData.imageCycle[
                            imageIndex % HomeData.imageCycle.length];
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => DetailsPage(
                                title: item.title,
                                subtitle: subtitleFor(item, 9 + index),
                                progress: 0.6,
                                image: image,
                                category: item.category,
                                overview: item.overview,
                                steps: item.steps,
                                proTips: item.proTips,
                              ),
                            );
                          },
                          child: _ImageOnlyInspirationCard(
                            image: image,
                          ),
                        );
                      },
                    ),
                  ),

                  // 底部导航栏高度的占位，确保内容不被遮挡
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 新的组件类
Color _categoryColor(String category) {
  switch (category) {
    case 'Care':
      return const Color(0xFFFF6B9D);
    case 'Storage':
      return const Color(0xFF9C27B0);
    case 'Organization':
      return const Color(0xFF66BB6A);
    case 'Washing':
      return const Color(0xFF4FC3F7);
    default:
      return const Color(0xFF9C27B0);
  }
}

class _WardrobeItem extends StatelessWidget {
  const _WardrobeItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            count,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _CareReminderCard extends StatelessWidget {
  const _CareReminderCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.detailIndex,
  });

  final String image;
  final String title;
  final String subtitle;
  final double progress;
  final int detailIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final detail = HomeData.careDetails[detailIndex];
        Get.to(() => DetailsPage(
              title: detail.title,
              subtitle: detail.overview,
              progress: progress,
              image: image,
              category: detail.category,
              overview: detail.overview,
              steps: detail.steps,
              proTips: detail.proTips,
            ));
      },
      child: Container(
        width: 280, // 进一步增加宽度以适应新布局
        height: 140, // 固定高度
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左侧图片区域 - 占据整个左侧高度
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Container(
                width: 120, // 图片区域宽度
                height: 120, // 与卡片高度相同
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // 右侧内容区域
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageOnlyInspirationCard extends StatelessWidget {
  const _ImageOnlyInspirationCard({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Care Inspiration 大卡片组件
class _CareInspirationLargeCard extends StatelessWidget {
  const _CareInspirationLargeCard({
    required this.image,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.categoryColor,
  });

  final String image;
  final String category;
  final String title;
  final String subtitle;
  final Color categoryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Care Inspiration 小卡片组件
class _CareInspirationSmallCard extends StatelessWidget {
  const _CareInspirationSmallCard({
    required this.image,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.difficulty,
    required this.difficultyColor,
    required this.categoryColor,
  });

  final String image;
  final String category;
  final String title;
  final String subtitle;
  final String duration;
  final String difficulty;
  final Color difficultyColor;
  final Color categoryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片部分
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 内容部分
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
