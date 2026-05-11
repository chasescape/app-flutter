import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';
import '../../../core/pink_ui.dart';
import '../models/lash_style.dart';
import '../providers/lash_provider.dart';

class CreatePreviewPage extends StatefulWidget {
  const CreatePreviewPage({super.key});

  @override
  State<CreatePreviewPage> createState() => _CreatePreviewPageState();
}

class _CreatePreviewPageState extends State<CreatePreviewPage> {
  bool _isGenerating = false;
  String? _generationError;

  Future<void> _generatePreview(LashProvider lashProvider) async {
    final selectedImagePath = lashProvider.selectedImagePath;
    if (selectedImagePath == null) {
      setState(() {
        _generationError = 'Upload an eye photo before generating.';
      });
      return;
    }
    if (lashProvider.selectedStyle == null) {
      setState(() {
        _generationError = 'Choose a style before generating.';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationError = null;
    });

    try {
      await lashProvider.generatePreview();

      if (!mounted) {
        return;
      }

      final latestItem =
          lashProvider.history.isNotEmpty ? lashProvider.history.first : null;
      if (latestItem != null) {
        AppRoutes.toResultWithItem(latestItem);
      }
    } on InsufficientCoinsException catch (e) {
      if (!mounted) {
        return;
      }
      _showInsufficientCoinsDialog(e.required, e.current);
    } catch (e) {
      if (!mounted) {
        return;
      }
      // Hide timeout / failure copy on the generate page.
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showInsufficientCoinsDialog(int requiredCoins, int currentCoins) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('More Coins Needed'),
          content: Text(
            'This preview needs $requiredCoins coins. You currently have $currentCoins.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                AppRoutes.toCoinStore();
              },
              child: const Text('Open Store'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PinkPageScaffold(
      leading: const PinkBackButton(onTap: AppRoutes.back),
      title: 'Create',
      centerTitle: true,
      child: Consumer<LashProvider>(
        builder: (context, lashProvider, child) {
          final hasSelectedStyle = lashProvider.selectedStyle != null;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PinkGlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.heroGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppTheme.textInverse,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create a new preview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppTheme.spacingXs),
                            Text(
                              'Upload a photo, pick a style, then generate your look.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                const PinkSectionTitle(
                  title: 'Upload',
                  subtitle:
                      'Use a clear, front-facing eye photo for the best result.',
                ),
                const SizedBox(height: AppTheme.spacingMd),
                _buildUploadCard(lashProvider),
                const SizedBox(height: AppTheme.spacingLg),
                const PinkSectionTitle(
                  title: 'Choose Style',
                  subtitle: 'Pick the lash mood you want to preview.',
                ),
                const SizedBox(height: AppTheme.spacingMd),
                _buildStyleCards(context, lashProvider),
                if (!hasSelectedStyle) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Select one style to enable AI generation.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryDark,
                        ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingLg),
                PinkPrimaryButton(
                  label: _isGenerating ? 'Generating...' : 'Generate Preview',
                  onPressed: _isGenerating || !hasSelectedStyle
                      ? null
                      : () => _generatePreview(lashProvider),
                  leading: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.textInverse,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded, size: 18),
                ),
                if (_generationError != null) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    _generationError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.error,
                        ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadCard(LashProvider lashProvider) {
    return PinkGlassCard(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: AspectRatio(
              aspectRatio: 1.08,
              child: lashProvider.selectedImagePath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(lashProvider.selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: AppTheme.spacingSm,
                          right: AppTheme.spacingSm,
                          child: GestureDetector(
                            onTap: lashProvider.clearSelectedImage,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor
                                    .withValues(alpha: 0.86),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.heroGradient,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.surfaceColor.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.add_a_photo_outlined,
                              color: AppTheme.textInverse,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          const Text(
                            'Drop in your eye photo',
                            style: TextStyle(
                              color: AppTheme.textInverse,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          const Text(
                            'Use a bright, front-facing shot for the cleanest result.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textInverse,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: PinkOutlineButton(
                  label: 'Camera',
                  onPressed: lashProvider.takePhoto,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: PinkPrimaryButton(
                  label: 'Gallery',
                  onPressed: lashProvider.pickImage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleCards(BuildContext context, LashProvider lashProvider) {
    return Column(
      children: LashStyle.presetStyles.map((style) {
        final isSelected = lashProvider.selectedStyle?.id == style.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              onTap: () => lashProvider.selectStyle(style),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryMain
                        : AppTheme.textPrimary.withValues(alpha: 0.08),
                    width: isSelected ? 1.4 : 1,
                  ),
                  boxShadow: [
                    AppTheme.shadow(
                      isSelected ? AppTheme.primaryMain : AppTheme.textPrimary,
                      isSelected ? 0.12 : 0.05,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            style.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            '${style.curl} · ${style.length}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected
                          ? AppTheme.primaryMain
                          : AppTheme.textDisabled,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
