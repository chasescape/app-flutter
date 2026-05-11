import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lenbo/lenbo/app/routes/app_routes.dart';
import 'package:lenbo/lenbo/core/theme/app_colors.dart';
import 'package:lenbo/lenbo/core/theme/app_spacing.dart';
import 'package:lenbo/lenbo/core/services/plant_analysis_ai_service.dart';
import 'package:lenbo/lenbo/core/services/analysis_storage.dart';
import 'package:lenbo/lenbo/core/services/coins_manager.dart';
import 'package:lenbo/lenbo/core/utils/constants.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _imagePath = '';

  Future<bool> _requestImagePermission(ImageSource source) async {
    final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    final status = await permission.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    final message = source == ImageSource.camera
        ? 'Camera permission is required to take plant photos.'
        : 'Photo library permission is required to choose plant photos.';

    _showPermissionSnackBar(message);

    if (status.isPermanentlyDenied || status.isRestricted) {
      _showPermissionSettingsDialog(source);
    }

    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    final granted = await _requestImagePermission(source);
    if (!granted) {
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _imagePath = picked.path;
          _hasError = false;
          _errorMessage = '';
        });
      }
    } catch (e) {
      print('[CreatePage] Image pick error: $e');
    }
  }

  void _showPermissionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPermissionSettingsDialog(ImageSource source) {
    final title = source == ImageSource.camera ? 'Enable Camera Access' : 'Enable Photo Access';
    final content = source == ImageSource.camera
        ? 'Please allow camera access in Settings so you can take plant photos.'
        : 'Please allow photo library access in Settings so you can choose plant photos.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: BorderSide(color: AppColors.cardBorderLight.withOpacity(0.3), width: 0.5),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.secondaryMain),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Text(
                'Select Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Camera option
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.cardBorderLight.withOpacity(0.4), width: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryMain.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.secondaryMain, size: 20),
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 20),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ),
              // Gallery option
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.cardBorderLight.withOpacity(0.4), width: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryMain.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: AppColors.secondaryMain, size: 20),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 20),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _saveImageToLocalStorage(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/analysis_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final targetPath = '${imagesDir.path}/$fileName';
    await File(sourcePath).copy(targetPath);
    return targetPath;
  }

  Future<void> _handleAnalyze() async {
    if (_imagePath.isEmpty) {
      _showImageSourcePicker();
      return;
    }

    if (!CoinsManager.isEnough(AppConstants.analyzeCost)) {
      _showInsufficientDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    PlantAnalysisAiService? aiService;
    try {
      final imageFile = File(_imagePath);
      final imageBytes = await imageFile.readAsBytes();

      aiService = PlantAnalysisAiService(apiKey: 'sk-x0z8mqyXr7GY7mUH04B8C36b01De47BdB2C849677d91AcB0');
      final result = await aiService.analyzePlant(imageBytes);

      // Save image to persistent storage
      final savedPath = await _saveImageToLocalStorage(_imagePath);
      final analysis = result.copyWith(assetImg: savedPath);

      // Persist to history
      await AnalysisStorage.saveAnalysis(analysis);

      // Deduct coins
      await CoinsManager.subCoins(AppConstants.analyzeCost);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _imagePath = '';
          _hasError = false;
          _errorMessage = '';
        });

        AppRoutes.toDetail(analysis);
      }
    } on PlantAnalysisAiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Analysis failed. Please try again.';
        });
      }
    } finally {
      aiService?.dispose();
    }
  }

  void _showInsufficientDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: BorderSide(color: AppColors.cardBorderLight.withOpacity(0.3), width: 0.5),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.secondaryMain, size: 22),
            SizedBox(width: 8),
            Text(
              'Insufficient Coins',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'This service requires ${AppConstants.analyzeCost} coins.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppRoutes.toCoinStore();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.secondaryMain),
            child: const Text('Get Coins'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bgPrimary,
                  AppColors.accentMain.withOpacity(0.10),
                  AppColors.bgPrimary,
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Container(
                    width: 104,
                    height: 104,
                    margin: const EdgeInsets.symmetric(horizontal: 96),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accentMain.withOpacity(0.35),
                          AppColors.bgPrimary,
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.secondaryMain.withOpacity(0.32),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPinkGlow.withOpacity(0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_florist_rounded,
                      size: 42,
                      color: AppColors.secondaryMain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Analyze Your Plant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Identify species, check health & get care tips',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withOpacity(0.82),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GestureDetector(
                    onTap: _showImageSourcePicker,
                    child: Container(
                      height: 360,
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.cardBorderLight.withOpacity(0.75),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonPinkGlow.withOpacity(0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: _imagePath.isNotEmpty
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.file(
                                    File(_imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 14,
                                  bottom: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.45),
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.photo_camera_rounded, color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'Change Photo',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 82,
                                  height: 82,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.secondaryMain.withOpacity(0.08),
                                    border: Border.all(
                                      color: AppColors.cardBorderLight.withOpacity(0.55),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.file_upload_rounded,
                                    size: 36,
                                    color: AppColors.secondaryMain,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Upload your plant photo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 28),
                                  child: Text(
                                    'Take a clear photo or choose one from your gallery to start the analysis right here.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: AppColors.textSecondary.withOpacity(0.78),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentMain.withOpacity(0.10),
                          AppColors.secondaryMain.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.cardBorderLight.withOpacity(0.35), width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on, color: AppColors.secondaryMain, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Cost: ${AppConstants.analyzeCost} coins per use',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPinkGlow.withOpacity(0.32),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAnalyze,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryMain,
                          foregroundColor: AppColors.textInverse,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          disabledBackgroundColor: AppColors.neonPink.withOpacity(0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_camera_rounded, size: 18, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Start Analysis',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_hasError) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.error.withOpacity(0.25), width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Analysis Failed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: AppColors.bgOverlay,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMain,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(color: AppColors.cardBorderLight.withOpacity(0.3), width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPinkGlow.withOpacity(0.3),
                        blurRadius: 24,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryMain),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Analyzing your plant...',
                        style: TextStyle(
                          color: AppColors.textInverse,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
