import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_constants.dart';
import 'package:zeria/zeria/constants/app_routes.dart';
import 'package:zeria/zeria/constants/app_strings.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/env/app_env.dart';
import 'package:zeria/zeria/services/app_service.dart';
import 'package:zeria/zeria/services/coins_manager.dart';
import 'package:zeria/zeria/services/spark_flow_ai_service.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final AppService _appService = AppService.to;
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _analysisStage;

  void _showSnack(
    String title,
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    // Create page: suppress snackbars per product request.
    // Intentionally no-op.
    // ignore: unused_local_variable
    final _ = (title, message, backgroundColor, textColor);
  }

  String _formatAnalyzeError(Object error) {
    if (error is SparkFlowException) {
      final statusPart =
          error.statusCode != null ? ' (status: ${error.statusCode})' : '';
      final original = error.originalError;
      String originalPart = '';
      if (original != null) {
        final cleaned =
            original.toString().trim().replaceAll(RegExp(r'\\s+'), ' ');
        final previewLength = cleaned.length > 240 ? 240 : cleaned.length;
        originalPart = '\n${cleaned.substring(0, previewLength)}';
      }
      return '${error.message}$statusPart$originalPart';
    }
    return error.toString();
  }

  Future<void> _pickImage() async {
    final ok = await _ensureGalleryPermission();
    if (!ok) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
      _analysisStage = null;
    });
  }

  Future<bool> _ensureGalleryPermission() async {
    if (!mounted) return false;

    final permission = _galleryPermissionForPlatform();
    if (permission == null) return true;

    final current = await permission.status;
    if (current.isGranted || current.isLimited) return true;
    if (!mounted) return false;

    final result = await permission.request();
    if (!mounted) return false;

    if (result.isGranted || result.isLimited) return true;

    if (result.isPermanentlyDenied || result.isRestricted) {
      _showSnack(
        AppStrings.warning,
        'Photo permission is off. Please enable it in Settings to upload a photo.',
        backgroundColor: AppColors.warning,
        textColor: Colors.black,
      );
    }

    return false;
  }

  Permission? _galleryPermissionForPlatform() {
    if (Platform.isIOS) return Permission.photos;
    if (Platform.isAndroid) {
      // Maps to READ_MEDIA_IMAGES on Android 13+, and legacy storage perms below.
      return Permission.photos;
    }
    return null;
  }

  Future<void> _analyzeImageAndOpenDetail() async {
    if (_selectedImage == null || _isAnalyzing) return;

    if (!await _ensureEnoughCoins()) return;
    if (!mounted) return;

    final apiKey = AppEnv().aiApiKey.trim();
    if (apiKey.isEmpty) {
      _showSnack(
        AppStrings.warning,
        'Please set AppEnv().aiApiKey before using AI analysis.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisStage = 'Analyzing scene...';
    });

    String? detailId;
    bool shouldChargeCoins = false;
    try {
      final service = SparkFlowAIService(apiKey: apiKey);
      final sparkResult = await service.analyzeImage(
        imageFile: _selectedImage!,
        onProgress: (stage) {
          if (!mounted) return;
          setState(() {
            _analysisStage = stage;
          });
        },
      );
      service.dispose();

      final historyItem = _appService.addSparkResult(sparkResult);
      detailId = historyItem.id;
      shouldChargeCoins = true;
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        AppStrings.warning,
        'We could not turn this photo into idea routes:\n${_formatAnalyzeError(e)}',
        backgroundColor: AppColors.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisStage = null;
        });
      }
    }

    if (detailId != null && mounted) {
      if (shouldChargeCoins) {
        final ok = await CoinsManager.instance.subCoins(
          AppConstants.createCostCoins,
        );
        if (!mounted) return;
        if (!ok) {
          _showSnack(
            AppStrings.warning,
            'Not enough coins to complete this action.',
            backgroundColor: AppColors.warning,
          );
          return;
        }
      }
      if (!mounted) return;
      // Reset to placeholder so when user returns from detail, Create looks fresh.
      setState(() {
        _selectedImage = null;
      });
      context.push('${AppRoutes.detail}/$detailId');
    }
  }

  Future<bool> _ensureEnoughCoins() async {
    final cost = AppConstants.createCostCoins;
    if (CoinsManager.instance.isEnough(cost)) return true;
    if (!mounted) return false;

    final goTopUp = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Not enough coins'),
          content: Text(
            'This action costs $cost coins. Top up to continue.',
            style: AppTextStyles.body,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            ZeriaDialogActions(
              cancelLabel: 'Cancel',
              confirmLabel: 'Instant top-up',
              onCancel: () => Navigator.of(context).pop(false),
              onConfirm: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (goTopUp == true && mounted) {
      context.push(AppRoutes.coinStore);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ZeriaScreen(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ZeriaHeader(
                title: 'Create',
                subtitle: 'TURN INPUTS INTO NEXT MOVES',
              ),
              const SizedBox(height: 22),
              _buildUploadSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildUploadCard(),
        const SizedBox(height: 10),
        _buildCostBubble(),
      ],
    );
  }

  Widget _buildUploadCard() {
    return ZeriaSurfaceCard(
      radius: 34,
      padding: const EdgeInsets.all(18),
      gradient: AppColors.accentGradient,
      borderColor: Colors.white.withValues(alpha: 0.32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              'Photo spark',
              style: AppTextStyles.h3Inverse.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              'Pick a photo. Zeria will generate 3 next-step ideas and open the detail page.',
              style: AppTextStyles.bodyInverse.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: _selectedImage == null
                  ? _buildImagePlaceholder()
                  : Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          ZeriaButton(
            label: _selectedImage == null ? 'Upload photo' : 'Analyze now',
            icon: Icons.photo_library_outlined,
            isLoading: _isAnalyzing,
            onPressed: _isAnalyzing
                ? null
                : () async {
                    if (_selectedImage == null) {
                      await _pickImage();
                      return;
                    }
                    await _analyzeImageAndOpenDetail();
                  },
          ),
          if (_selectedImage != null && !_isAnalyzing) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _pickImage,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.92),
                  textStyle: AppTextStyles.small.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: const Text('Change photo'),
              ),
            ),
          ],
          if (_analysisStage != null) ...[
            const SizedBox(height: 12),
            Text(
              '$_analysisStage We will open the idea detail page when it is ready.',
              style: AppTextStyles.small.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              child: const Icon(
                Icons.photo_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your photo will preview here',
              style: AppTextStyles.small.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostBubble() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        'Use once ${AppConstants.createCostCoins} coins to unlock 3 actionable ideas from your photo.',
        style: AppTextStyles.caption.copyWith(
          color: Colors.black.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}
