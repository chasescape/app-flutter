import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:senxo/senxo/app/module/nav/nav_view.dart';
import '../../shared/widgets/common/gradient_background.dart';
import '../../routes/app_pages.dart';
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(HomeLogic());

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Obx(() => logic.isLoading.value
                ? _HomeSkeleton()
                : _HomeContentWithAnimation(logic: logic)),
            // 浮动导航栏
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: NavPage(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 首次加载时显示的骨架屏
class _HomeSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: 60.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _shimmerBox(height: 40.h, width: 180.w),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _shimmerBox(height: 28.h, width: 220.w),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _shimmerBox(height: 550.h),
        ),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _shimmerBox(height: 28.h, width: 200.w),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: [
              Expanded(child: _shimmerBox(height: 280.h)),
              SizedBox(width: 16.w),
              Expanded(child: _shimmerBox(height: 280.h)),
            ],
          ),
        ),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _shimmerBox(height: 28.h, width: 180.w),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 240.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: 4,
            itemBuilder: (_, __) => Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: _shimmerBox(height: 240.h, width: 160.w),
            ),
          ),
        ),
        SizedBox(height: 32.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _shimmerBox(height: 28.h, width: 160.w),
        ),
        SizedBox(height: 16.h),
        ...List.generate(3, (_) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Expanded(child: _shimmerBox(height: 280.h)),
                SizedBox(width: 16.w),
                Expanded(child: _shimmerBox(height: 280.h)),
              ],
            ),
          ),
        )),
        SizedBox(height: 100.h),
      ],
    ),
    );
      },
    );
  }

  Widget _shimmerBox({required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

/// 加载完成后带分段「弹出」动画的内容
class _HomeContentWithAnimation extends StatefulWidget {
  final HomeLogic logic;

  const _HomeContentWithAnimation({required this.logic});

  @override
  State<_HomeContentWithAnimation> createState() =>
      _HomeContentWithAnimationState();
}

class _HomeContentWithAnimationState extends State<_HomeContentWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _sectionAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    const intervals = [
      (0.0, 0.22),
      (0.15, 0.38),
      (0.32, 0.55),
      (0.48, 0.72),
      (0.65, 0.88),
    ];
    _sectionAnimations = intervals
        .map((e) => CurvedAnimation(
              parent: _controller,
              curve: Interval(e.$1, e.$2, curve: Curves.easeOutCubic),
            ))
        .toList();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logic = widget.logic;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: 60.h),

        _wrapSection(0, [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Discover',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ]),

        _wrapSection(1, [
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Featured Inspection',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildFeaturedCard(logic.featuredEquipment),
          ),
        ]),
        SizedBox(height: 32.h),

        _wrapSection(2, [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Recent Inspections',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildTiltCard(
                    logic.recentInspections[0],
                    tiltLeft: true,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTiltCard(
                    logic.recentInspections[1],
                    tiltLeft: false,
                  ),
                ),
              ],
            ),
          ),
        ]),
        SizedBox(height: 32.h),

        _wrapSection(3, [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Safety Overview',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 240.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: logic.safetyOverview.length,
              itemBuilder: (context, index) {
                final item = logic.safetyOverview[index];
                final accentColors = [
                  const Color(0xFF9575CD),
                  const Color(0xFFEC407A),
                  const Color(0xFFFF7043),
                  const Color(0xFF9575CD),
                  const Color(0xFFEC407A),
                  const Color(0xFFFF7043),
                ];
                return Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: _buildCompactCard(item, accentColors[index]),
                );
              },
            ),
          ),
        ]),
        SizedBox(height: 32.h),

        _wrapSection(4, [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'All Equipment',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(
            (logic.equipmentGrid.length / 2).ceil(),
            (rowIndex) {
              final startIndex = rowIndex * 2;
              final endIndex =
                  (startIndex + 2).clamp(0, logic.equipmentGrid.length);
              final rowItems =
                  logic.equipmentGrid.sublist(startIndex, endIndex);

              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTiltCard(
                          rowItems[0],
                          tiltLeft: true,
                        ),
                      ),
                      if (rowItems.length > 1) ...[
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTiltCard(
                            rowItems[1],
                            tiltLeft: false,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ]),

        SizedBox(height: 100.h),
      ],
    );
  }

  Widget _wrapSection(int index, List<Widget> children) {
    if (index >= _sectionAnimations.length) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
    final anim = _sectionAnimations[index];
    return FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(anim),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // Featured Card
  Widget _buildFeaturedCard(item) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.detail, arguments: item.toMap());
      },
      child: Container(
        height: 550.h,
        child: Stack(
          children: [
            // Background
            Positioned(
              left: 0,
              right: 0,
              top: 40.h,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(40.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
              ),
            ),

            // Image
            Positioned(
              left: 20.w,
              right: 20.w,
              top: 0,
              child: Transform.rotate(
                angle: -0.02,
                child: Container(
                  height: 420.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: Hero(
                      tag: 'equipment_image_${item.id}',
                      child: Image.asset(
                        item.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 20.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.equipmentName,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Inspected on: ${item.date}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF424242),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE1BEE7),
                          Color(0xFFCE93D8),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14.r),
                        topRight: Radius.circular(4.r),
                        bottomLeft: Radius.circular(4.r),
                        bottomRight: Radius.circular(14.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.shield_check,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          item.type,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tilt Card
  Widget _buildTiltCard(item, {required bool tiltLeft}) {
    final accentColor = item.riskLevel == 'Low'
        ? const Color(0xFF9575CD)
        : item.riskLevel == 'Medium'
        ? const Color(0xFFEC407A)
        : const Color(0xFFFF7043);

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.detail, arguments: item.toMap());
      },
      child: Container(
        height: 280.h,
        child: Stack(
          children: [
            // Background
            Positioned(
              left: 0,
              right: 0,
              top: 30.h,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(tiltLeft ? 30.r : 8.r),
                    topRight: Radius.circular(tiltLeft ? 8.r : 30.r),
                    bottomLeft: Radius.circular(tiltLeft ? 8.r : 30.r),
                    bottomRight: Radius.circular(tiltLeft ? 30.r : 8.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),

            // Image
            Positioned(
              left: 8.w,
              right: 8.w,
              top: 0,
              child: Transform.rotate(
                angle: tiltLeft ? -0.03 : 0.03,
                child: Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Hero(
                      tag: 'equipment_image_${item.id}',
                      child: Image.asset(
                        item.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Text
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.equipmentName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212121),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${item.condition}% Condition',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact Card
  Widget _buildCompactCard(item, Color accentColor) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.detail, arguments: item.toMap());
      },
      child: Container(
        width: 160.w,
        child: Stack(
          children: [
            // Background
            Positioned(
              left: 0,
              right: 0,
              top: 20.h,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(6.r),
                    bottomLeft: Radius.circular(6.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),

            // Image
            Positioned(
              left: 8.w,
              right: 8.w,
              top: 0,
              child: Transform.rotate(
                angle: -0.02,
                child: Container(
                  height: 165.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: Hero(
                      tag: 'equipment_image_${item.id}',
                      child: Image.asset(
                        item.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Text
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.equipmentName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212121),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      item.type,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
