import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/widgets/bounce_in_animation.dart';
import '../../app/widgets/gradient_button.dart';
import '../../app/widgets/glass_card.dart' show GlassCard;
import '../../services/ai_analysis_service.dart';
import '../../services/coins_manager.dart';
import '../../light_handle.dart';
import '../../app/router/app_router.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  File? _selectedImage;
  bool _isProcessing = false;
  double _progress = 0;
  bool _showResult = false;

  /// AI分析固定扣费金额（运行时不变）
  static const int _kAnalysisCostCoins = 47;

  Future<bool> _requestImagePermission(ImageSource source) async {
    final permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  Future<void> _pickImage(ImageSource source) async {
    final hasPermission = await _requestImagePermission(source);
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _showResult = false;
      });
    }
  }

  Future<void> _startAnalysis() async {
    if (_selectedImage == null) return;

    // 检查金币是否足够
    if (!CoinsManager.instance.isEnough(_kAnalysisCostCoins)) {
      _showInsufficientCoinsDialog();
      return;
    }

    setState(() {
      _isProcessing = true;
      _progress = 0;
    });

    _animateProgress();

    try {
      final service = AiAnalysisService();
      final result = await service.analyzeImage(_selectedImage!.path);
      if (!mounted) return;

      // AI分析成功后扣费（关键：只在成功时扣费）
      await CoinsManager.instance.subCoins(_kAnalysisCostCoins);

      await LightHandle.saveAnalysis(result);
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _progress = 0;
      });
      AppRouter.toDetail(context, data: result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _progress = 0;
      });
      // 分析失败不扣费；按需求关闭失败弹窗提示
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       e is AiAnalysisException
      //           ? e.message
      //           : 'Analysis failed, please try again',
      //     ),
      //     backgroundColor: AppColors.error,
      //   ),
      // );
    }
  }

  void _animateProgress() async {
    while (_isProcessing && mounted) {
      await Future.delayed(const Duration(milliseconds: 260));
      if (!mounted || !_isProcessing) return;
      setState(() {
        if (_progress < 0.18) {
          _progress += 0.02;
        } else if (_progress < 0.45) {
          _progress += 0.012;
        } else if (_progress < 0.72) {
          _progress += 0.008;
        } else if (_progress < 0.9) {
          _progress += 0.0035;
        } else {
          _progress += 0.001;
        }
        _progress = _progress.clamp(0.0, 0.94);
      });
    }
  }

  void _startOver() {
    setState(() {
      _selectedImage = null;
      _showResult = false;
      _progress = 0;
    });
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF160724),
                  Color(0xFF2B1461),
                  Color(0xFF3A1D7D)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -80,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryMain.withValues(alpha: 0.18),
            ),
          ),
        ),
        Positioned(
          top: 180,
          right: -110,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8C6BFF).withValues(alpha: 0.16),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentMain.withValues(alpha: 0.14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 80),
      child: GlassCard(
        borderRadius: AppSpacing.borderRadiusXl,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(AppSpacing.lg),
        bgColor: Colors.white.withValues(alpha: 0.08),
        borderColor: Colors.white.withValues(alpha: 0.14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'AI Photo Coach',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Turn one photo into practical next-shot advice.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Upload an image and get scene analysis, composition feedback, and specific ways to improve your next capture.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 130),
      child: GlassCard(
        borderRadius: AppSpacing.borderRadiusXl,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(AppSpacing.md),
        bgColor: Colors.white.withValues(alpha: 0.07),
        borderColor: Colors.white.withValues(alpha: 0.12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.accentMain, size: 18),
                const SizedBox(width: 8),
                Text(
                  'How it works',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStepCard(
              context,
              number: '1',
              title: 'Pick your photo',
              description: 'Choose a shot from camera or gallery.',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildStepCard(
              context,
              number: '2',
              title: 'Let AI inspect it',
              description: 'We read composition, lighting, and scene cues.',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildStepCard(
              context,
              number: '3',
              title: 'Get next-shot direction',
              description: 'Receive concrete tips you can apply immediately.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostChip(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 180),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.12), width: 0.6),
          ),
          child: Row(
            children: [
              const Icon(Icons.diamond_rounded,
                  color: AppColors.accentMain, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$_kAnalysisCostCoins coins per analysis',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 230),
      child: GlassCard(
        borderRadius: AppSpacing.borderRadiusXxl,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(AppSpacing.md),
        bgColor: Colors.white.withValues(alpha: 0.08),
        borderColor: Colors.white.withValues(alpha: 0.14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your image',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                if (_selectedImage != null)
                  TextButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _showImageSourceDialog(context),
                    child: const Text('Change'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap:
                  _isProcessing ? null : () => _showImageSourceDialog(context),
              child: Container(
                height: 480,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.borderRadiusXl),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.borderRadiusXl),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Tap to select a photo',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Supports JPG and PNG. Camera and gallery both work.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.68),
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    if (_showResult) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 12, AppSpacing.lg, AppSpacing.lg),
          child: GradientButton(
            text: 'Start Over',
            onPressed: _startOver,
          ),
        ),
      );
    }

    if (_isProcessing) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 12, AppSpacing.lg, AppSpacing.lg),
          child: GlassCard(
            borderRadius: AppSpacing.borderRadiusXl,
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(AppSpacing.md),
            bgColor: Colors.white.withValues(alpha: 0.10),
            borderColor: Colors.white.withValues(alpha: 0.14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Analyzing photo...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${(_progress * 100).clamp(0, 100).toInt()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.76),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accentMain),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 12, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientButton(
              text: 'Analyze Composition',
              onPressed: _selectedImage != null ? _startAnalysis : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundPrimary,
      bottomNavigationBar: _buildBottomAction(context),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _TransparentTopBar(title: 'Composition Analysis'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      140,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroCard(context),
                        const SizedBox(height: AppSpacing.lg),
                        _buildCostChip(context),
                        const SizedBox(height: AppSpacing.lg),
                        if (!_showResult) _buildUploadCard(context),
                        if (_showResult) ...[
                          BounceInAnimation(
                            delay: const Duration(milliseconds: 200),
                            child: GlassCard(
                              borderRadius: AppSpacing.borderRadiusXl,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.auto_awesome,
                                          color: AppColors.accentMain),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Analysis Result',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  // Result image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.borderRadiusMd),
                                    child: _selectedImage != null
                                        ? Image.file(_selectedImage!,
                                            height: 160, fit: BoxFit.cover)
                                        : Container(
                                            height: 160,
                                            color: AppColors.cardBg,
                                          ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  // Analysis details
                                  _buildAnalysisItem(
                                      'Composition Score', '92/100'),
                                  _buildAnalysisItem(
                                      'Rule of Thirds', 'Excellent'),
                                  _buildAnalysisItem('Leading Lines', 'Good'),
                                  _buildAnalysisItem(
                                      'Color Harmony', 'Very Good'),
                                  _buildAnalysisItem('Balance', 'Excellent'),
                                  const SizedBox(height: AppSpacing.md),
                                  // Scene description
                                  Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundOverlay,
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.borderRadiusMd),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.lightbulb_outline,
                                                color: AppColors.accentMain,
                                                size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Suggestions',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Text(
                                          'Your photo demonstrates excellent use of the rule of thirds. '
                                          'Consider adjusting the horizon slightly lower to create more '
                                          'dramatic sky composition. The leading lines from the road '
                                          'draw the eye naturally into the frame.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        _buildHowItWorksCard(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accentMain,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Insufficient Coins'),
          ],
        ),
        content: const Text(
          'This analysis requires $_kAnalysisCostCoins coins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppRouter.toCoinStore(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentMain,
              foregroundColor: Colors.white,
            ),
            child: const Text('Get Coins'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ListTile(
                  leading: const Icon(Icons.photo_library,
                      color: AppColors.accentMain),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.camera_alt, color: AppColors.accentMain),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TransparentTopBar extends StatelessWidget {
  final String title;

  const _TransparentTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
