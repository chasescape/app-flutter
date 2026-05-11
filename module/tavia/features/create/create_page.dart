import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../cherish_ai/cherish_moment_ai_service.dart';
import '../../cherish_ai/cherish_moment_storage.dart';
import '../../core/state/state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/dialog_widget.dart';
import '../../core/widgets/tavia_ui.dart';
import '../../data/models/cherish_moment.dart';
import '../../shared/constants/app_constants.dart';

/// Create page with AI-powered image analysis.
class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  static const int _generationCost = 100;

  final ImagePicker _picker = ImagePicker();
  int _currentStep = 1;
  String? _selectedImagePath;
  CherishMoment? _generatedMoment;
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingMd,
              AppConstants.spacingLg,
              AppConstants.spacingXxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: AppConstants.spacingLg),
                _buildStepContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        TaviaIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        const Expanded(
          child: TaviaSectionTitle(
            title: 'Create',
            subtitle:
                'Upload one image and let AI turn it into a gentle Cherish moment.',
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 1) {
      return _buildUploadStep();
    }
    return _buildResultStep();
  }

  Widget _buildUploadStep() {
    return TaviaPanel(
      child: Column(
        children: [
          _selectedImagePath == null
              ? Container(
                  height: 340,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white.withValues(alpha: 0.34),
                        AppColors.white.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.36),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor(
                              AppColors.black,
                              opacity: 0.12,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.file_upload_outlined,
                        size: 42,
                        color: AppColors.primaryMain,
                      ),
                    ),
                  ),
                )
              : TaviaMedia(
                  source: _selectedImagePath,
                  height: 340,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(28),
                ),
          const SizedBox(height: AppConstants.spacingLg),
          const Text(
            'Pick one photo and we will turn it into a Cherish moment card.',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            _isAnalyzing
                ? 'Analyzing light, mood, and emotional tone...'
                : 'Each generation costs $_generationCost coins. The result page will be filled with AI-generated title, reflection, and tags.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          SizedBox(
            width: double.infinity,
            child: TaviaPrimaryButton(
              label: _isAnalyzing ? 'Analyzing...' : 'Pick an image',
              onPressed: _isAnalyzing ? null : _pickImage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    final moment = _generatedMoment;
    if (moment == null) {
      return const TaviaPanel(
        child: Text(
          'No generated result yet.',
          style: AppTextStyles.body,
        ),
      );
    }

    final oneLineMoment = moment.oneLineMoment.trim();
    final summary = moment.shareableCaption.trim().isNotEmpty
        ? moment.shareableCaption.trim()
        : oneLineMoment;
    final showSummary =
        summary.toLowerCase() != oneLineMoment.toLowerCase();

    return TaviaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaviaMedia(
            source: _selectedImagePath,
            height: 380,
            width: double.infinity,
            borderRadius: BorderRadius.circular(28),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Text(
            moment.cardTitle,
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            oneLineMoment,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryMain,
            ),
          ),
          if (showSummary) ...[
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              summary,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spacingLg),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.38),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusFull),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.58),
                        ),
                      ),
                      child: TextButton(
                        onPressed: _isAnalyzing ? null : _resetFlow,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          minimumSize: const Size(
                            double.infinity,
                            AppConstants.buttonHeightLg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusFull),
                          ),
                        ),
                        child: const Text('Change'),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: TaviaPrimaryButton(
                  label: 'Save',
                  onPressed: _saveContent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final state = StateProvider.of(context);
    if (state.coinBalance < _generationCost) {
      await AppDialog.showErrorDialog(
        context,
        title: 'Not enough coins',
        message:
            'Generating one result costs $_generationCost coins. Please top up your balance first.',
      );
      return;
    }

    final status = await Permission.photos.request();
    if (!(status.isGranted || status.isLimited)) {
      return;
    }

    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) {
      return;
    }

    final service = CherishMomentAiService();

    setState(() {
      _selectedImagePath = image.path;
      _isAnalyzing = true;
    });

    AppDialog.showLoadingDialog(
      context,
      message: 'Analyzing your image...',
    );

    try {
      final moment = service.hasApiKey
          ? await service.analyzeImage(File(image.path))
          : _buildFallbackMoment(image.path);

      if (!mounted) {
        return;
      }

      state.spendCoins(_generationCost);
      setState(() {
        _generatedMoment = moment;
        _currentStep = 2;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      AppDialog.showErrorDialog(
        context,
        title: 'Analysis failed',
        message: e.toString(),
      );
    } finally {
      service.dispose();
      AppDialog.hideLoadingDialog();
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  CherishMoment _buildFallbackMoment(String imagePath) {
    return CherishMoment(
      assetImg: imagePath,
      timeOfDay: SceneCard(
        value: 'Unknown',
        confidence: 0.28,
        evidence: 'Local fallback used without AI key',
      ),
      sceneType: SceneCard(
        value: 'Unknown',
        confidence: 0.28,
        evidence: 'Local fallback used without AI key',
      ),
      mainSubject: SceneCard(
        value: 'Scenery',
        confidence: 0.42,
        evidence: 'A single uploaded image is present',
      ),
      emotionalTone: SceneCard(
        value: 'Peaceful',
        confidence: 0.48,
        evidence: 'Fallback keeps the output calm and neutral',
      ),
      lightingQuality: SceneCard(
        value: 'Soft Diffused',
        confidence: 0.36,
        evidence: 'Fallback default for a gentle visual treatment',
      ),
      oneLineMoment: 'A quiet scene held still for a little longer.',
      visualElements: const ['soft focus', 'single image', 'quiet mood'],
      safety: SafetyInfo(
        hasSensitiveContent: false,
        notes: '',
      ),
      essay: CherishEssay(
        opening:
            'There is a calm honesty in starting with one image and letting it carry the mood without too much decoration.',
        feeling:
            'Even before AI is fully configured, the photo already offers a small pause. The composition, color, and texture hold enough feeling to suggest a softer story waiting underneath.',
        gratitude:
            'Sometimes the first step is simply noticing that an ordinary image is already worth keeping. That is enough for now.',
      ),
      moodTags: const ['#quietmoment', '#softfocus', '#smalljoy'],
      visualStyleRecommendation: 'Soft Pastel',
      shareableCaption:
          'Holding on to one quiet image and letting the feeling stay gentle.',
      cardTitle: 'Quiet Image Pause',
    );
  }

  void _resetFlow() {
    setState(() {
      _currentStep = 1;
      _generatedMoment = null;
      _selectedImagePath = null;
    });
  }

  Future<void> _saveContent() async {
    final moment = _generatedMoment;
    final imagePath = _selectedImagePath;
    if (moment == null) {
      return;
    }

    final saved = await CherishMomentStorage.save(
      moment,
      imagePath: imagePath,
    );

    if (!mounted) {
      return;
    }

    StateProvider.of(context).addToHistory(saved.toContentModel());
    AppDialog.showToast(
      context,
      message: 'Cherish card saved',
    );
    Navigator.of(context).pop();
  }
}
