import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/network/dio_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/coin_service.dart';
import '../../data/models/equipment/equipment_model.dart';
import '../../routes/app_pages.dart';
import '../history/history_logic.dart';

class GenerateLogic extends GetxController {
  final DioClient _dioClient = Get.find<DioClient>();
  final ImagePicker _picker = ImagePicker();
  final CoinService _coinService = Get.find<CoinService>();

  RxBool hasImage = false.obs;
  RxBool isAnalyzing = false.obs;
  RxBool hasResult = false.obs;

  /// 当前选中的图片路径（相机或相册）
  final Rx<String?> selectedImagePath = Rx<String?>(null);

  /// AI 分析结果，与展示结构一致：type, condition, safety, wear, recommendations
  final Rx<Map<String, String>?> analysisResult = Rx<Map<String, String>?>(null);

  /// 后台任务列表
  final RxList<String> backgroundTasks = <String>[].obs;

  // 获取金币数量
  int get coins => _coinService.coins;
  RxInt get coinsRx => _coinService.coinsRx;

  Future<void> pickImageFromCamera() async {
    // 请求相机权限
    final cameraStatus = await Permission.camera.request();
    
    if (cameraStatus.isGranted) {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        selectedImagePath.value = file.path;
        hasImage.value = true;
        hasResult.value = false;
        analysisResult.value = null;
      }
    } else if (cameraStatus.isDenied) {
      Get.snackbar(
        'Camera Permission Required',
        'Please grant camera permission to take photos',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
        duration: const Duration(seconds: 3),
      );
    } else if (cameraStatus.isPermanentlyDenied) {
      _showPermissionDialog('Camera', 'camera permission to take photos');
    }
  }

  Future<void> pickImageFromGallery() async {
    // 请求相册权限
    Permission permission;
    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      // Android 13+ (API 33+) 使用 Permission.photos，之前版本使用 Permission.storage
      permission = Permission.photos;
    }
    
    final status = await permission.request();
    
    if (status.isGranted || status.isLimited) {
      try {
        final XFile? file = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85, // 压缩图片质量
        );
        
        if (file != null) {
          selectedImagePath.value = file.path;
          hasImage.value = true;
          hasResult.value = false;
          analysisResult.value = null;
          
          // 如果是限制访问状态，给用户一个提示
          if (Platform.isIOS && status.isLimited) {
            Get.snackbar(
              'Limited Access',
              'Photo selected successfully. For more photos, consider allowing full access in Settings.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.blue[100],
              colorText: Colors.blue[900],
              duration: const Duration(seconds: 3),
            );
          }
        } else {
          // 用户取消选择或没有可访问的照片
          if (Platform.isIOS && status.isLimited) {
            _showLimitedAccessDialog();
          }
        }
      } catch (e) {
        print('Error picking image: $e');
        if (Platform.isIOS && status.isLimited) {
          _showLimitedAccessDialog();
        } else {
          Get.snackbar(
            'Error',
            'Failed to access gallery. Please try again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
            duration: const Duration(seconds: 3),
          );
        }
      }
    } else if (status.isDenied) {
      Get.snackbar(
        'Gallery Permission Required',
        'Please grant gallery permission to select photos',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
        duration: const Duration(seconds: 3),
      );
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog('Gallery', 'gallery permission to select photos');
    }
  }

  /// 显示权限设置对话框
  void _showPermissionDialog(String permissionName, String description) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('$permissionName Permission Required'),
        content: Text(
          'This app needs $description. Please enable it in Settings.',
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

  /// 显示限制访问对话框
  void _showLimitedAccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Limited Photo Access'),
        content: const Text(
          'You have granted limited access to your photos. To select more photos or if you can\'t find the photo you want, please allow full access to your photo library in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continue with Limited Access'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Allow Full Access'),
          ),
        ],
      ),
    );
  }

  void removeImage() {
    selectedImagePath.value = null;
    hasImage.value = false;
    hasResult.value = false;
    analysisResult.value = null;
  }

  Future<void> analyzeImage() async {
    // 防止重复点击：已有分析任务或正在分析时直接返回
    if (isAnalyzing.value || hasBackgroundTasks) {
      Get.snackbar(
        'Analysis in progress',
        'Please wait for the current analysis to finish.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final path = selectedImagePath.value;
    if (path == null || path.isEmpty) {
      Get.snackbar('Notice', 'Please select an image first');
      return;
    }

    // 检查金币是否足够
    if (!_coinService.canAnalyze()) {
      Get.snackbar(
        'Insufficient Coins',
        'You need at least ${_coinService.analysisPrice} coins to perform analysis.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // 关闭snackbar
            Get.toNamed(Routes.coins); // 跳转到充值页面
          },
          child: Text(
            'Recharge',
            style: TextStyle(
              color: Colors.orange[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      return;
    }

    // 消耗金币
    final success = await _coinService.consumeCoinsForAnalysis();
    if (!success) {
      return;
    }

    // 标记为分析中，直到后台任务结束
    isAnalyzing.value = true;

    // 生成任务 ID
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    backgroundTasks.add(taskId);

    print('=== Starting new analysis task ===');
    print('Task ID: $taskId');
    print('Image path: $path');
    print('Coins consumed: ${_coinService.analysisPrice}');
    print('Remaining coins: ${_coinService.coins}');

    // 显示提示
    Get.snackbar(
      'Analysis Started',
      'AI analysis in progress. You can navigate to other pages. Results will appear in history when complete.',
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );

    // 保存当前图片路径用于后台任务
    final imagePath = path;

    // 异步执行分析
    _analyzeImageInBackground(taskId, imagePath);
  }

  Future<void> _analyzeImageInBackground(String taskId, String imagePath) async {
    int retryCount = 0;
    const maxRetries = 2;
    
    while (retryCount <= maxRetries) {
      try {
        print('Starting analysis for task: $taskId (attempt ${retryCount + 1}/${maxRetries + 1})');
        print('Image path: $imagePath');
        
        // 检查图片文件是否存在
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          _onBackgroundTaskError(taskId, 'Image file not found: $imagePath');
          return;
        }
        
        // 检查图片文件大小
        final fileSize = await imageFile.length();
        print('Image file size: ${fileSize} bytes');
        if (fileSize == 0) {
          _onBackgroundTaskError(taskId, 'Image file is empty');
          return;
        }
        
        // 限制图片大小 (20MB)
        if (fileSize > 20 * 1024 * 1024) {
          _onBackgroundTaskError(taskId, 'Image file too large (max 20MB)');
          return;
        }
        
        final response = await _dioClient.uploadImageForAnalysis<Map<String, dynamic>>(
          imagePath,
          prompt: AppConstants.equipmentSafetyCheckPrompt,
        );

        print('Response status: ${response.statusCode}');
        print('Response data type: ${response.data.runtimeType}');
        
        final data = response.data;
        if (data == null) {
          if (retryCount < maxRetries) {
            retryCount++;
            print('No data returned, retrying... (attempt ${retryCount + 1})');
            await Future.delayed(Duration(seconds: retryCount * 2)); // 递增延迟
            continue;
          }
          _onBackgroundTaskError(taskId, 'No data returned after ${maxRetries + 1} attempts');
          return;
        }

        final content = _extractContent(data);
        if (content == null || content.isEmpty) {
          if (retryCount < maxRetries) {
            retryCount++;
            print('No analysis content in response, retrying... (attempt ${retryCount + 1})');
            await Future.delayed(Duration(seconds: retryCount * 2));
            continue;
          }
          _onBackgroundTaskError(taskId, 'No analysis content in response after ${maxRetries + 1} attempts');
          return;
        }

        print('Content to parse: $content');
        
        final parsed = _parseSafetyCheckResult(content);
        if (parsed != null) {
          print('Parsed result: $parsed');
          
          // 创建新的设备记录
          final newEquipment = _createEquipmentFromAnalysis(parsed, imagePath);
          
          // 添加到历史记录
          try {
            print('=== Starting to add equipment to history ===');
            
            // 确保 HistoryLogic 已初始化并设为永久实例
            HistoryLogic historyLogic;
            if (!Get.isRegistered<HistoryLogic>()) {
              print('HistoryLogic not registered, creating new permanent instance');
              historyLogic = Get.put(HistoryLogic(), permanent: true);
            } else {
              print('HistoryLogic already registered, using existing instance');
              historyLogic = Get.find<HistoryLogic>();
            }
            
            print('HistoryLogic instance: ${historyLogic.hashCode}');
            print('Current history items count before add: ${historyLogic.historyItems.length}');
            
            historyLogic.addEquipment(newEquipment);
            
            print('Current history items count after add: ${historyLogic.historyItems.length}');
            print('=== Equipment added to history successfully ===');
            
          } catch (e, stackTrace) {
            print('=== Error adding to history ===');
            print('Error: $e');
            print('Stack trace: $stackTrace');
            
            // 如果还是失败，强制创建新的永久实例
            try {
              print('Attempting to create new permanent HistoryLogic instance');
              final historyLogic = Get.put(HistoryLogic(), permanent: true);
              historyLogic.addEquipment(newEquipment);
              print('Successfully added to history after creating new permanent logic');
            } catch (e2) {
              print('Failed to add to history even after creating new permanent instance: $e2');
            }
          }

          // 移除任务
          backgroundTasks.remove(taskId);
          // 后台任务完成，允许再次点击
          if (!hasBackgroundTasks) {
            isAnalyzing.value = false;
          }

          // Navigate to detail page
          Get.toNamed(Routes.detail, arguments: newEquipment.toMap());
          return; // 成功完成，退出重试循环
        } else {
          if (retryCount < maxRetries) {
            retryCount++;
            print('Failed to parse analysis result, retrying... (attempt ${retryCount + 1})');
            await Future.delayed(Duration(seconds: retryCount * 2));
            continue;
          }
          _onBackgroundTaskError(taskId, 'Failed to parse analysis result after ${maxRetries + 1} attempts');
          return;
        }
      } catch (e, stackTrace) {
        print('Error in background analysis (attempt ${retryCount + 1}): $e');
        print('Stack trace: $stackTrace');
        
        if (retryCount < maxRetries) {
          retryCount++;
          print('Retrying analysis... (attempt ${retryCount + 1})');
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
        
        _onBackgroundTaskError(taskId, 'Analysis exception after ${maxRetries + 1} attempts: ${e.toString()}');
        return;
      }
    }
  }

  EquipmentModel _createEquipmentFromAnalysis(Map<String, String> parsed, String imagePath) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // 从 parsed 中提取数据
    final safetyScore = int.tryParse(parsed['safety']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
    final conditionScore = int.tryParse(parsed['condition']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
    
    // 根据安全分数判断风险等级
    String riskLevel;
    String type;
    if (safetyScore >= 80) {
      riskLevel = 'Low';
      type = 'Safe';
    } else if (safetyScore >= 60) {
      riskLevel = 'Medium';
      type = 'Warning';
    } else {
      riskLevel = 'High';
      type = 'Critical';
    }

    // 根据条件分数判断状态
    String status;
    if (conditionScore >= 90) {
      status = 'Excellent';
    } else if (conditionScore >= 80) {
      status = 'Great Condition';
    } else if (conditionScore >= 60) {
      status = 'Moderate Wear';
    } else {
      status = 'Critical Wear';
    }

    return EquipmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      equipmentName: parsed['type'] ?? 'Unknown Equipment',
      date: dateStr,
      status: status,
      riskLevel: riskLevel,
      image: imagePath,
      coinsUsed: 50,
      condition: conditionScore,
      safety: safetyScore,
      wearLevel: parsed['wear'] ?? 'Unknown',
      aiAnalysis: parsed['condition'] ?? 'AI analysis completed.',
      type: type,
      issuesFound: _parseIssues(parsed['recommendations'] ?? ''),
      recommendations: _parseRecommendations(parsed['recommendations'] ?? ''),
    );
  }

  List<String> _parseIssues(String text) {
    // 简单解析，可以根据实际返回格式调整
    if (text.isEmpty) return [];
    final parts = text.split(';');
    return parts.take(3).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  List<String> _parseRecommendations(String text) {
    // 简单解析，可以根据实际返回格式调整
    if (text.isEmpty) return ['Regular maintenance recommended'];
    final parts = text.split('.');
    return parts.take(3).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  void _onBackgroundTaskError(String taskId, String message) {
    backgroundTasks.remove(taskId);
    
    // Refund coins for failed analysis
    _coinService.refundCoinsForFailedAnalysis();
    
    // Show error message (coins refund message will be shown by CoinService)
    print('Analysis failed for task $taskId: $message');

    // 任务失败后也需要恢复状态，允许再次点击
    if (!hasBackgroundTasks) {
      isAnalyzing.value = false;
    }
  }

  String? _extractContent(Map<String, dynamic> data) {
    try {
      // 打印完整响应用于调试
      print('GPT API Response: $data');
      
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        print('Error: choices is null or empty');
        return null;
      }
      
      final firstChoice = choices[0] as Map<String, dynamic>?;
      if (firstChoice == null) {
        print('Error: firstChoice is null');
        return null;
      }
      
      // GPT API 返回的是 message 对象，不是直接的 content
      final message = firstChoice['message'] as Map<String, dynamic>?;
      if (message == null) {
        print('Error: message is null');
        return null;
      }
      
      final content = message['content'] as String?;
      print('Extracted content: $content');
      return content;
    } catch (e) {
      print('Error extracting content: $e');
      return null;
    }
  }

  Map<String, String>? _parseSafetyCheckResult(String content) {
    try {
      String jsonStr = content.trim();
      
      print('Original content: $jsonStr');
      
      // 移除 markdown 代码块标记
      if (jsonStr.contains('```json')) {
        final start = jsonStr.indexOf('```json') + 7;
        final end = jsonStr.indexOf('```', start);
        if (end > start) {
          jsonStr = jsonStr.substring(start, end).trim();
        }
      } else if (jsonStr.contains('```')) {
        final start = jsonStr.indexOf('```') + 3;
        final end = jsonStr.indexOf('```', start);
        if (end > start) {
          jsonStr = jsonStr.substring(start, end).trim();
        }
      }

      print('Cleaned JSON string: $jsonStr');

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      print('Decoded map: $map');
      
      // 提取并格式化数据
      final equipmentType = (map['equipment_type'] ?? 'Unknown').toString();
      final conditionSummary = (map['condition_summary'] ?? '-').toString();
      final safetyScore = map['safety_score_percent'] ?? 0;
      final wearLevel = (map['wear_level'] ?? '-').toString();
      
      // 处理 issues
      final issues = map['issues'];
      final issuesStr = issues is List
          ? (issues).map((e) => e.toString()).join('; ')
          : '';

      // 处理 recommendations
      final recommendations = (map['recommendations'] ?? '').toString();

      final result = {
        'type': equipmentType,
        'condition': conditionSummary,
        'safety': '$safetyScore',
        'wear': wearLevel,
        'recommendations': [
          recommendations,
          if (issuesStr.isNotEmpty) 'Issues: $issuesStr',
        ].where((s) => s.isNotEmpty).join(' '),
      };
      
      print('Parsed result: $result');
      return result;
    } catch (e, stackTrace) {
      print('Error parsing safety check result: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// 供 View 展示用：有结果时返回结果，否则返回 null
  Map<String, String>? get resultMap => analysisResult.value;

  /// 检查是否有后台任务正在运行
  bool get hasBackgroundTasks => backgroundTasks.isNotEmpty;

  @override
  void onClose() {
    selectedImagePath.value = null;
    hasImage.value = false;
    isAnalyzing.value = false;
    hasResult.value = false;
    analysisResult.value = null;
    super.onClose();
  }
}
