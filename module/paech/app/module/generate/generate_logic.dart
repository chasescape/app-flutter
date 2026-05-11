import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../history/history_logic.dart';

enum Language {
  english,
  chinese,
  spanish,
  french,
}

enum Style {
  professional,
  casual,
  elegant,
  creative,
}

class GenerateLogic extends GetxController {
  // 金币余额（实际应该从服务器或本地存储获取）
  final RxInt credits = 0.obs;

  // 免费生成次数（前3次免费）
  final RxInt freeGenerations = 1.obs;

  // 每次生成消耗的金币数（免费次数用完后，每次生成消耗100个金币）
  static const int costPerGeneration = 100;
  
  // 免费生成次数上限
  static const int freeGenerationLimit = 1;

  // 当前选择的图片
  final Rx<File?> selectedImage = Rx<File?>(null);

  // 选择的语言
  final Rx<Language?> selectedLanguage = Rx<Language?>(null);

  // 选择的风格
  final Rx<Style?> selectedStyle = Rx<Style?>(null);

  // 是否正在生成
  final RxBool isGenerating = false.obs;

  // 生成结果（故事数据）
  final Rx<Map<String, dynamic>?> generatedStory =
      Rx<Map<String, dynamic>?>(null);

  // 错误信息
  final RxString errorMessage = ''.obs;

  final ImagePicker _imagePicker = ImagePicker();

  // AI 服务配置
  static const String _apiBaseUrl = 'https://api.gpt.ge';
  static const String _apiKey =
      'sk-b0pCUwaHv89vrIP54d57Bc8eAb8b4eAeB7C8000aCc0dB844';
  static const String _model = 'gpt-4o-2024-05-13';

  late final dio.Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _initDio();
    _loadCredits();
  }

  /// 初始化 Dio
  void _initDio() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
    ));
  }

  /// 本地存储 key（退出登录不清理，避免「退出再登录」导致免费次数被刷新）
  static const String _keyFreeGenerations = 'generate_free_generations';
  static const String _keyCredits = 'generate_credits';

  /// 从本地存储加载金币余额和免费次数（有则用已存值，无则用初始值，退出再登录不会重置）
  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFree = prefs.getInt(_keyFreeGenerations);
    final savedCredits = prefs.getInt(_keyCredits);
    if (savedFree != null) {
      freeGenerations.value = savedFree;
    } else {
      freeGenerations.value = freeGenerationLimit;
    }
    if (savedCredits != null) {
      credits.value = savedCredits;
    } else {
      credits.value = 0;
    }
    debugPrint('_loadCredits: free=${freeGenerations.value}, credits=${credits.value}');
  }

  /// 保存金币余额和免费次数到本地存储
  Future<void> _saveCredits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFreeGenerations, freeGenerations.value);
    await prefs.setInt(_keyCredits, credits.value);
    debugPrint('_saveCredits: free=${freeGenerations.value}, credits=${credits.value}');
  }

  /// 检查是否有免费次数
  bool hasFreeGenerations() {
    return freeGenerations.value > 0;
  }

  /// 检查是否有足够的金币（当免费次数用完后）
  bool hasEnoughCredits() {
    // 如果还有免费次数，不需要检查金币
    if (hasFreeGenerations()) {
      return true;
    }
    // 免费次数用完后，需要检查金币是否足够
    return credits.value >= costPerGeneration;
  }

  /// 获取显示文本（区分免费次数和金币）
  String get creditsDisplayText {
    // 如果还有免费次数，显示免费次数
    if (freeGenerations.value > 0) {
      return '$freeGenerations';
    }
    // 免费次数用完后，显示金币数量
    return '${credits.value}';
  }
  
  /// 获取显示类型（用于判断显示单位）
  bool get isFreeGenerationMode {
    return freeGenerations.value > 0;
  }

  /// 从充值页面更新金币余额（当购买成功后调用）
  void updateCredits(int newCredits) {
    credits.value = newCredits;
    _saveCredits();
  }

  /// 增加金币（购买成功后调用）
  void addCredits(int amount) {
    credits.value += amount;
    _saveCredits();
  }
  
  /// 增加免费次数（如果需要）
  void addFreeGenerations(int amount) {
    freeGenerations.value += amount;
    _saveCredits();
  }

  /// 步骤1: 从相机拍照
  Future<void> takePhoto() async {
    try {
      errorMessage.value = '';
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        debugPrint('Image selected from camera: ${image.path}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to take photo: $e';
      Get.snackbar(
        'Camera Error',
        'Unable to access camera. Please check permissions.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
      );
    }
  }

  /// 步骤1: 从相册选择图片
  Future<void> pickImageFromGallery() async {
    try {
      errorMessage.value = '';
      // 先检查并请求相册权限（系统弹窗由 permission_handler 触发）
      final hasPermission = await _ensureGalleryPermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission Required',
          'Photo access is required to select images from your gallery.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF2D2A26),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        debugPrint('Image selected from gallery: ${image.path}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
      Get.snackbar(
        'Gallery Error',
        'Unable to access gallery. Please check permissions.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
      );
    }
  }

  /// 检查并请求相册/照片权限，触发系统权限弹窗
  Future<bool> _ensureGalleryPermission() async {
    // iOS 优先使用 photos 权限；Android 13+ 也支持 photos，旧版本回落到 storage
    PermissionStatus status = await Permission.photos.status;

    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      return true;
    }

    // 对部分 Android 设备，可能需要存储权限
    if (!status.isPermanentlyDenied && !status.isRestricted) {
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }
    }

    return false;
  }

  /// 步骤2: 选择语言
  void selectLanguage(Language language) {
    selectedLanguage.value = language;
    debugPrint('Language selected: $language');
  }

  /// 步骤2: 选择风格
  void selectStyle(Style style) {
    selectedStyle.value = style;
    debugPrint('Style selected: $style');
  }

  /// 检查是否可以生成（只需要有图片即可）
  bool canGenerate() {
    return selectedImage.value != null && !isGenerating.value;
  }

  /// 步骤3: 开始生成
  Future<void> startGeneration() async {
    if (!canGenerate()) {
      if (selectedImage.value == null) {
        Get.snackbar(
          'Missing Image',
          'Please select an image first.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF2D2A26),
          colorText: Colors.white,
        );
        return;
      }
      return;
    }

    // 检查是否有免费次数或足够的金币
    if (!hasEnoughCredits()) {
      Get.snackbar(
        'Insufficient Credits',
        'You need $costPerGeneration coins to generate. Current: ${credits.value} coins',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/deposit'),
          child: const Text(
            'Top Up',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    // 开始生成
    isGenerating.value = true;
    errorMessage.value = '';
    generatedStory.value = null;

    try {
      debugPrint('Starting AI generation...');
      debugPrint('Image: ${selectedImage.value?.path}');

      // 1. 将图片转换为 Base64
      final base64Image = await _imageToBase64(selectedImage.value!);
      debugPrint('Image converted to Base64, length: ${base64Image.length}');

      // 2. 调用 AI API 生成故事
      final storyData = await _generateStoryFromImage(base64Image);

      // 3. 保存生成结果
      generatedStory.value = storyData;

      debugPrint('Generation completed. Story data saved.');

      // 4. 跳转到结果页面（在跳转成功后再扣除，避免错误时吞掉次数）
      await _navigateToResult();

      // 5. 扣除免费次数或金币（在成功跳转后扣除，确保不会因为跳转错误而吞掉次数）
      if (freeGenerations.value > 0) {
        // 如果还有免费次数，扣除免费次数
        freeGenerations.value -= 1;
        debugPrint('Free generation used. Free generations remaining: ${freeGenerations.value}');
      } else {
        // 免费次数用完后，扣除金币
        credits.value -= costPerGeneration;
        debugPrint('Credits deducted: $costPerGeneration. Credits remaining: ${credits.value}');
      }
      await _saveCredits();
    } catch (e) {
      errorMessage.value = 'Generation failed: $e';
      debugPrint('Generation error: $e');
      Get.snackbar(
        'Generation Failed',
        'Unable to generate story. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isGenerating.value = false;
    }
  }

  /// 将图片转换为 Base64
  Future<String> _imageToBase64(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      throw Exception('Failed to convert image to Base64: $e');
    }
  }

  /// 获取穿搭分析提示词
  String _getStoryPrompt() {
    return '''You are a fashion expert and clothing care specialist with deep knowledge of fabrics, styles, and garment maintenance. Analyze the uploaded clothing photo and provide detailed outfit analysis and care instructions.

**Analysis Guidelines:**
- Identify the clothing items, fabrics, colors, and styles visible in the photo
- Analyze the outfit composition, coordination, and overall aesthetic
- Consider the garment types, materials, and construction details
- Assess the care requirements based on fabric types and garment features

**Response Requirements:**
- Provide a comprehensive outfit analysis (200-400 words)
- Include specific care instructions for each garment type
- Mention fabric types, washing methods, and storage recommendations
- Give styling tips and outfit coordination advice
- Make the analysis practical, detailed, and helpful

**Response Format:**
Return ONLY a valid JSON object with the following exact structure (no additional text or code blocks):
{
  "title": "Outfit Analysis Title (e.g., 'Casual Chic Ensemble' or 'Professional Workwear Look')",
  "outfit_description": "Detailed description of the outfit, including items, colors, styles, and overall aesthetic",
  "garment_types": ["Item1", "Item2", "Item3"],
  "fabric_analysis": "Analysis of visible fabrics and materials",
  "care_instructions": "Complete care guide with washing, drying, ironing, and storage tips",
  "styling_tips": "Tips for styling and coordinating this outfit",
  "style_category": "Style category (e.g., Casual, Professional, Elegant, Streetwear, Vintage)",
  "color_palette": "Color analysis and palette description"
}

**Style Guidelines:**
- Be specific about garment types and fabrics
- Provide actionable care instructions
- Include practical styling advice
- Use clear, professional language
- Focus on practical information

**Important:**
- Base the analysis on visible clothing in the photo
- Provide accurate care instructions based on fabric types
- Give specific, actionable advice
- Return ONLY valid JSON - no descriptive text or formatting''';
  }

  /// 调用 AI API 生成
  Future<Map<String, dynamic>> _generateStoryFromImage(
      String base64Image) async {
    try {
      final requestData = {
        "model": _model,
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": _getStoryPrompt(),
              },
              {
                "type": "image_url",
                "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
              }
            ]
          }
        ],
        "max_tokens": 2000,
        "temperature": 0.8,
      };

      debugPrint('Calling AI API: $_apiBaseUrl/v1/chat/completions');

      final response = await _dio.post(
        '/v1/chat/completions',
        data: requestData,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );

      debugPrint('AI API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 解析响应
        final responseData = response.data as Map<String, dynamic>;
        final choices = responseData['choices'] as List;

        if (choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>;
          final content = message['content'] as String;

          // 解析 JSON 内容
          final storyData = _parseStoryResponse(content);
          return storyData;
        } else {
          throw Exception('No response from AI API');
        }
      } else {
        throw Exception('AI API returned status code: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      if (e.response != null) {
        debugPrint('Response data: ${e.response?.data}');
        throw Exception(
            'AI API error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error generating story: $e');
      rethrow;
    }
  }

  /// 解析故事响应内容
  Map<String, dynamic> _parseStoryResponse(String content) {
    try {
      String jsonString = content.trim();

      // 处理代码块格式（```json ... ```）
      if (jsonString.contains('```json')) {
        final jsonStart = jsonString.indexOf('```json') + 7;
        final jsonEnd = jsonString.indexOf('```', jsonStart);
        if (jsonEnd != -1) {
          jsonString = jsonString.substring(jsonStart, jsonEnd).trim();
        }
      } else if (jsonString.contains('```')) {
        // 处理普通代码块（``` ... ```）
        final jsonStart = jsonString.indexOf('```') + 3;
        final jsonEnd = jsonString.indexOf('```', jsonStart);
        if (jsonEnd != -1) {
          jsonString = jsonString.substring(jsonStart, jsonEnd).trim();
        }
      }

      // 尝试提取 JSON 对象
      if (!jsonString.startsWith('{')) {
        final startIndex = jsonString.indexOf('{');
        if (startIndex != -1) {
          final endIndex = jsonString.lastIndexOf('}');
          if (endIndex != -1 && endIndex > startIndex) {
            jsonString = jsonString.substring(startIndex, endIndex + 1);
          }
        }
      }

      // 解析 JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 返回标准化的穿搭分析数据
      return {
        'title': jsonData['title'] ?? 'Outfit Analysis',
        'outfit_description': jsonData['outfit_description'] ?? '',
        'garment_types': jsonData['garment_types'] is List
            ? List<String>.from(jsonData['garment_types'])
            : <String>[],
        'fabric_analysis': jsonData['fabric_analysis'] ?? '',
        'care_instructions': jsonData['care_instructions'] ?? '',
        'styling_tips': jsonData['styling_tips'] ?? '',
        'style_category': jsonData['style_category'] ?? 'Casual',
        'color_palette': jsonData['color_palette'] ?? '',
      };
    } catch (e) {
      debugPrint('Failed to parse story response: $e');
      debugPrint('Content: $content');

      // 降级处理：返回默认穿搭分析结构
      return {
        'title': 'Outfit Analysis',
        'outfit_description': content, // 使用原始内容作为描述
        'garment_types': <String>[],
        'fabric_analysis': '',
        'care_instructions': '',
        'styling_tips': '',
        'style_category': 'Casual',
        'color_palette': '',
      };
    }
  }

  /// 跳转到结果页面
  Future<void> _navigateToResult() async {
    final story = generatedStory.value;
    if (story == null) {
      debugPrint('No story data to navigate');
      return;
    }

    final title = story['title'] ?? 'Outfit Analysis';
    final description = story['outfit_description'] ?? '';
    final imagePath = selectedImage.value?.path;
    final tips = _convertOutfitToTips(story);

    // 保存到历史记录（异步）
    await _saveToHistory(
      title: title,
      subtitle: description,
      imagePath: imagePath,
      tips: tips,
    );

    // 跳转到详情页，传递穿搭分析数据
    Get.toNamed(
      '/details',
      arguments: {
        'imagePath': imagePath,
        'title': title,
        'description': description,
        'tips': tips,
      },
    );

    // 重置状态
    selectedImage.value = null;
  }

  /// 保存生成结果到历史记录
  Future<void> _saveToHistory({
    required String title,
    required String subtitle,
    required String? imagePath,
    required List<Map<String, String>> tips,
  }) async {
    try {
      // 使用 Get.put 确保 HistoryLogic 已注册
      final historyLogic = Get.put(HistoryLogic());
      
      // 调用异步方法保存历史记录（内部会等待初始化完成）
      await historyLogic.addHistoryEntry(
        title: title,
        subtitle: subtitle,
        imagePath: imagePath,
        tips: tips,
      );
      debugPrint('✅ Successfully saved generation result to history: $title');
    } catch (e) {
      debugPrint('❌ Error saving to history: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  /// 将穿搭分析数据转换为 tips 格式
  List<Map<String, String>> _convertOutfitToTips(Map<String, dynamic> outfit) {
    final tips = <Map<String, String>>[];

    // 1. 穿搭描述卡片
    final descriptionCard = <String, String>{
      'title': outfit['title'] as String? ?? 'Outfit Analysis',
      'subtitle': outfit['style_category'] as String? ?? 'Casual',
      'cardTitle': 'Outfit Description',
      'cardSubtitle':
          '${outfit['style_category'] ?? 'Casual'} • ${outfit['color_palette'] ?? 'Color Analysis'}',
    };

    // 将描述文本按段落分割
    final description = outfit['outfit_description'] as String? ?? '';
    final paragraphs =
        description.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    for (int i = 0; i < paragraphs.length && i < 10; i++) {
      descriptionCard['instruction${i + 1}'] = paragraphs[i].trim();
    }
    tips.add(descriptionCard);

    // 2. 保养说明卡片
    final careInstructionsRaw = outfit['care_instructions'];
    final careInstructions = _safeStringConvert(careInstructionsRaw);
    if (careInstructions.isNotEmpty) {
      final careCard = <String, String>{
        'title': 'Care Instructions',
        'subtitle': 'How to maintain your outfit',
        'cardTitle': 'Care Instructions',
        'cardSubtitle': 'Washing, drying, and storage tips',
      };

      // 将保养说明按行或段落分割
      final careLines = careInstructions
          .split(RegExp(r'\n+|\. '))
          .where((l) => l.trim().isNotEmpty)
          .toList();
      for (int i = 0; i < careLines.length && i < 10; i++) {
        careCard['instruction${i + 1}'] =
            careLines[i].trim().replaceAll(RegExp(r'^\d+[\.\)]\s*'), '');
      }

      tips.add(careCard);
    }

    // 3. 面料分析卡片
    final fabricAnalysisRaw = outfit['fabric_analysis'];
    final fabricAnalysis = _safeStringConvert(fabricAnalysisRaw);
    if (fabricAnalysis.isNotEmpty) {
      final fabricCard = <String, String>{
        'title': 'Fabric Analysis',
        'subtitle': 'Material and texture details',
        'cardTitle': 'Fabric Analysis',
        'cardSubtitle': 'Material composition and characteristics',
      };

      final fabricLines = fabricAnalysis
          .split(RegExp(r'\n+|\. '))
          .where((l) => l.trim().isNotEmpty)
          .toList();
      for (int i = 0; i < fabricLines.length && i < 10; i++) {
        fabricCard['instruction${i + 1}'] = fabricLines[i].trim();
      }

      tips.add(fabricCard);
    }

    // 4. 搭配建议卡片
    final stylingTipsRaw = outfit['styling_tips'];
    final stylingTips = _safeStringConvert(stylingTipsRaw);
    if (stylingTips.isNotEmpty) {
      final stylingCard = <String, String>{
        'title': 'Styling Tips',
        'subtitle': 'How to style this outfit',
        'cardTitle': 'Styling Tips',
        'cardSubtitle': 'Coordination and styling advice',
      };

      final stylingLines = stylingTips
          .split(RegExp(r'\n+|\. '))
          .where((l) => l.trim().isNotEmpty)
          .toList();
      for (int i = 0; i < stylingLines.length && i < 10; i++) {
        stylingCard['instruction${i + 1}'] = stylingLines[i].trim();
      }

      tips.add(stylingCard);
    }

    // 5. 服装类型卡片
    final garmentTypes = outfit['garment_types'] as List<dynamic>?;
    if (garmentTypes != null && garmentTypes.isNotEmpty) {
      final garmentCard = <String, String>{
        'title': 'Garment Types',
        'subtitle': 'Items in this outfit',
        'cardTitle': 'Garment Types',
        'cardSubtitle': 'Clothing items identified',
      };

      for (int i = 0; i < garmentTypes.length && i < 10; i++) {
        garmentCard['instruction${i + 1}'] = garmentTypes[i].toString();
      }

      tips.add(garmentCard);
    }

    return tips;
  }

  /// 安全地将各种类型转换为字符串
  String _safeStringConvert(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value;
    }
    if (value is Map) {
      // 如果是 Map，尝试转换为 JSON 字符串，或者提取文本内容
      try {
        return value.toString();
      } catch (e) {
        return '';
      }
    }
    if (value is List) {
      // 如果是 List，用换行符连接
      return value.map((e) => e.toString()).join('\n');
    }
    // 其他类型直接转换为字符串
    return value.toString();
  }

  /// 重置所有选择
  void reset() {
    selectedImage.value = null;
    generatedStory.value = null;
    errorMessage.value = '';
  }
}
