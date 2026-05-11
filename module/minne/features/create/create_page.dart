import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/utils/app_overlay.dart';
import '../../core/widgets/app_button.dart';
import '../../core/models/creation_model.dart';
import '../../cherish_ai/cherish_card_ai_service.dart';
import '../../cherish_ai/cherish_card_storage.dart';
import '../../data/models/cherish_card.dart';
import '../../routes/app_pages.dart';
import '../../services/coins_manager.dart';

/// Create Page - Content Creation with 3-Step Flow (Micoo Create Layout)
/// Enhanced with Erin Flink's unique design elements
/// Step 1: Upload image with cost notice
/// Step 2: Language & style selection
/// Step 3: Result display with actions
class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage>
    with TickerProviderStateMixin {
  static const Color _berryPrimary = Color(0xFF8F355B);
  static const Color _berrySecondary = Color(0xFFB06A84);
  static const Color _pageTop = Color(0xFFFFEAF4);
  static const Color _pageMid = Color(0xFFFFD7E7);
  static const Color _pageBottom = Color(0xFFFFF5DF);
  static const Color _surface = Color(0xFFFFFCFE);
  static const Color _outlineRose = Color(0xFFFF5E72);
  static const List<Color> _berryGradient = [
    Color(0xFFFFB6CF),
    Color(0xFFFFDC88),
  ];
  static const List<Color> _ctaGradient = [
    Color(0xFFFF4D67),
    Color(0xFFFF8EAD),
    Color(0xFFFFD76A),
  ];

  final CreationsState _creationsState = CreationsState();
  final CoinsManager _coinsManager = CoinsManager();

  late AnimationController _stepController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _currentStep = 1;
  XFile? _selectedImage;
  String _selectedLanguage = 'English';
  String _selectedStyle = 'Warm';
  bool _isGenerating = false;
  CreationModel? _result;
  CherishCard? _lastCherishCard;

  static const int costPerCreation = 42;

  @override
  void initState() {
    super.initState();
    _creationsState.setCurrentStep(1);

    _stepController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _stepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _berryPrimary),
        title: const Text(
          'Create Happiness',
          style: TextStyle(
            color: _berryPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_pageTop, _pageMid, _pageBottom],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_pageTop, _pageMid, _pageBottom],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Step indicator
                  _buildStepIndicator(),

                  // Step content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        120,
                      ),
                      child: _buildStepContent(),
                    ),
                  ),
                ],
              ),
            ),

            // Generating overlay
            if (_isGenerating) _buildGeneratingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final labels = ['Upload', 'Style', 'Result'];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: AppBorderRadius.borderRadiusXXL,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final step = index + 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStepPill(
                    step: step,
                    label: labels[index],
                  ),
                ),
                if (index < labels.length - 1)
                  const SizedBox(
                    width: AppSpacing.sm,
                    child: Divider(
                      thickness: 1,
                      color: Color(0xFFE8D8E2),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepPill({
    required int step,
    required String label,
  }) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: isActive ? const LinearGradient(colors: _ctaGradient) : null,
        color: isActive ? null : Colors.white.withValues(alpha: 0.86),
        borderRadius: AppBorderRadius.borderRadiusFull,
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFFFC0D3)
              : isActive
                  ? Colors.transparent
                  : const Color(0xFFE6D7DF),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFF7F9E).withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.24)
                  : isCompleted
                      ? const Color(0xFFFFE1EB)
                      : const Color(0xFFF5EDF2),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: _berryPrimary,
                    )
                  : Text(
                      '$step',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : _berryPrimary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.captionMediumStyle.copyWith(
                color: isActive ? Colors.white : _berryPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Upload Image
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCostCard(),
        AppSpacing.gapLG,
        _buildUploadStage(),
        AppSpacing.gapLG,
        AppButton(
          text: 'Continue',
          isExpanded: true,
          gradientColors: _ctaGradient,
          onPressed: _selectedImage != null ? _goToStep2 : null,
        ),
      ],
    );
  }

  Widget _buildCostCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: _berryGradient,
        ),
        borderRadius: AppBorderRadius.borderRadiusXL,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD7A6).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.36),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
            ),
          ),
          AppSpacing.gapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cost: $costPerCreation coins',
                  style: AppTextStyles.bodyMediumStyle.copyWith(
                    color: _berryPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'One creation per use',
                  style: AppTextStyles.captionStyle.copyWith(
                    color: _berrySecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadStage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: AppBorderRadius.borderRadiusXXL,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Your Photo',
            style: AppTextStyles.h3Style.copyWith(
              color: _berryPrimary,
            ),
          ),
          AppSpacing.gapXS,
          Text(
            'Share your happy moment with us',
            style: AppTextStyles.bodySecondaryStyle.copyWith(
              color: _berrySecondary,
            ),
          ),
          AppSpacing.gapMD,
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _selectedImage == null ? _pulseAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    width: double.infinity,
                    height: 480,
                    decoration: BoxDecoration(
                      gradient: _selectedImage != null
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.20),
                                Colors.white.withValues(alpha: 0.06),
                              ],
                            )
                          : const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFFFBFD),
                                Color(0xFFFFF2F7),
                              ],
                            ),
                      borderRadius: AppBorderRadius.borderRadiusXL,
                      border: Border.all(
                        color: _outlineRose,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryMain.withValues(alpha: 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _selectedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: AppBorderRadius.borderRadiusXL,
                                child: Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildUploadPlaceholder();
                                  },
                                ),
                              ),
                              Positioned(
                                top: AppSpacing.md,
                                right: AppSpacing.md,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedImage = null);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.36),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: AppColors.textInverse,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _buildUploadPlaceholder(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD6E0),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryMain.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.file_upload_outlined,
            size: 40,
            color: _outlineRose,
          ),
        ),
        AppSpacing.gapMD,
        Text(
          'Tap to upload photo',
          style: AppTextStyles.bodyMediumStyle.copyWith(
            color: _berryPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.gapSM,
        Text(
          'Support JPG, PNG',
          style: AppTextStyles.smallStyle.copyWith(
            color: _berrySecondary,
          ),
        ),
      ],
    );
  }

  // Step 2: Language & Style Selection
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customize Your Creation',
          style: AppTextStyles.h2Style.copyWith(color: _berryPrimary),
        ),
        AppSpacing.gapSM,
        Text(
          'Choose your preferred language and style',
          style: AppTextStyles.bodySecondaryStyle.copyWith(color: _berrySecondary),
        ),

        AppSpacing.gapXL,

        // Language selection
        Text(
          'Language',
          style: AppTextStyles.bodyMediumStyle.copyWith(color: _berryPrimary),
        ),
        AppSpacing.gapSM,
        _buildLanguageSelector(),

        AppSpacing.gapLG,

        // Style selection
        Text(
          'Style',
          style: AppTextStyles.bodyMediumStyle.copyWith(color: _berryPrimary),
        ),
        AppSpacing.gapSM,
        _buildStyleSelector(),

        AppSpacing.gapXL,

        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Back',
                isOutlined: true,
                isExpanded: true,
                onPressed: _goToStep1,
              ),
            ),
            AppSpacing.gapMD,
            Expanded(
              child: AppButton(
                text: 'Generate',
                isExpanded: true,
                gradientColors: _ctaGradient,
                onPressed: _generateCreation,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    final languages = [
      {'name': 'English', 'flag': '🇺🇸'},
      {'name': 'Spanish', 'flag': '🇪🇸'},
      {'name': 'French', 'flag': '🇫🇷'},
      {'name': 'German', 'flag': '🇩🇪'},
      {'name': 'Japanese', 'flag': '🇯🇵'},
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: languages.map((lang) {
        final isSelected = _selectedLanguage == lang['name'];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedLanguage = lang['name'] as String);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: _berryGradient,
                      )
                    : null,
                color: isSelected ? null : _surface,
                borderRadius: AppBorderRadius.borderRadiusMD,
                border: Border.all(
                  color: isSelected
                      ? _berryPrimary
                      : const Color(0xFFF2D7E3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryMain.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang['flag'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                  AppSpacing.gapSM,
                  Text(
                    lang['name'] as String,
                    style: AppTextStyles.captionStyle.copyWith(
                          color: isSelected
                          ? _berryPrimary
                          : _berryPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStyleSelector() {
    final styles = [
      {'name': 'Warm', 'icon': '☀️', 'gradient': AppColors.primaryGradient},
      {'name': 'Peaceful', 'icon': '🌿', 'gradient': AppColors.secondaryGradient},
      {'name': 'Joyful', 'icon': '🎉', 'gradient': AppColors.accentGradient},
      {'name': 'Dreamy', 'icon': '✨', 'gradient': const [Color(0xFF9B59B6), Color(0xFF3498DB)]},
      {'name': 'Romantic', 'icon': '💕', 'gradient': const [Color(0xFFE91E63), Color(0xFFFF5722)]},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.2,
      ),
      itemCount: styles.length,
      itemBuilder: (context, index) {
        final style = styles[index];
        final isSelected = _selectedStyle == style['name'];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedStyle = style['name'] as String);
            },
            child: Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: style['gradient'] as List<Color>)
                    : null,
                color: isSelected ? null : _surface,
                borderRadius: AppBorderRadius.borderRadiusLG,
                border: Border.all(
                  color: isSelected
                      ? (style['gradient'] as List<Color>).first
                      : AppColors.inputBorder,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (style['gradient'] as List<Color>).first
                              .withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.textInverse.withOpacity(0.2)
                          : const Color(0xFFFFF0F6),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      style['icon'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  AppSpacing.gapSM,
                  Expanded(
                    child: Text(
                      style['name'] as String,
                      style: AppTextStyles.captionMediumStyle.copyWith(
                        color: isSelected
                            ? _berryPrimary
                            : _berryPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Step 3: Result
  Widget _buildStep3() {
    if (_result == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Happy Creation',
          style: AppTextStyles.h2Style.copyWith(color: _berryPrimary),
        ),

        AppSpacing.gapLG,

        // Result image
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.borderRadiusLG,
            boxShadow: AppShadows.shadowMD,
          ),
          child: ClipRRect(
            borderRadius: AppBorderRadius.borderRadiusLG,
            child: _buildImageForPath(_result!.imageUrl),
          ),
        ),

        AppSpacing.gapLG,

        // AI Analysis
        if (_result!.aiAnalysis != null) ...[
          Text(
            'AI Analysis',
            style: AppTextStyles.h3Style.copyWith(color: _berryPrimary),
          ),
          AppSpacing.gapSM,
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: _surface.withOpacity(0.78),
              borderRadius: AppBorderRadius.borderRadiusMD,
            ),
            child: Text(
              _result!.aiAnalysis!,
              style: AppTextStyles.bodyStyle.copyWith(color: _berryPrimary),
            ),
          ),
          AppSpacing.gapLG,
        ],

        // Result text
        if (_result!.resultText != null) ...[
          Text(
            'Generated Text',
            style: AppTextStyles.h3Style.copyWith(color: _berryPrimary),
          ),
          AppSpacing.gapSM,
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: _surface.withOpacity(0.78),
              borderRadius: AppBorderRadius.borderRadiusMD,
            ),
            child: Text(
              _result!.resultText!,
              style: AppTextStyles.bodyStyle.copyWith(color: _berryPrimary),
            ),
          ),
          AppSpacing.gapLG,
        ],

        // Action buttons
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Create New',
                isSecondary: true,
                isExpanded: true,
                onPressed: _openDetailAndReset,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeneratingOverlay() {
    return Container(
      color: AppColors.bgOverlay,
      child: Center(
        child: Container(
          padding: AppSpacing.paddingXL,
          margin: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryMain,
                AppColors.primaryLight,
              ],
            ),
            borderRadius: AppBorderRadius.borderRadiusXXL,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryMain.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated spinner
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    // Outer ring
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.textInverse,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    // Inner content
                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: const Icon(
                              Icons.auto_awesome,
                              color: AppColors.textInverse,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapLG,
              Text(
                'Creating your happiness...',
                style: AppTextStyles.h3Style.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.gapSM,
              Text(
                'This may take a few seconds',
                style: AppTextStyles.captionStyle.copyWith(
                  color: AppColors.textInverse.withOpacity(0.8),
                ),
              ),
              AppSpacing.gapMD,
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.textInverse.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceSheet() async {
    if (_isGenerating) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.shadowLG,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from Photos'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _requestMediaPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }

    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  Future<void> _pickImage(ImageSource source) async {
    final isGranted = await _requestMediaPermission(source);
    if (!isGranted) {
      if (!mounted) return;
      AppOverlay.showToast(
        context,
        message: source == ImageSource.camera
            ? 'Camera permission is required'
            : 'Photo permission is required',
        type: ToastType.warning,
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  void _goToStep1() {
    setState(() => _currentStep = 1);
    _creationsState.setCurrentStep(1);
  }

  void _goToStep2() {
    if (!_coinsManager.isEnoughCoins(costPerCreation)) {
      AppOverlay.showConfirmDialog(
        context: context,
        title: 'Insufficient Coins',
        content: 'This service requires $costPerCreation coins.',
        confirmText: 'Get Coins',
        cancelText: 'Cancel',
      ).then((confirmed) {
        if (confirmed == true) {
          AppRoutes.toShop();
        }
      });
      return;
    }
    setState(() => _currentStep = 2);
    _creationsState.setCurrentStep(2);
  }

  Future<void> _generateCreation() async {
    // Check balance before starting service
    if (!_coinsManager.isEnoughCoins(costPerCreation)) {
      AppOverlay.showToast(
        context,
        message: 'Insufficient coins',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isGenerating = true);

    final aiService = CherishCardAiService();
    try {
      final imagePath = _selectedImage!.path;

      final cherishCard = await aiService.analyzeImage(
        File(imagePath),
        imagePath: imagePath,
        language: _selectedLanguage,
        style: _selectedStyle,
      );

      // Deduct coins only after service succeeds
      await _coinsManager.subCoins(costPerCreation);

      // Persist to storage
      await CherishCardStorage.save(
        data: cherishCard,
        imagePath: imagePath,
        costCoins: costPerCreation,
      );

      // Create CreationModel for backward compatibility
      final result = CreationModel(
        id: cherishCard.id,
        userId: 'current_user',
        imageUrl: imagePath,
        resultText: cherishCard.meta.oneLineMoment,
        aiAnalysis: cherishCard.visualPoetry.shortHealingText,
        costCoins: costPerCreation,
        createdAt: DateTime.now(),
      );

      setState(() {
        _result = result;
        _lastCherishCard = cherishCard;
        _isGenerating = false;
        _currentStep = 3;
      });

      _creationsState.addCreation(result);

      // Stay on the result step; user can open Detail manually.
    } on CherishCardAiException catch (e) {
      setState(() => _isGenerating = false);
      if (!mounted) {
        return;
      }
      // No coins deducted on failure
      final statusInfo = e.statusCode == null ? '' : ' (HTTP ${e.statusCode})';
      AppOverlay.showToast(
        context,
        message: 'AI analysis failed: ${e.message}$statusInfo',
        type: ToastType.error,
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      if (!mounted) {
        return;
      }
      // No coins deducted on failure
      AppOverlay.showToast(
        context,
        message: 'Generation failed, please try again',
        type: ToastType.error,
      );
    } finally {
      aiService.dispose();
    }
  }

  void _shareCreation() {
    AppOverlay.showToast(
      context,
      message: 'Shared successfully!',
      type: ToastType.success,
    );
  }

  void _resetCreation() {
    setState(() {
      _selectedImage = null;
      _result = null;
      _lastCherishCard = null;
      _currentStep = 1;
    });
    _creationsState.setCurrentStep(1);
  }

  Future<void> _openDetailAndReset() async {
    final card = _lastCherishCard;
    if (card == null) {
      _resetCreation();
      return;
    }
    await AppRoutes.toDetail(card, imagePath: _result?.imageUrl);
    _resetCreation();
  }

  Widget _buildImageForPath(String pathOrUrl) {
    final value = pathOrUrl.trim();
    final isRemote = value.startsWith('http://') || value.startsWith('https://');
    if (isRemote) {
      return Image.network(
        value,
        fit: BoxFit.cover,
      );
    }

    final filePath = value.startsWith('file://') ? Uri.parse(value).toFilePath() : value;
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
