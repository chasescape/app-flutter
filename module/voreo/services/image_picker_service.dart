import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class ImagePickerService extends GetxService {
  static ImagePickerService get to => Get.find();

  final ImagePicker _picker = ImagePicker();

  // Pick from gallery
  Future<File?> pickFromGallery() async {
    try {
      // Check permission
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Required',
          'Please grant photo library access to select images',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Take photo
  Future<File?> takePhoto() async {
    try {
      // Check permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Required',
          'Please grant camera access to take photos',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}
