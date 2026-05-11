import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:senxo/senxo/app/module/nav/nav_view.dart';
import 'package:senxo/gen_a/A.dart';
import '../../shared/widgets/common/gradient_background.dart';
import 'generate_logic.dart';

class GeneratePage extends StatelessWidget {
  GeneratePage({super.key});

  final GenerateLogic logic = Get.put(GenerateLogic());

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: _buildGeneratePage(),
            ),
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

  Widget _buildGeneratePage() {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header with Coins
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Inspection',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Upload your equipment photo for AI analysis',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                // Coins Display
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFDAE0),
                        Color(0xFFFFF4DC),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFDAE0).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.coins,
                        size: 18.sp,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${logic.coins}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),


          // Cost Information
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF0F8FF),
                    Color(0xFFFFF9FB),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFFFFDAE0).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDAE0).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      LucideIcons.info,
                      size: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Each analysis costs 100 coins',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.hand_coins,
                        size: 16.sp,
                        color: const Color(0xFFFFB347),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '100',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 18.h),

          // Upload Area
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Obx(() => _buildUploadArea()),
          ),

          SizedBox(height: 24.h),

          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: LucideIcons.camera,
                    label: 'Camera',
                    onTap: () => logic.pickImageFromCamera(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionButton(
                    icon: LucideIcons.image,
                    label: 'Gallery',
                    onTap: () => logic.pickImageFromGallery(),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),


          // Analyze Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildAnalyzeButton(),
          ),

          SizedBox(height: 24.h),

          // 后台任务提示
          Obx(() {
            if (logic.hasBackgroundTasks) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE3F2FD),
                        Color(0xFFF3E5F5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFF90CAF9).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF42A5F5),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Currently analyzing in the background...',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'You can go to other pages; it will be displayed in your history after you are done.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
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
            return const SizedBox.shrink();
          }),

          SizedBox(height: 24.h),

          // AI Tips Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildAITipsCard(),
          ),

          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  // Upload Area
  Widget _buildUploadArea() {
    if (logic.hasImage.value) {
      return Container(
        height: 400.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: _buildSelectedImage(),
            ),
            // Remove button
            Positioned(
              top: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: () => logic.removeImage(),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.x,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => logic.pickImageFromGallery(),
      child: Container(
        height: 400.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9FB),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB6C1).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.upload,
                size: 48.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Upload Equipment Photo',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap to select from gallery',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AI Tips Card
  Widget _buildAITipsCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF9FB),
            Color(0xFFFFFBF0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFFFDAE0).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB6C1).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFDAE0),
                      Color(0xFFFFF4DC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  LucideIcons.lightbulb,
                  size: 20.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'AI Tips',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Upload a photo of your extreme sports equipment and let our AI analyze it for you!',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          _buildTipItem(
            LucideIcons.shield_check,
            'Safety Check',
            'Detect potential safety hazards',
          ),
          SizedBox(height: 10.h),
          _buildTipItem(
            LucideIcons.search,
            'Wear Analysis',
            'Identify wear and tear on equipment',
          ),
          SizedBox(height: 10.h),
          _buildTipItem(
            LucideIcons.circle_alert,
            'Risk Assessment',
            'Get warnings about dangerous conditions',
          ),
        ],
      ),
    );
  }

  // Tip Item
  Widget _buildTipItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Action Button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: Colors.black87),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Analyze Button
  Widget _buildAnalyzeButton() {
    return Obx(() {
      final bool disabled = logic.isAnalyzing.value || logic.hasBackgroundTasks;

      return GestureDetector(
        onTap: disabled ? null : () => logic.analyzeImage(),
        child: Opacity(
          opacity: disabled ? 0.6 : 1.0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFDAE0),
                  Color(0xFFFFF4DC),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFDAE0).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.pencil_line,
                  size: 20.sp,
                  color: Colors.black87,
                ),
                SizedBox(width: 8.w),
                Text(
                  disabled ? 'Analyzing...' : 'Analyze with AI',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSelectedImage() {
    final path = logic.selectedImagePath.value;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return Image.file(
        File(path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      A.assets_senxo_01_0,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
