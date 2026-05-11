import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_logic.dart';
import 'widgets/photo_detail_body.dart';

// ✅ 性能优化：使用 GetView 替代 StatelessWidget + Get.put，避免重复创建 Controller
class DetailPage extends GetView<DetailLogic> {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0b2e),
      // ✅ 性能优化：缩小 Obx 范围，只监听 photoData 变化
      body: Obx(() {
        final photo = controller.photoData;
        final photoId = Get.arguments?.toString() ?? '1';
        
        if (photo.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return PhotoDetailBody(photo: photo, photoId: photoId);
      }),
    );
  }
}
