import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/ai_service.dart';
import '../../data/generate_data.dart';
import '../../widgets/loading_overlay.dart';

class GenerateLogic extends GetxController {
  GenerateLogic({AiService? aiService})
      : _aiService = aiService ?? _createDefaultAiService();

  final selectedImage = ''.obs;
  final isAnalyzing = false.obs;

  /// 最近一次 AI 结果（用于传给详情页、写入历史）
  Map<String, dynamic>? lastAiResult;

  final AiService _aiService;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final hasPermission = await _ensurePhotoPermission();
      if (!hasPermission) return;

      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file == null) return;

      selectedImage.value = file.path;
      lastAiResult = null;
    } catch (e) {
      debugPrint('pickImage error: $e');
    }
  }

  void clearImage() {
    selectedImage.value = '';
    lastAiResult = null;
  }

  Future<void> analyzeImage() async {
    if (selectedImage.value.isEmpty || isAnalyzing.value) {
      return;
    }

    lastAiResult = null;

    final path = selectedImage.value;

    try {
      isAnalyzing.value = true;
      LoadingOverlay.show(message: 'Analyzing your gear photo...');
      final file = File(path);
      if (!await file.exists()) {
        await Future.delayed(const Duration(seconds: 1));
        return;
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final prompt = GenerateAiPrompts.gearInspectionPrompt;

      final result = await _aiService.generateVisionStory(
        base64Image: base64Image,
        prompt: prompt,
      );

      // 解析 JSON，失败则保留原始字符串
      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(result) as Map<String, dynamic>;
      } catch (_) {
        parsed = {'raw': result};
      }
      lastAiResult = {
        ...parsed,
        'imagePath': path,
        'createdAt': DateTime.now().toIso8601String(),
      };
    } catch (e, s) {
      debugPrint('analyzeImage error: $e\n$s');
    } finally {
      LoadingOverlay.hide();
      isAnalyzing.value = false;
    }
  }

  Future<bool> _ensurePhotoPermission() async {
    if (!Platform.isIOS) return true;

    var status = await Permission.photos.status;
    if (status.isDenied) {
      status = await Permission.photos.request();
    }

    if (status.isGranted) return true;

    if (status.isLimited) {
      _showLimitedPhotoAccessDialog();
      return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      _showPhotoPermissionSettingsDialog();
      return false;
    }

    return false;
  }

  void _showLimitedPhotoAccessDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Limited Photo Access'),
        content: const Text(
          'You are using limited photo access on iOS. '
          'If you cannot find the image you want, please allow full photo access in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPhotoPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Photo Permission Needed'),
        content: const Text(
          'Please enable photo access in iOS Settings to select images.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

AiService _createDefaultAiService() {
  final options = dio.BaseOptions(
    baseUrl: 'https://api.gpt.ge',
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 120),
    headers: const {
      'Authorization':
      'Bearer sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a',
      'Content-Type': 'application/json',
    },
  );

  return AiService(dio.Dio(options));
}
