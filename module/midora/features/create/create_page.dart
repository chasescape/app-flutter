import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/app_controller.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/midora_design.dart';
import '../../core/widgets/midora_open_background.dart';
import '../store/store_page.dart';
import '../../scene_ai/scene_card_ai_service.dart';
import '../../services/coins_manager.dart';
import '../detail/detail_page.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final ImagePicker _imagePicker = ImagePicker();

  bool _isAnalyzing = false;
  File? _selectedImage;
  String? _analysisProgress;
  bool _isShowingInsufficientCoinsDialog = false;

  final int _analysisCost = 35;

  Future<void> _showInsufficientCoinsDialog({required int cost}) async {
    if (_isShowingInsufficientCoinsDialog || !mounted) return;
    _isShowingInsufficientCoinsDialog = true;

    final currentCoins = CoinsManager.I.currentCoins;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Not enough coins'),
          content: Text(
            'This action costs $cost coins, but you only have $currentCoins.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(this.context).push(
                  MaterialPageRoute(builder: (_) => const StorePage()),
                );
              },
              child: const Text('Get Coins'),
            ),
          ],
        );
      },
    );

    _isShowingInsufficientCoinsDialog = false;
  }

  Future<bool> _ensurePhotoPermission() async {
    Permission permission = Permission.photos;
    if (Platform.isAndroid) {
      // Android 13+ maps to READ_MEDIA_IMAGES; older versions fall back to storage.
      final androidInfo = await Permission.photos.status;
      if (androidInfo.isDenied || androidInfo.isRestricted) {
        permission = Permission.photos;
      }
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isDenied || storageStatus.isRestricted) {
        permission = Permission.storage;
      }
    }

    final status = await permission.request();
    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!mounted) return false;

    final shouldOfferSettings = status.isPermanentlyDenied || status.isRestricted;
    Get.snackbar(
      'Permission Needed',
      'Please allow photo access to upload a picture.',
      snackPosition: SnackPosition.BOTTOM,
      mainButton: shouldOfferSettings
          ? TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text('Open Settings'),
            )
          : null,
    );
    return false;
  }

  Future<void> _pickImage() async {
    try {
      final ok = await _ensurePhotoPermission();
      if (!ok) return;

      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _analyzeAndCreateSceneCard() async {
    if (_selectedImage == null) {
      Get.snackbar(
        'No Image',
        'Please select an image first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!CoinsManager.I.isEnough(_analysisCost)) {
      await _showInsufficientCoinsDialog(cost: _analysisCost);
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisProgress = 'Analyzing your photo...';
    });

    try {
      final success = await CoinsManager.I.subCoins(_analysisCost);
      if (!success) {
        throw Exception('Failed to deduct coins');
      }

      setState(() => _analysisProgress = 'Connecting to AI...');
      final sceneCard = await SceneCardAiService.I.analyzeImage(
        _selectedImage!,
        // Store the picked image path so detail/feed pages can render it.
        assetImgPath: _selectedImage!.path,
      );

      await AppController.I.saveSceneCard(sceneCard);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailPage(card: sceneCard)),
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Analysis Failed',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisProgress = null;
        });
      }
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _analysisProgress = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _selectedImage != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MidoraOpenBackground(overlayOpacity: 0.24),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    140,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MidoraTopBar(
                          title: 'Create',
                          subtitle:
                              'Upload one photo and let Midora turn it into a scene.',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        MidoraGlassCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MidoraSectionTitle(
                                title: 'Photo Upload',
                                subtitle: 'A single image is all you need here.',
                              ),
                              const SizedBox(height: AppSpacing.md),
                              GestureDetector(
                                onTap: _isAnalyzing ? null : _pickImage,
                                child: Container(
                                  width: double.infinity,
                                  height: 340,
                                  decoration: BoxDecoration(
                                    borderRadius: AppBorderRadius.borderRadiusXl,
                                    gradient: AppColors.sheetGradient,
                                    border: Border.all(
                                      color: hasImage
                                          ? AppColors.primaryLight
                                          : AppColors.glassBorderStrong,
                                    ),
                                  ),
                                  child: hasImage
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  AppBorderRadius.borderRadiusXl,
                                              child: Image.file(
                                                _selectedImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (!_isAnalyzing)
                                              Positioned(
                                                top: AppSpacing.md,
                                                right: AppSpacing.md,
                                                child: MidoraCircleButton(
                                                  icon: Icons.close_rounded,
                                                  onTap: _clearImage,
                                                  size: 42,
                                                ),
                                              ),
                                          ],
                                        )
                                      : const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_photo_alternate_rounded,
                                              size: 56,
                                              color: AppColors.textSecondary,
                                            ),
                                            SizedBox(height: AppSpacing.md),
                                            Text(
                                              'Tap to upload a photo',
                                              style: AppTextStyles.bodyBold,
                                            ),
                                            SizedBox(height: AppSpacing.xs),
                                            Text(
                                              'We will keep the image front and center.',
                                              style: AppTextStyles.caption,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                hasImage
                                    ? 'Tap the preview if you want to replace the image.'
                                    : 'Choose a clear image from your library to start.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (_analysisProgress != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  _analysisProgress!,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textInverse,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: MidoraPrimaryButton(
                                  label:
                                      hasImage ? 'Generate Scene' : 'Upload Photo',
                                  onTap: _isAnalyzing
                                      ? null
                                      : hasImage
                                          ? _analyzeAndCreateSceneCard
                                          : _pickImage,
                                  isLoading: _isAnalyzing,
                                  leading: Icon(
                                    hasImage
                                        ? Icons.auto_awesome_rounded
                                        : Icons.file_upload_rounded,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildCostCard(
                          icon: Icons.auto_awesome_rounded,
                          text: 'Each AI generation costs $_analysisCost coins',
                          accent: AppColors.info,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostCard({
    required IconData icon,
    required String text,
    required Color accent,
  }) {
    return MidoraGlassCard(
      borderRadius: AppBorderRadius.borderRadiusLg,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: AppBorderRadius.borderRadiusMd,
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textInverse),
            ),
          ),
          CoinsBuilder(
            builder: (coins) => Text(
              '$coins',
              style:
                  AppTextStyles.bodyBold.copyWith(color: AppColors.textInverse),
            ),
          ),
        ],
      ),
    );
  }
}
