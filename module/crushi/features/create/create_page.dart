import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';
import 'package:crushi/crushi/core/widgets/app_widgets.dart';
import 'package:crushi/crushi/core/router/global_router.dart';
import 'package:crushi/crushi/core/widgets/diffuse_background.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:crushi/crushi/features/create/story_ai_service.dart';
import 'package:crushi/crushi/data/generated_history_store.dart';
import 'package:crushi/crushi/features/detail/detail_page.dart';
import 'package:crushi/crushi/data/coins_wallet_store.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  bool _isGenerating = false;
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();
  final StoryAiService _storyService = StoryAiService();
  final CoinsWalletStore _wallet = CoinsWalletStore();

  static const int _costPerGeneration = 30;

  @override
  void initState() {
    super.initState();
    _wallet.load();
  }

  Future<void> _handleGenerate() async {
    if (_selectedImagePath == null) return;
    if (_isGenerating) return;

    final ok = await _wallet.spend(_costPerGeneration);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins. Please top up first.')),
      );
      GlobalRouter.I.goToCoins();
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final result = await _storyService.generateStoicCardFromImagePath(
        imagePath: _selectedImagePath!,
      );
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        // clear selection so returning won't show previous upload as placeholder
        _selectedImagePath = null;
      });
      GeneratedHistoryStore.I.add(result.card);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailPage(card: result.card),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await _wallet.refund(_costPerGeneration);
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generate failed: $e')),
      );
    }
  }

  Future<bool> _ensurePhotoPermission() async {
    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) return true;

    final req = await Permission.photos.request();
    if (req.isGranted || req.isLimited) return true;

    if (!mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo permission is required to pick an image.')),
    );
    return false;
  }

  Future<void> _pickFromGallery() async {
    final ok = await _ensurePhotoPermission();
    if (!ok) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;

    if (!mounted) return;
    setState(() => _selectedImagePath = file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DiffuseBackground(
              base: Color(0xFF070B16),
              bottom: Color(0xFF070B16),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => GlobalRouter.I.goBack(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.textInverse,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Create',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textInverse,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Turn an image into stoic insight',
                              style: AppTypography.h2.copyWith(
                                color: AppColors.textInverse,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Upload something meaningful, then generate a short reflection.',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textInverse.withOpacity(0.72),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildCostCard(),
                            const SizedBox(height: AppSpacing.md),
                            _buildUploadCard(),
                            const SizedBox(height: AppSpacing.xl),

                            AppButton(
                              text: 'Generate',
                              onPressed: _selectedImagePath != null
                                  ? _handleGenerate
                                  : null,
                              isLoading: _isGenerating,
                              backgroundColor: AppColors.primaryMain,
                              textColor: AppColors.textInverse,
                              disabledBackgroundColor: AppColors.primaryMain,
                              disabledTextColor: AppColors.textInverse,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildStepsCard(),
                            const SizedBox(height: AppSpacing.xl),

                          ],
                        ),
                      ),
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

  Widget _buildUploadCard() {
    return _GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryMain.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.primaryMain,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  'Upload Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textInverse,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
              ),
              if (_selectedImagePath != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Text(
                    'Selected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textInverse,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildUploadArea(),
        ],
      ),
    );
  }

  Widget _buildStepsCard() {
    return _GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primaryMain.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primaryMain,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'How It Works',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.textInverse,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStepItem('1', 'Upload an image that inspires you'),
          _buildStepItem('2', 'AI analyzes the stoic wisdom within'),
          _buildStepItem('3', 'Receive your personalized insight'),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryMain,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textInverse.withOpacity(0.78),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostCard() {
    return _GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: AppColors.primaryMain, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Each generation costs $_costPerGeneration coins',
              style: AppTypography.caption.copyWith(
                color: AppColors.textInverse.withOpacity(0.78),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => GlobalRouter.I.goToCoins(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Text(
                'Get Coins',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textInverse,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickFromGallery,
      child: Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _selectedImagePath != null
                ? AppColors.primaryMain
                : AppColors.bgTertiary,
            width: 2,
          ),
        ),
        child: _selectedImagePath != null
            ? Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Image.file(
                        File(_selectedImagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryMain,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Text(
                        'Tap to change',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textInverse,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.textDisabled),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap to upload an image',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    const borderRadius = AppRadius.xl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            boxShadow: AppShadows.md,
          ),
          child: child,
        ),
      ),
    );
  }
}
