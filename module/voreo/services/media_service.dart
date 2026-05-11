import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MediaService extends GetxService {
  static MediaService get to => Get.find();

  // Save image to gallery
  Future<bool> saveImageToGallery(String imagePath) async {
    try {
      final result = await GallerySaver.saveImage(imagePath);
      return result ?? false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Share image
  Future<void> shareImage(String imagePath) async {
    try {
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Check out my hairstyle preview!',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get temporary directory path
  Future<String> getTempPath() async {
    final tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }
}
