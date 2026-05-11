import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:ui';
import 'package:speech_to_text/speech_to_text.dart';

import '../../service/ai_service.dart';
import '../../service/coins_service.dart';
import '../history/history_logic.dart';
import '../details/details_view.dart';

import '../../service/ai_service.dart';
import '../details/details_view.dart';

class GenerateLogic extends GetxController {
  // 选中的分类索引
  int selectedCategoryIndex = 0;

  // 选中的图片
  File? selectedImage;

  // 分类数据 - 使用更美观且不重复的颜色
  final categories = [
    {'icon': Icons.water_drop_outlined, 'label': 'Washing', 'color': Color(0xFF4FC3F7)}, // 清新蓝色
    {'icon': Icons.inventory_2_outlined, 'label': 'Storage', 'color': Color(0xFF9C27B0)}, // 紫色
    {'icon': Icons.layers_outlined, 'label': 'Organization', 'color': Color(0xFF66BB6A)}, // 绿色
    {'icon': Icons.favorite_outline, 'label': 'Care', 'color': Color(0xFFFF6B9D)}, // 粉色
  ];

  final ImagePicker _picker = ImagePicker();
  final TextEditingController descriptionController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool isListening = false;
  bool speechEnabled = false;

  // 选择分类
  void selectCategory(int index) {
    selectedCategoryIndex = index;
    update(); // 使用update()来通知UI更新
  }

  @override
  void onInit() {
    if (!Get.isRegistered<CoinsService>()) {
      Get.put(CoinsService(), permanent: true);
    }
    _coinsService = Get.find<CoinsService>();
    _initSpeech();
    super.onInit();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    _speechToText.stop();
    super.onClose();
  }

  Future<void> _initSpeech() async {
    speechEnabled = await _speechToText.initialize();
    update();
  }

  Future<void> toggleListening() async {
    if (!speechEnabled) return;
    if (isListening) {
      await _speechToText.stop();
      isListening = false;
      update();
    } else {
      await _speechToText.listen(
        onResult: (result) {
          descriptionController.text = result.recognizedWords;
          update();
        },
      );
      isListening = true;
      update();
    }
  }

  // 上传照片
  Future<void> uploadPhoto() async {
    try {
      // 显示选择对话框，权限检查在选择具体来源时进行
      await _showImageSourceDialog();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to access image picker: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 显示图片来源选择对话框
  Future<void> _showImageSourceDialog() async {
    await Get.dialog(
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: 320,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      decoration: TextDecoration.none,
                    ),
                    child: Text('Select Image Source'),
                  ),
                  const SizedBox(height: 12),
                  _SourceTile(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Take a new photo',
                    onTap: () {
                      Get.back();
                      _pickImageWithPermission(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 12),
                  _SourceTile(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    subtitle: 'Choose from library',
                    onTap: () {
                      Get.back();
                      _pickImageWithPermission(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        textStyle: const TextStyle(decoration: TextDecoration.none),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.25),
    );
  }

  // 带权限检查的图片选择
  Future<void> _pickImageWithPermission(ImageSource source) async {
    try {
      Permission permission;
      String permissionName;

      if (source == ImageSource.camera) {
        permission = Permission.camera;
        permissionName = 'camera';
      } else {
        // 对于相册，根据平台选择合适的权限
        if (Platform.isIOS) {
          permission = Permission.photos;
          permissionName = 'photo library';
        } else {
          // Android 13+ 使用新的媒体权限
          permission = Permission.storage;
          permissionName = 'storage';
        }
      }

      // 检查权限状态
      PermissionStatus status = await permission.status;

      if (status.isDenied) {
        // 请求权限
        status = await permission.request();
      }

      if (status.isGranted) {
        // 权限已授予，选择图片
        await _pickImage(source);
      } else if (status.isPermanentlyDenied) {
        // 权限被永久拒绝，引导用户到设置
        Get.dialog(
          AlertDialog(
            title: const Text('Permission Required'),
            content: Text('Please enable $permissionName permission in Settings to use this feature.'),
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
                child: const Text('Settings'),
              ),
            ],
          ),
        );
      } else {
        // 权限被拒绝
        Get.snackbar(
          'Permission Denied',
          'Please grant $permissionName permission to use this feature',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to request permission: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 选择图片
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage = File(image.path);
        update();

        Get.snackbar(
          'Success',
          'Image selected successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  final AiService _aiService = AiService();
  final HistoryLogic _historyLogic = Get.put(HistoryLogic());
  late final CoinsService _coinsService;
  static const int _costPerGenerate = 100;


  // Generate AI care suggestion from selected image
  Future<void> publishPost() async {
    if (selectedImage == null) {
      Get.snackbar(
        'No photo',
        'Please upload a photo first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    await _coinsService.ensureLoaded();

    final canPay = await _coinsService.deduct(_costPerGenerate);
    if (!canPay) {
      Get.snackbar(
        'Not enough coins',
        'You need $_costPerGenerate coins to generate AI tips.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      final AiResult result = await _aiService.generateFromImage(selectedImage!);

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      final imagePath = selectedImage!.path;
      await _historyLogic.addRecord(result, imagePath);
      selectedImage = null;
      update();

      Get.to(
        () => DetailsPage(
          title: result.title,
          subtitle: result.overview,
          progress: 1.0,
          image: imagePath,
          category: result.category,
          overview: result.overview,
          steps: result.steps,
          proTips: result.proTips,
        ),
      );
    } catch (e) {
      // refund coins on failure
      await _coinsService.add(_costPerGenerate);
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        'Error',
        'Failed to generate suggestion: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.6),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}
