import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/photo_data.dart';
import '../../services/generated_photo_service.dart';

class DetailLogic extends GetxController {
  final photoData = <String, dynamic>{}.obs;
  String? _lastLoadedId;
  late final GeneratedPhotoService _photoService;

  @override
  void onInit() {
    super.onInit();
    // ✅ 性能优化：使用 Get.find 替代 Get.put，避免重复创建服务实例
    _photoService = Get.find<GeneratedPhotoService>();
    // ✅ 性能优化：延迟加载，避免阻塞 UI 初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadPhoto(Get.arguments as String?);
    });
  }

  /// 根据当前路由 arguments 加载对应照片，每次进入页面都会用最新 id 刷新
  void loadPhoto(String? id) {
    final photoId = id ?? '1';
    if (photoId == _lastLoadedId) return;
    _lastLoadedId = photoId;
    
    // 先尝试从生成的照片中查找
    if (photoId.startsWith('gen_')) {
      final generatedPhoto = _photoService.getPhotoById(photoId);
      if (generatedPhoto != null) {
        photoData.value = generatedPhoto;
        return;
      }
    }
    
    // 否则从预定义照片中查找
    final photo = PhotoDataSource.getPhotoById(photoId);
    if (photo != null) {
      photoData.value = photo.toMap();
    } else {
      photoData.value = PhotoDataSource.allPhotos.first.toMap();
    }
  }

  Future<void> onShare() async {
    try {
      final imagePath = photoData['image'] as String?;
      final title = photoData['title'] as String? ?? 'Travel Memory';
      final location = photoData['location'] as String? ?? '';
      final date = photoData['date'] as String? ?? '';
      
      if (imagePath == null) {
        Get.snackbar(
          'Error',
          'No image to share',
          backgroundColor: const Color(0xFFef4444),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // 检查是否是 asset 图片
      final isAsset = !imagePath.startsWith('/');
      
      if (isAsset) {
        // Asset 图片只能分享文字
        await Share.share(
          '$title\n📍 $location\n📅 $date',
          subject: title,
        );
      } else {
        // 本地文件可以分享图片
        final file = File(imagePath);
        if (await file.exists()) {
          await Share.shareXFiles(
            [XFile(imagePath)],
            text: '$title\n📍 $location\n📅 $date',
            subject: title,
          );
        } else {
          // 文件不存在，只分享文字
          await Share.share(
            '$title\n📍 $location\n📅 $date',
            subject: title,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share: $e',
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}