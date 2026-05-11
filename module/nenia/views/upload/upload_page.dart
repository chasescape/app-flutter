import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/global_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../routes/app_pages.dart';
import '../../services/coins_manager.dart';
import '../../style_ai/style_analysis_ai_service.dart';
import '../../style_ai/style_analysis_storage.dart';
import '../../widgets/common/soft_ui.dart';

class UploadController extends GetxController {
  static const int analysisCost = 99;
  static const String analysisCostHint = 'Each analysis costs 99 coins.';
  static const String insufficientCoinsMessage =
      'Each AI analysis costs 99 coins. Please top up and try again.';

  final GlobalController _globalController = GlobalController.to;
  final StyleAnalysisAiService _analysisService = StyleAnalysisAiService();
  final ImagePicker _picker = ImagePicker();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isAnalyzing = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> pickImageFromGallery() async {
    final hasPermission = await _ensurePermission(
      Permission.photos,
      deniedMessage:
          'Please allow photo access so you can choose an image to analyze.',
      settingsMessage:
          'Photo access is disabled. Please enable Photos permission in Settings.',
    );
    if (!hasPermission) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image: $e';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> pickImageFromCamera() async {
    final hasPermission = await _ensurePermission(
      Permission.camera,
      deniedMessage: 'Please allow camera access so you can take a portrait.',
      settingsMessage:
          'Camera access is disabled. Please enable Camera permission in Settings.',
    );
    if (!hasPermission) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to take photo: $e';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> analyzeImage() async {
    if (selectedImage.value == null) {
      errorMessage.value = 'Please select an image first';
      Get.snackbar('Notice', errorMessage.value);
      return;
    }

    if (!await _ensureEnoughCoins()) {
      return;
    }

    isAnalyzing.value = true;
    errorMessage.value = '';

    try {
      final selectedFile = selectedImage.value!;
      final analysis = await _analysisService.analyzeImage(selectedFile);
      await _globalController.updateCoins(-analysisCost);

      final savedItem = await StyleAnalysisStorage.save(
        analysis,
        imagePath: selectedFile.path,
      );
      final savedAnalysis = savedItem.data;
      savedAnalysis.assetImg = savedItem.imagePath ?? selectedFile.path;

      await _globalController.refreshStyleAnalysisHistory();
      Get.back();
      Routes.toDetail(savedAnalysis);
      Get.snackbar(
        'Success',
        'Style analysis completed. $analysisCost coins deducted.',
      );
    } on StyleAnalysisAiException catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Analysis Failed', e.message);
    } on Exception catch (e) {
      if (e.toString().contains('Insufficient coins')) {
        errorMessage.value = 'You need $analysisCost coins to analyze one photo.';
        await _showInsufficientCoinsDialog();
      } else {
        errorMessage.value = 'Unexpected error: $e';
        Get.snackbar('Error', 'An unexpected error occurred');
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isAnalyzing.value = false;
    }
  }

  void clearImage() {
    selectedImage.value = null;
    errorMessage.value = '';
  }

  void goToHistory() {
    Routes.toAnalysisHistory();
  }

  void goToHome() {
    Get.offAllNamed(Routes.main);
  }

  Future<bool> _ensureEnoughCoins() async {
    if (CoinsManager.to.isEnough(analysisCost)) {
      return true;
    }

    errorMessage.value = 'You need $analysisCost coins to analyze one photo.';
    await _showInsufficientCoinsDialog();
    return false;
  }

  Future<void> _showInsufficientCoinsDialog() async {
    await Get.dialog<void>(
      AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: const Text('Not enough coins', style: AppTextStyles.h3),
        content: const Text(
          insufficientCoinsMessage,
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              Routes.toCoinStore();
            },
            child: const Text('Get coins'),
          ),
        ],
      ),
    );
  }

  Future<bool> _ensurePermission(
    Permission permission, {
    required String deniedMessage,
    required String settingsMessage,
  }) async {
    var status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showPermissionSettingsPrompt(settingsMessage);
      return false;
    }

    status = await permission.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showPermissionSettingsPrompt(settingsMessage);
      return false;
    }

    Get.snackbar('Permission needed', deniedMessage);
    return false;
  }

  Future<void> _showPermissionSettingsPrompt(String message) async {
    await Get.dialog<void>(
      AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: const Text('Permission needed', style: AppTextStyles.h3),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Not now')),
          FilledButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _analysisService.dispose();
    super.onClose();
  }
}

class UploadPage extends GetView<UploadController> {
  const UploadPage({super.key});

  Future<void> _showImageSourceSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: AppBorderRadius.allXl,
                border: Border.all(color: AppColors.lineSoft),
                boxShadow: AppShadows.lg,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Choose your photo', style: AppTextStyles.h3),
                    const SizedBox(height: 6),
                    Text(
                      'Pick the source below and we will place it into the card.',
                      style: AppTextStyles.caption.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    _ImageSourceTile(
                      icon: Icons.camera_alt_rounded,
                      title: 'Take photo',
                      subtitle: 'Open the camera and snap a portrait.',
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await controller.pickImageFromCamera();
                      },
                    ),
                    const SizedBox(height: 12),
                    _ImageSourceTile(
                      icon: Icons.photo_library_outlined,
                      title: 'Choose from photos',
                      subtitle: 'Select an existing image from your gallery.',
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        await controller.pickImageFromGallery();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(UploadController());
    final samples = allStyleMockData.take(3).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NeniaBackdrop(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeniaInlineHeader(
                    title: 'Upload',
                    subtitle: 'Prepare a clean portrait for style analysis.',
                    onBack: controller.goToHome,
                    trailing: NeniaCircleButton(
                      icon: Icons.history_rounded,
                      onTap: controller.goToHistory,
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeniaSurface(
                    radius: 32,
                    gradient: AppColors.spotlightGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NeniaPageHeader(
                          label: 'Upload',
                          title: 'Prepare a clean photo for the soft-card feed',
                          subtitle:
                              'Portraits with open framing work best because the detail page now keeps text off the image.',
                        ),
                        const SizedBox(height: 18),
                        _buildReferenceCollage(samples),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildImageArea(context),
                  const SizedBox(height: 16),
                  _buildAnalyzeButton(),
                  if (controller.errorMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildErrorBubble(controller.errorMessage.value),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea(BuildContext context) {
    final image = controller.selectedImage.value;
    final isAnalyzing = controller.isAnalyzing.value;
    if (image == null) {
      return GestureDetector(
        onTap: isAnalyzing ? null : () => _showImageSourceSheet(context),
        child: NeniaSurface(
          radius: 30,
          child: SizedBox(
            height: 360,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    gradient: AppColors.candyGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_a_photo_outlined,
                      size: 42, color: AppColors.textInverse),
                ),
                const SizedBox(height: 22),
                const Text('Tap to add one portrait', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                const Text(
                  'Choose camera or gallery from the sheet below. Front-facing images with more room around the face work best.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isAnalyzing ? null : () => _showImageSourceSheet(context),
      child: NeniaSurface(
        padding: const EdgeInsets.all(10),
        radius: 30,
        child: ClipRRect(
          borderRadius: AppBorderRadius.allLg,
          child: Stack(
            children: [
              SizedBox(
                height: 460,
                width: double.infinity,
                child: Image.file(image, fit: BoxFit.cover),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.46),
                    borderRadius: AppBorderRadius.allMd,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          size: 18,
                          color: AppColors.textInverse,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap the card to switch photo',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: NeniaCircleButton(
                  icon: Icons.close_rounded,
                  onTap: controller.clearImage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBubble(String rawMessage) {
    final message = _friendlyErrorMessage(rawMessage);
    final status = _extractStatus(rawMessage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F5),
        borderRadius: AppBorderRadius.allLg,
        border: Border.all(color: const Color(0xFFFFD4DB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE4E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis unavailable',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Status: $status',
                    style: AppTextStyles.small.copyWith(color: AppColors.error),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyErrorMessage(String rawMessage) {
    final normalized = rawMessage.toLowerCase();
    if (normalized.contains('api key') || normalized.contains('401')) {
      return 'We could not connect to the analysis service. Please check the API key configuration and try again.';
    }
    if (normalized.contains('network') || normalized.contains('socket')) {
      return 'We could not reach the analysis service. Please check your connection and try again.';
    }
    if (normalized.contains('select an image first')) {
      return 'Please choose a photo before starting the analysis.';
    }
    return 'Something went wrong while analyzing this photo. Please try again in a moment.';
  }

  String? _extractStatus(String rawMessage) {
    final match =
        RegExp(r'status:\s*(\d+)', caseSensitive: false).firstMatch(rawMessage);
    return match?.group(1);
  }

  Widget _buildReferenceCollage(List<dynamic> samples) {
    if (samples.length < 3) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 144,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _buildReferenceImage(
              samples[0].assetImg,
              radius: BorderRadius.circular(26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: _buildReferenceImage(
                    samples[1].assetImg,
                    radius: BorderRadius.circular(22),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _buildReferenceImage(
                    samples[2].assetImg,
                    radius: BorderRadius.circular(22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceImage(
    String path, {
    required BorderRadius radius,
  }) {
    return ClipRRect(
      borderRadius: radius,
      child: NeniaAdaptiveImage(
        path: path,
        borderRadius: radius,
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Obx(() {
      final hasImage = controller.selectedImage.value != null;
      final isAnalyzing = controller.isAnalyzing.value;
      return Column(
        children: [
          NeniaPrimaryButton(
            label: isAnalyzing
                ? 'Analyzing...'
                : hasImage
                    ? 'Analyze style'
                    : 'Select a photo to analyze',
            onPressed:
                hasImage && !isAnalyzing ? controller.analyzeImage : null,
            trailingIcon: isAnalyzing
                ? Icons.hourglass_top_rounded
                : Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary.withValues(alpha: 0.88),
              borderRadius: AppBorderRadius.allLg,
              border: Border.all(color: AppColors.lineSoft),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    gradient: AppColors.candyGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.toll_rounded,
                    size: 16,
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    UploadController.analysisCostHint,
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.allMd,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary.withValues(alpha: 0.92),
            borderRadius: AppBorderRadius.allMd,
            border: Border.all(color: AppColors.lineSoft),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: AppColors.candyGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.textInverse),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
