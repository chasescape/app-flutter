import 'dart:io';

import 'package:flutter/material.dart';
import 'package:havki/havki/app/services/coins_manager.dart';
import 'package:havki/havki/app/routes/app_routes.dart';
import 'package:havki/havki/app/theme/app_theme.dart';
import 'package:havki/havki/data/models/quote/quote_vibe_analysis_data.dart';
import 'package:havki/havki/env/api_keys.dart';
import 'package:havki/havki/services/quote_vibe_ai_service.dart';
import 'package:havki/havki/services/quote_vibe_storage_service.dart';
import 'package:image_picker/image_picker.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final ImagePicker _imagePicker = ImagePicker();
  final CoinsManager _coinsManager = CoinsManager();
  File? _selectedImage;
  QuoteVibeStyle _selectedStyle = QuoteVibeStyle.healing;
  bool _isAnalyzing = false;

  static const int _kAnalysisCostCoins = 43;

  @override
  void initState() {
    super.initState();
    _coinsManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppCircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: AppSectionTitle(
                    eyebrow: 'Create',
                    title: 'Upload a photo',
                    subtitle: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                children: [
                  _buildCostCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildImageCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildStyleSelector(),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedImage == null || _isAnalyzing ? null : _analyzeImage,
                      child: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze photo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard() {
    return AppGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI analysis cost',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Each successful analysis uses a fixed fee after the result is ready.',
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    fontWeight: AppFontWeights.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '43 coins per analysis',
                    style: TextStyle(
                      fontSize: AppFontSizes.caption,
                      fontWeight: AppFontWeights.semibold,
                      color: AppColors.textPrimary,
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

  Widget _buildImageCard() {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected image',
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              fontWeight: AppFontWeights.semibold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: _isAnalyzing ? null : _pickImage,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              child: AspectRatio(
                aspectRatio: 0.9,
                child: _selectedImage == null
                    ? Container(
                        color: Colors.white.withValues(alpha: 0.55),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 42, color: AppColors.textSecondary),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Tap to choose a photo',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: AppFontSizes.caption,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector() {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood direction',
            style: TextStyle(
              fontSize: AppFontSizes.caption,
              fontWeight: AppFontWeights.semibold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: QuoteVibeStyle.values.map((style) {
              final selected = style == _selectedStyle;
              return ChoiceChip(
                label: Text(style.displayName),
                selected: selected,
                onSelected: (_) => setState(() => _selectedStyle = style),
                selectedColor: AppColors.secondary,
                labelStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: selected ? AppFontWeights.semibold : AppFontWeights.medium,
                ),
                side: const BorderSide(color: AppColors.divider),
                backgroundColor: Colors.white.withValues(alpha: 0.55),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      return;
    }

    if (!_coinsManager.isEnough(_kAnalysisCostCoins)) {
      _showInsufficientCoinsDialog(_kAnalysisCostCoins);
      return;
    }

    setState(() => _isAnalyzing = true);
    try {
      QuoteVibeAiService.initialize(apiKey: kGeApiKey);
      final result = await QuoteVibeAiService.instance.analyzeImage(
        imagePath: _selectedImage!.path,
        style: _selectedStyle,
      );
      await _coinsManager.subCoins(_kAnalysisCostCoins);
      await QuoteVibeStorageService.instance.addResult(result);
      if (mounted) {
        AppNavigator.I.toDetail(result);
      }
    } on QuoteVibeAiException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Analysis failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInsufficientCoinsDialog(int requiredCoins) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: AppSpacing.sm),
              Text('Insufficient Coins'),
            ],
          ),
          content: Text(
            'This analysis requires $requiredCoins coins. Add more coins to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                AppNavigator.I.toStore();
              },
              child: const Text('Get Coins'),
            ),
          ],
        );
      },
    );
  }
}
