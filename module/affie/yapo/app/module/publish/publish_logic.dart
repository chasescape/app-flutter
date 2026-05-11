import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dio/dio.dart' as dio;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapo/yapo/app/data/ai_prompt_config.dart';
import 'package:yapo/yapo/core/network/ai_service.dart';
import 'package:yapo/yapo/env/app_env.dart';
import '../../routes/app_pages.dart';
import '../../services/generated_photo_service.dart';
import 'widgets/insufficient_coins_bottom_sheet.dart';

/// AI 图生图页面逻辑控制器
/// 负责处理图片上传、语音识别、表单验证和 AI 图生图流程
class PublishLogic extends GetxController {
  // ==================== 状态管理 ====================
  
  final selectedImages = <String>[].obs;
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final weatherController = TextEditingController();
  final selectedDate = ''.obs;
  final selectedTime = ''.obs;
  final userCoins = 100.obs;
  final publishCost = 100;
  final isListening = false.obs;
  final isPublishing = false.obs;
  final aiProgress = 0.0.obs;
  final aiStatusText = ''.obs;

  // ==================== 私有变量 ====================
  
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  final ImagePicker _picker = ImagePicker();
  late final dio.Dio _dio;
  late final AiService _aiService;
  
  // SharedPreferences key (与 CoinsLogic 共享)
  static const String _keyUserCoins = 'user_coins';
  
  // 后台生成相关
  String? _currentGeneratingPhotoId;

  // ==================== 计算属性 ====================
  
  bool get canPublish => 
      selectedImages.isNotEmpty && 
      userCoins.value >= publishCost &&
      !isPublishing.value;

  // ==================== 生命周期 ====================
  
  @override
  void onInit() {
    super.onInit();
    _loadUserCoins(); // 加载金币
    _initSpeech();
    _initDio();
    // 确保 GeneratedPhotoService 已初始化
    Get.put(GeneratedPhotoService());
  }

  @override
  void onClose() {
    locationController.dispose();
    descriptionController.dispose();
    weatherController.dispose();
    _speech.stop();
    super.onClose();
  }

  // ==================== 网络初始化 ====================
  
  void _initDio() {
    final env = AppEnv();
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: env.aiApiBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      headers: {
        'Authorization': 'Bearer ${env.aiApiKey}',
      },
    ));
    _aiService = AiService(_dio);
  }

  // ==================== 金币管理 ====================
  
  /// 从本地存储加载用户金币
  Future<void> _loadUserCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCoins = prefs.getInt(_keyUserCoins);
      if (savedCoins != null) {
        userCoins.value = savedCoins;
      }
    } catch (e) {
      // 加载失败，静默处理
    }
  }

  /// 保存用户金币到本地存储
  Future<void> _saveUserCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUserCoins, userCoins.value);
    } catch (e) {
      // 保存失败，静默处理
    }
  }

  // ==================== 语音识别功能 ====================
  
  Future<void> _initSpeech() async {
    try {
      _speech = stt.SpeechToText();
      _speechAvailable = await _speech.initialize(
        onError: (error) {
          isListening.value = false;
          _showErrorSnackbar('语音识别出错', error.errorMsg);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
      );
    } catch (e) {
      _speechAvailable = false;
    }
  }

  Future<void> startListening() async {
    if (!_speechAvailable) {
      _showErrorSnackbar('Error', '语音识别服务不可用');
      return;
    }

    try {
      isListening.value = true;
      await _speech.listen(
        onResult: (result) {
          descriptionController.text = result.recognizedWords;
        },
        localeId: 'en_US',
      );
    } catch (e) {
      isListening.value = false;
      _showErrorSnackbar('Error', '无法启动语音识别');
    }
  }

  Future<void> stopListening() async {
    try {
      isListening.value = false;
      await _speech.stop();
    } catch (e) {
      // Silent fail
    }
  }

  // ==================== 图片处理功能 ====================
  
  /// 检查并请求相册权限
  Future<bool> _requestPhotoPermission() async {
    try {
      final status = await Permission.photos.status;
      
      // iOS 有「限制访问」(limited) 状态，这里一并当作已授权处理
      if (status.isGranted || status.isLimited) {
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.photos.request();
        // 再次判断是否授权或限制授权
        return result.isGranted || result.isLimited;
      }
      
      if (status.isPermanentlyDenied) {
        // 永久拒绝，提示并引导到系统设置
        _showWarningSnackbar('相册权限', '请在系统设置中允许访问相册');
        await openAppSettings();
        return false;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 检查并请求相机权限
  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      
      if (status.isPermanentlyDenied) {
        // 永久拒绝，提示并引导到系统设置
        _showWarningSnackbar('相机权限', '请在系统设置中允许访问相机');
        await openAppSettings();
        return false;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 从相册选择图片（单张）
  Future<void> handleImageUpload() async {
    // 检查并请求权限
    final hasPermission = await _requestPhotoPermission();
    if (!hasPermission) {
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        selectedImages.clear();
        selectedImages.add(image.path);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Unable to access photo album');
    }
  }

  /// 从相机拍照（单张）
  Future<void> handleCameraCapture() async {
    // 检查并请求权限
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        selectedImages.clear();
        selectedImages.add(image.path);
      }
    } catch (e) {
      _showErrorSnackbar('Error', '无法访问相机');
    }
  }

  /// 显示图片来源选择对话框
  Future<void> showImageSourceDialog() async {
    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a0b2e),
                Color(0xFF2d1b4e),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFec4899).withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFec4899).withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFf9a8d4), Color(0xFFec4899)],
                ).createShader(bounds),
                child: const Text(
                  'Choose Photo Source',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 相机按钮
              InkWell(
                onTap: () {
                  Get.back();
                  handleCameraCapture();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFec4899), Color(0xFFa855f7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFec4899).withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Camera',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Take a new photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // 相册按钮
              InkWell(
                onTap: () {
                  Get.back();
                  handleImageUpload();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFec4899).withValues(alpha: 0.15),
                    border: Border.all(
                      color: const Color(0xFFec4899).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFec4899).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_library_rounded,
                          color: Color(0xFFf9a8d4),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Photo Library',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFf9a8d4).withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose from gallery',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFFd8b4fe).withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: const Color(0xFFf9a8d4).withValues(alpha: 0.6),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 取消按钮
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFd8b4fe).withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// 移除图片
  void removeImage() {
    selectedImages.clear();
  }

  // ==================== 日期选择功能 ====================
  
  Future<void> selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFec4899),
                onPrimary: Colors.white,
                surface: Color(0xFF1a0b2e),
                onSurface: Color(0xFFf9a8d4),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        selectedDate.value = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Unable to select date');
    }
  }
  
  Future<void> selectTime(BuildContext context) async {
    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFa855f7),
                onPrimary: Colors.white,
                surface: Color(0xFF1a0b2e),
                onSurface: Color(0xFFd8b4fe),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.hour >= 12 ? 'PM' : 'AM';
        final displayHour = picked.hour > 12 ? picked.hour - 12 : (picked.hour == 0 ? 12 : picked.hour);
        selectedTime.value = '$displayHour:$minute $period';
      }
    } catch (e) {
      _showErrorSnackbar('Error', '无法选择时间');
    }
  }


  // ==================== AI 图生图功能 ====================
  
  Future<String> _callAIImageGeneration(
    String imagePath, {
    String? location,
    String? date,
  }) async {
    try {
      // 如果没有传入参数，则从 controller 读取（兼容旧代码）
      final finalLocation = location ?? 
          (locationController.text.trim().isEmpty 
              ? 'Unknown Location' 
              : locationController.text.trim());
      final finalDate = date ?? 
          (selectedDate.value.isEmpty 
              ? DateTime.now().toString().split(' ')[0] 
              : selectedDate.value);
      
      final prompt = AIPromptConfig.generateEnhancedPrompt(
        location: finalLocation,
        date: finalDate,
        description: '',
      );

      final imageUrl = await _aiService.generateEditedImage(
        imagePath: imagePath,
        prompt: prompt,
      );

      return await _saveGeneratedImage(imageUrl, imagePath);
    } on dio.DioException catch (e) {
      
      String errorMsg = 'Error';
      if (e.type == dio.DioExceptionType.connectionTimeout) {
        errorMsg = 'Connection timeout, please check your network';
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        errorMsg = 'AI generation timed out, please try again';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMsg = 'API Error: ${e.response?.statusCode}';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        errorMsg = 'Unable to connect to server';
      } else if (e.response?.statusCode == 401) {
        errorMsg = 'API key is invalid';
      } else if (e.response?.statusCode == 429) {
        errorMsg = 'Too many API requests, please slow down';
      }
      
      _showErrorSnackbar('Error', errorMsg);
      return imagePath;
    } catch (e, stackTrace) {
      _showErrorSnackbar('Error', 'Failed to process: $e');
      return imagePath;
    }
  }

  /// 保存生成的图片到本地
  Future<String> _saveGeneratedImage(String content, String originalPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'generated_$timestamp.jpg';
      final filePath = '${directory.path}/$fileName';
      
      // 如果 content 是 URL，下载图片
      if (content.startsWith('http')) {
        // 不使用 Dio，改用 HttpClient 避免认证问题
        final httpClient = HttpClient();
        try {
          final request = await httpClient.getUrl(Uri.parse(content));
          final response = await request.close();
          
          if (response.statusCode == 200) {
            final bytes = await consolidateHttpClientResponseBytes(response);
            final file = File(filePath);
            await file.writeAsBytes(bytes);
            return filePath;
          } else {
            // 下载失败，返回原图
            return originalPath;
          }
        } finally {
          httpClient.close();
        }
      } 
      // 如果是 base64，解码并保存
      else if (content.contains('base64,')) {
        final base64String = content.split('base64,').last;
        final bytes = base64Decode(base64String);
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      }
      // 如果 AI 没有返回图片，使用原图
      else {
        return originalPath;
      }
    } catch (e) {
      // 保存失败，返回原图路径
      return originalPath;
    }
  }

  void _updateAIProgress(double progress, String status) {
    aiProgress.value = progress;
    aiStatusText.value = status;
  }

  /// 生成 Story 描述（AI 对图片做了什么处理）
  Future<String> _generateStoryDescription({
    String? location,
    String? date,
    String? userDescription,
  }) async {
    try {
      final env = AppEnv();
      
      // 如果没有传入参数，则从 controller 读取（兼容旧代码）
      final finalLocation = location ?? 
          (locationController.text.trim().isEmpty 
              ? 'Unknown Location' 
              : locationController.text.trim());
      final finalDate = date ?? 
          (selectedDate.value.isEmpty 
              ? DateTime.now().toString().split(' ')[0] 
              : selectedDate.value);
      final finalDescription = userDescription ?? 
          (descriptionController.text.trim().isEmpty 
              ? null 
              : descriptionController.text.trim());
      
      final prompt = AIPromptConfig.generateStoryPrompt(
        location: finalLocation,
        date: finalDate,
        userDescription: finalDescription,
      );

      final story = await _aiService.generateStory(
        prompt: prompt,
        model: env.aiModel,
        temperature: 0.7,
        maxTokens: 200,
      );
      return story;
    } catch (e) {
      // 如果生成失败，返回默认描述
      return 'The AI has enhanced this travel photo with decorative stickers, vintage filters, and scrapbook-style elements, creating a beautiful memory that captures the essence of this journey.';
    }
  }

  // ==================== 发布功能 ====================
  
  Future<void> handlePublish() async {
    // 防抖：如果正在发布，直接返回
    if (isPublishing.value) {
      return;
    }

    if (!_validateForm()) {
      return;
    }

    if (!_checkCoins()) {
      return;
    }

    // 保存表单数据，以便后台生成时使用
    final savedLocation = locationController.text.trim();
    final savedDescription = descriptionController.text.trim();
    final savedWeather = weatherController.text.trim();
    final savedDate = selectedDate.value;
    final savedTime = selectedTime.value;
    final savedImagePath = selectedImages.first;

    try {
      isPublishing.value = true;
      
      // 显示英文生成提示（持久显示）
      _showGeneratingSnackbar();
      
      // 生成唯一 ID（提前生成，以便后台跳转）
      final photoId = 'gen_${DateTime.now().millisecondsSinceEpoch}';
      _currentGeneratingPhotoId = photoId;
      
      // 后台异步生成（不阻塞 UI）
      _generateInBackground(
        photoId: photoId,
        imagePath: savedImagePath,
        location: savedLocation,
        date: savedDate,
        time: savedTime,
        weather: savedWeather,
        description: savedDescription,
      );
      
      // 清空表单，允许用户退出页面
      _clearForm();
      _updateAIProgress(0.0, '');
      
      // 允许用户退出页面，生成在后台继续
      
    } catch (e) {
      _hideGeneratingSnackbar();
      _showErrorSnackbar('Generation Failed', 'Please try again later');
      _updateAIProgress(0.0, '');
      isPublishing.value = false;
    }
  }

  /// 后台生成方法（异步执行，不依赖页面状态）
  Future<void> _generateInBackground({
    required String photoId,
    required String imagePath,
    required String location,
    required String date,
    required String time,
    required String weather,
    required String description,
  }) async {
    try {
      _updateAIProgress(0.2, 'Preparing image...');
      await Future.delayed(const Duration(milliseconds: 500));

      _updateAIProgress(0.4, 'AI is analyzing image...');
      
      final generatedImagePath = await _callAIImageGeneration(
        imagePath,
        location: location,
        date: date,
      );

      _updateAIProgress(0.6, 'AI is generating description...');
      
      // 生成 Story 描述（AI 对图片做了什么处理）
      final storyDescription = await _generateStoryDescription(
        location: location,
        date: date,
        userDescription: description.isEmpty ? null : description,
      );
      
      _updateAIProgress(0.8, 'Saving results...');
      
      // 保存到本地历史（使用生成的图片路径）
      final photoService = Get.find<GeneratedPhotoService>();
      await photoService.saveGeneratedPhoto(
        id: photoId,
        imagePath: generatedImagePath,
        title: location.isEmpty ? 'AI Travel Memory' : '$location Journey',
        location: location.isEmpty ? 'Unknown Location' : location,
        date: date.isEmpty ? DateTime.now().toString().split(' ')[0] : date,
        description: storyDescription,
        time: time.isEmpty 
            ? DateTime.now().toString().split(' ')[1].substring(0, 5)
            : time,
        weather: weather.isEmpty ? 'Clear Sky' : weather,
        tags: _generateTagsFromLocation(location),
        highlights: ['AI Generated', 'Travel Album', 'Personalized Design'],
      );

      await Future.delayed(const Duration(milliseconds: 500));

      // 扣除金币
      userCoins.value -= publishCost;
      await _saveUserCoins();

      _updateAIProgress(1.0, 'Generation complete!');
      await Future.delayed(const Duration(milliseconds: 300));

      // 隐藏生成提示
      _hideGeneratingSnackbar();

      // 无论用户在哪个页面，都跳转到详情页
      Get.toNamed(Routes.details, arguments: photoId);
      
      // 显示成功提示
      _showSuccessSnackbar(
        'Generation Complete',
        'Your travel memory has been created!',
      );
      
    } catch (e) {
      _hideGeneratingSnackbar();
      _showErrorSnackbar('Generation Failed', 'Please try again later');
    } finally {
      isPublishing.value = false;
      _currentGeneratingPhotoId = null;
      _updateAIProgress(0.0, '');
    }
  }

  /// 显示生成中的提示（英文）
  void _showGeneratingSnackbar() {
    Get.snackbar(
      'Generating...',
      'Your memory is being created. You can leave this page.',
      backgroundColor: const Color(0xFF9333ea),
      colorText: Colors.white,
      icon: const Icon(Icons.auto_awesome, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(minutes: 10), // 设置较长的持续时间
      isDismissible: false, // 不允许手动关闭
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      mainButton: TextButton(
        onPressed: null,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  /// 隐藏生成中的提示
  void _hideGeneratingSnackbar() {
    Get.closeAllSnackbars();
  }

  /// 根据位置生成标签
  List<String> _generateTagsFromLocation(String location) {
    final tags = <String>['#AIGenerated', '#TravelMemory'];
    if (location.isNotEmpty) {
      tags.add('#${location.replaceAll(' ', '')}');
    }
    return tags;
  }

  /// 生成标题
  String _generateTitle() {
    final location = locationController.text.trim();
    if (location.isEmpty) {
      return 'AI Travel Memory';
    }
    return '$location Journey';
  }

  /// 生成标签
  List<String> _generateTags() {
    final tags = <String>['#AIGenerated', '#TravelMemory'];
    final location = locationController.text.trim();
    if (location.isNotEmpty) {
      tags.add('#${location.replaceAll(' ', '')}');
    }
    return tags;
  }

  // ==================== 私有辅助方法 ====================
  
  bool _validateForm() {
    if (selectedImages.isEmpty) {
      _showWarningSnackbar('Tips', 'Please upload at least one photo.');
      return false;
    }
    return true;
  }

  bool _checkCoins() {
    if (userCoins.value < publishCost) {
      InsufficientCoinsBottomSheet.show(
        currentCoins: userCoins.value,
        requiredCoins: publishCost,
      );
      return false;
    }
    return true;
  }

  void _clearForm() {
    selectedImages.clear();
    locationController.clear();
    descriptionController.clear();
    weatherController.clear();
    selectedDate.value = '';
    selectedTime.value = '';
  }

  // ==================== UI 反馈方法 ====================
  
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFFef4444),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFFfbbf24),
      colorText: Colors.white,
      icon: const Icon(Icons.warning_amber, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFF10b981),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
