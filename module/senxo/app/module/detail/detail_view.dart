import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import '../../shared/widgets/common/gradient_background.dart';
import 'detail_logic.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late final DetailLogic logic = Get.find<DetailLogic>();
  late final AnimationController _animController;
  late final Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = logic.equipmentData;
    final riskGradient = logic.getRiskGradient();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 560.h,
                  pinned: true,
                  backgroundColor: Colors.white,
                  leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                      LucideIcons.chevron_left, color: Colors.black87),
                  onPressed: () => Get.back(),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.share_2, color: Colors.black87),
                    onPressed: () {
                      logic.shareReport();
                    },
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(data['image'] ?? ''),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 100.h,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _contentOpacity,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['equipmentName'] ?? '',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF212121),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFF9FB),
                                        Color(0xFFFFF4DC),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.calendar,
                                        size: 14.sp,
                                        color: const Color(0xFF757575),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        data['date'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF424242),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: riskGradient,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.r),
                                      topRight: Radius.circular(4.r),
                                      bottomLeft: Radius.circular(4.r),
                                      bottomRight: Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    data['type'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      _buildStatsSection(data),
                      SizedBox(height: 32.h),
                      _buildAIAnalysisCard(data, riskGradient),
                      SizedBox(height: 24.h),
                      _buildIssuesSection(data, riskGradient),
                      SizedBox(height: 24.h),
                      _buildRecommendationsSection(data),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
            );
          },
        ),
      ),
    );
  }

  // Stats Section - 三个倾斜的数据卡片
  Widget _buildStatsSection(Map<String, dynamic> data) {
    return Container(
      height: 140.h,
      child: Stack(
        children: [
          // Condition Card - 左倾
          Positioned(
            left: 24.w,
            top: 0,
            child: Transform.rotate(
              angle: -0.03,
              child: _buildStatCard(
                'Condition',
                '${data['condition']}%',
                const Color(0xFF9575CD),
              ),
            ),
          ),
          // Safety Card - 中间
          Positioned(
            left: 0,
            right: 0,
            top: 20.h,
            child: Center(
              child: _buildStatCard(
                'Safety',
                '${data['safety']}%',
                const Color(0xFFEC407A),
              ),
            ),
          ),
          // Wear Level Card - 右倾
          Positioned(
            right: 24.w,
            top: 0,
            child: Transform.rotate(
              angle: 0.03,
              child: _buildStatCard(
                'Wear Level',
                data['wearLevel'] ?? '',
                const Color(0xFFFF7043),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Single Stat Card
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      width: 110.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(8.r),
          bottomLeft: Radius.circular(8.r),
          bottomRight: Radius.circular(20.r),
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // AI Analysis Card - 大气泡卡片
  Widget _buildAIAnalysisCard(Map<String, dynamic> data, List<Color> gradient) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient[0].withValues(alpha: 0.1),
              gradient[1].withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(8.r),
            bottomLeft: Radius.circular(8.r),
            bottomRight: Radius.circular(30.r),
          ),
          border: Border.all(
            color: gradient[0].withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    LucideIcons.sparkles,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'AI Analysis',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF212121),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              data['aiAnalysis'] ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF424242),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Issues Section - 不规则卡片列表
  Widget _buildIssuesSection(Map<String, dynamic> data, List<Color> gradient) {
    final issues = data['issuesFound'] as List? ?? [];
    if (issues.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Issues Found',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF212121),
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(issues.length, (index) {
            final isEven = index % 2 == 0;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Transform.rotate(
                angle: isEven ? -0.01 : 0.01,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isEven ? 24.r : 8.r),
                      topRight: Radius.circular(isEven ? 8.r : 24.r),
                      bottomLeft: Radius.circular(isEven ? 8.r : 24.r),
                      bottomRight: Radius.circular(isEven ? 24.r : 8.r),
                    ),
                    border: Border.all(
                      color: gradient[0].withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          issues[index],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF424242),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Recommendations Section - 编号气泡卡片
  Widget _buildRecommendationsSection(Map<String, dynamic> data) {
    final recommendations = data['recommendations'] as List? ?? [];
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF212121),
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(recommendations.length, (index) {
            final colors = [
              [const Color(0xFFE1BEE7), const Color(0xFFCE93D8)],
              [const Color(0xFFF8BBD0), const Color(0xFFF48FB1)],
              [const Color(0xFFFFCCBC), const Color(0xFFFFAB91)],
            ];
            final gradient = colors[index % 3];

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number bubble
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradient[0].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Content card
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.r),
                          topRight: Radius.circular(16.r),
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        recommendations[index],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF424242),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 构建图片 Widget，支持本地文件和 asset
  Widget _buildImage(String imagePath) {
    final data = logic.equipmentData;
    final equipmentId = data['id'] ?? '';

    Widget imageWidget;

    // 检查是否是本地文件路径
    if (imagePath.startsWith('/') || imagePath.contains('file://')) {
      final file = File(imagePath.replaceAll('file://', ''));
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              LucideIcons.image_off,
              size: 64.sp,
              color: Colors.grey[600],
            ),
          ),
        );
      }
    } else {
      // 否则作为 asset 加载
      imageWidget = Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Icon(
                LucideIcons.image_off,
                size: 64.sp,
                color: Colors.grey[600],
              ),
            ),
          );
        },
      );
    }

    // 用Hero包装图片以实现过渡动画
    return Hero(
      tag: 'equipment_image_$equipmentId',
      child: imageWidget,
    );
  }
}
