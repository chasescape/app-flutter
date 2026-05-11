import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/nail_models.dart';
import '../../routes/app_routes.dart';
import '../../services/ai_service.dart';
import '../../services/coin_manager.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  String? _selectedImage;
  SceneTag? _selectedScene;
  final _preferenceController = TextEditingController();
  bool _isAnalyzing = false;

  final List<SceneTag> _scenes = SceneTag.values;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _selectedImage = image.path);
    }
  }

  void _showImageSourcePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Choose from Library'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _cancelAnalysis() {
    AIService().cancelAnalysis();
    setState(() => _isAnalyzing = false);
  }

  Future<void> _analyze() async {
    if (_selectedImage == null) return;

    final coinMgr = CoinManager.to;
    final cost = CoinManager.costPerToolUse;
    final canAfford = coinMgr.hasFreeUses || coinMgr.coins >= cost;

    if (!canAfford) {
      _showInsufficientCoinsDialog(cost);
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final styles = await AIService().analyzeHandPhoto(
        imagePath: _selectedImage!,
        sceneTag: _selectedScene?.label,
        preference: _preferenceController.text.isEmpty
            ? null
            : _preferenceController.text,
      );

      final result = RecommendationResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: _selectedImage!,
        sceneTag: _selectedScene?.label,
        preference: _preferenceController.text.isEmpty
            ? null
            : _preferenceController.text,
        styles: styles,
        createdAt: DateTime.now(),
      );

      await AIService().saveResult(result);
      await coinMgr.consumeToolUse();

      if (mounted) {
        context.push(AppRoutes.result, extra: {
          'imagePath': _selectedImage!,
          'styles': styles,
          'sceneTag': _selectedScene?.label,
        });
      }
    } on AIServiceException catch (e) {
      if (mounted && !e.isCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis failed, please try again'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _showInsufficientCoinsDialog(int cost) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Insufficient Coins'),
        content: Text('This analysis requires $cost coins.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.coins);
            },
            child: const Text('Get Coins'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _preferenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CreateHeader(),
              const SizedBox(height: AppSpacing.lg),
              _buildBalanceRow(context),
              const SizedBox(height: AppSpacing.lg),
              AppImageStage(
                imagePath: _selectedImage,
                height: 420,
                onTap: _showImageSourcePicker,
                emptyTitle: 'Tap to upload a hand photo',
                emptySubtitle: 'The cleaner the shot, the prettier the recommendations.',
                footer: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedImage == null
                            ? 'We recommend a close-up with soft light.'
                            : 'Tap the photo again if you want to switch it.',
                        style: const TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.photo_library_outlined, color: AppColors.textOnDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSceneSelector(),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Generate my moodboard',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _selectedImage != null ? _analyze : null,
                ),
              ),
            ],
          ),
        ),
        if (_isAnalyzing) AnalysisLoadingOverlay(onCancel: _cancelAnalysis),
      ],
    );
  }

  Widget _buildBalanceRow(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                CoinManager.to.hasFreeUses
                    ? '${CoinManager.to.freeCount} free'
                    : '${CoinManager.costPerToolUse} coins per analysis',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CoinBadge(
            coins: CoinManager.to.coins.value,
            onTap: () => context.push(AppRoutes.coins),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneSelector() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Occasion mood',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Optional, but great for steering the style direction.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _scenes.map((scene) {
              return StyleTagChip(
                label: scene.label,
                isSelected: _selectedScene == scene,
                onTap: () => setState(
                  () => _selectedScene = _selectedScene == scene ? null : scene,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CreateHeader extends StatelessWidget {
  const _CreateHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build your moodboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload a photo and start.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                height: 1.25,
              ),
        ),
      ],
    );
  }
}
