import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import '../../shared/widgets/common/gradient_background.dart';
import '../../routes/app_pages.dart';
import 'history_logic.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  // 确保使用永久实例，如果不存在则创建
  final HistoryLogic logic = Get.isRegistered<HistoryLogic>() 
      ? Get.find<HistoryLogic>() 
      : Get.put(HistoryLogic(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.chevron_left, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Inspection History',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _buildHistoryList(),
      ),
    );
  }

  // History list
  Widget _buildHistoryList() {
    return Obx(() {
      final items = logic.historyItems;
      print('=== HistoryPage _buildHistoryList ===');
      print('Logic instance hash: ${logic.hashCode}');
      print('Items count: ${items.length}');
      if (items.isNotEmpty) {
        print('First item: ${items.first.equipmentName}');
        for (int i = 0; i < items.length; i++) {
          print('  [$i]: ${items[i].equipmentName} - ${items[i].date}');
        }
      }
      print('=== End _buildHistoryList ===');
      
      if (items.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 100.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.inbox,
                  size: 64.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No inspection records',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(24.w),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildHistoryCard(item);
        },
      );
    });
  }

  // History card
  Widget _buildHistoryCard(item) {
    final riskLevel = item.riskLevel;
    List<Color> bubbleGradient;
    List<Color> badgeGradient;
    
    if (riskLevel == 'Low') {
      bubbleGradient = [
        const Color(0xFFFFF9FB), // 粉白
        const Color(0xFFFFF4DC), // 淡黄
      ];
      badgeGradient = [
        const Color(0xFFE1BEE7), // 淡紫
        const Color(0xFFCE93D8), // 紫色
      ];
    } else if (riskLevel == 'Medium') {
      bubbleGradient = [
        const Color(0xFFFFF0F5), // 淡粉
        const Color(0xFFFFF4DC), // 淡黄
      ];
      badgeGradient = [
        const Color(0xFFF8BBD0), // 粉色
        const Color(0xFFF48FB1), // 深粉
      ];
    } else {
      bubbleGradient = [
        const Color(0xFFFFF5F3), // 淡橙粉
        const Color(0xFFFFF4DC), // 淡黄
      ];
      badgeGradient = [
        const Color(0xFFFFCCBC), // 珊瑚
        const Color(0xFFFFAB91), // 深珊瑚
      ];
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.detail, arguments: item.toMap());
      },
      child: Container(
        height: 160.h,
        child: Stack(
          children: [
            // Background card - 白色
            Positioned(
              left: 0,
              right: 0,
              top: 20.h,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(8.r),
                    bottomLeft: Radius.circular(8.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),

            // Image with rotation and shadow
            Positioned(
              left: 16.w,
              top: 0,
              child: Container(
                width: 140.w,
                height: 140.h,
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
                child: Hero(
                  tag: 'equipment_${item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: _buildImage(item.image),
                  ),
                ),
              ),
            ),

            // Content area
            Positioned(
              left: 170.w,
              right: 16.w,
              top: 30.h,
              bottom: 10.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Equipment name
                  Text(
                    item.equipmentName,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212121),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date with gradient bubble
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: bubbleGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 12.sp,
                              color: const Color(0xFF757575),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              item.date,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF424242),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Status
                      Text(
                        item.status,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF212121),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Risk badge with gradient
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: badgeGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(4.r),
                            bottomLeft: Radius.circular(4.r),
                            bottomRight: Radius.circular(12.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: badgeGradient[0].withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '$riskLevel Risk',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow indicator with gradient bubble
            Positioned(
              right: 8.w,
              top: 28.h,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bubbleGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.chevron_right,
                  size: 16.sp,
                  color: const Color(0xFF757575),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建图片 Widget，支持本地文件和 asset
  Widget _buildImage(String imagePath) {
    // 检查是否是本地文件路径
    if (imagePath.startsWith('/') || imagePath.contains('file://')) {
      final file = File(imagePath.replaceAll('file://', ''));
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
        );
      }
    }
    
    // 否则作为 asset 加载
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: Icon(
            LucideIcons.image_off,
            size: 40.sp,
            color: Colors.grey[600],
          ),
        );
      },
    );
  }
}
