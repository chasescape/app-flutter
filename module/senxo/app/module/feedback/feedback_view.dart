import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import '../../shared/widgets/common/gradient_background.dart';
import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  FeedbackPage({super.key});

  final FeedbackLogic logic = Get.put(FeedbackLogic());

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
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
              'Feedback',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 26.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: _buildFeedbackPage(),
        ),
      ),
    );
  }

  Widget _buildFeedbackPage() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        SizedBox(height: 8.h),

        // Header
        Text(
          'We\'d love to hear from you',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Report issues or share your suggestions',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),

        SizedBox(height: 32.h),

        // Feedback Type
        Text(
          'Feedback Type',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                _buildTypeChip('Bug Report', LucideIcons.bug, 0),
                _buildTypeChip('Feature Request', LucideIcons.lightbulb, 1),
                _buildTypeChip('Improvement', LucideIcons.trending_up, 2),
                _buildTypeChip('Other', LucideIcons.message_circle, 3),
              ],
            )),

        SizedBox(height: 32.h),

        // Description
        Text(
          'Description',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Stack(
          children: [
            _buildTextField(
              controller: logic.descriptionController,
              hint: 'Please provide detailed information...',
              maxLines: 8,
            ),
            // Voice Input Button
            Positioned(
              right: 12.w,
              bottom: 12.h,
              child: Obx(() => GestureDetector(
                onTap: () => logic.toggleListening(),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: logic.isListening.value
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFFDAE0),
                              Color(0xFFFFF4DC),
                            ],
                          )
                        : null,
                    color: logic.isListening.value 
                        ? null 
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: logic.isListening.value
                            ? const Color(0xFFFFDAE0).withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: logic.isListening.value ? 12 : 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    logic.isListening.value 
                        ? LucideIcons.mic_off 
                        : LucideIcons.mic,
                    size: 20.sp,
                    color: logic.isListening.value 
                        ? Colors.red[600] 
                        : Colors.black87,
                  ),
                ),
              )),
            ),
          ],
        ),
        // Show listening indicator
        Obx(() => logic.isListening.value
            ? Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Listening...',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink()),

        SizedBox(height: 32.h),

        // Submit Button
        _buildSubmitButton(),

        SizedBox(height: 40.h),
      ],
    );
  }

  // Type Chip
  Widget _buildTypeChip(String label, IconData icon, int index) {
    final isSelected = logic.selectedType.value == index;
    return GestureDetector(
      onTap: () => logic.selectType(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFFDAE0), Color(0xFFFFF4DC)],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFFFDAE0).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: Colors.black87,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[400],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(16.w),
        ),
      ),
    );
  }

  // Attachment Area
  Widget _buildAttachmentArea() {
    if (logic.hasAttachment.value) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16.r),
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
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAE0).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                LucideIcons.image,
                size: 24.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'screenshot.png',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '2.4 MB',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(LucideIcons.x, size: 20.sp, color: Colors.grey[600]),
              onPressed: () => logic.removeAttachment(),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => logic.addAttachment(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9FB),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.upload,
              size: 32.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12.h),
            Text(
              'Upload Screenshot',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'PNG, JPG up to 10MB',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Submit Button
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () => logic.submitFeedback(),
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
              color: const Color(0xFFFFDAE0).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.send, size: 20.sp, color: Colors.black87),
            SizedBox(width: 8.w),
            Text(
              'Submit Feedback',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
