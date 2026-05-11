import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageAccessException implements Exception {
  const ImageAccessException(
    this.message, {
    this.shouldOpenSettings = false,
  });

  final String message;
  final bool shouldOpenSettings;

  @override
  String toString() => message;
}

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImageFromGallery() async {
    await _ensurePhotoPermission();

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    return image?.path;
  }

  static Future<String?> takePhoto() async {
    await _ensureCameraPermission();

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    return photo?.path;
  }

  static bool isValidImagePath(String path) {
    if (path.isEmpty) return false;
    final file = File(path);
    return file.existsSync();
  }

  static Future<String> copyImageToAssets(String sourcePath) async {
    return sourcePath;
  }

  static Future<void> _ensureCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      throw const ImageAccessException(
        'Camera access is disabled. Please enable it in iOS Settings to take a photo.',
        shouldOpenSettings: true,
      );
    }

    throw const ImageAccessException(
      'Camera permission was denied, so Bilra could not open the camera.',
    );
  }

  static Future<void> _ensurePhotoPermission() async {
    final status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      return;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      throw const ImageAccessException(
        'Photo access is disabled. Please enable Photos permission in iOS Settings to choose an image.',
        shouldOpenSettings: true,
      );
    }

    throw const ImageAccessException(
      'Photo library permission was denied, so Bilra could not open your gallery.',
    );
  }
}
