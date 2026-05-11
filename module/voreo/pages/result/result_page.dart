import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../models/hairstyle_result.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_border.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../ui/dreamy_ui.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final UserController _userController = Get.find<UserController>();
  HairstyleResult? _result;
  bool _showOriginal = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final String? resultId = args?['resultId'] as String?;
    if (resultId != null) {
      _result = _userController.history
          .firstWhereOrNull((item) => item.id == resultId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null) {
      return const Scaffold(
        body: DreamyEmptyState(
          title: 'Result not found',
          subtitle: 'This preview may have been removed from your history.',
          icon: Icons.collections_bookmark_outlined,
        ),
      );
    }

    final String currentPath = _showOriginal
        ? _result!.originalImagePath
        : (_result!.previewImagePath ?? _result!.originalImagePath);

    return DreamyPageScaffold(
      showFloor: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DreamyTopBar(
              title: 'Your preview',
              subtitle: 'Image-forward result, with notes kept cleanly below.',
              onBack: AppRoutes.goBack,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: DreamyChip(
                    label: 'Preview',
                    selected: !_showOriginal,
                    onTap: () => setState(() => _showOriginal = false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DreamyChip(
                    label: 'Original',
                    selected: _showOriginal,
                    onTap: () => setState(() => _showOriginal = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: DreamyImageCard(
                height: 430,
                radius: AppBorder.radiusXLarge,
                child: _buildFileImage(
                  currentPath,
                  label: _showOriginal ? 'Original' : 'Preview',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DreamyGlassCard(
              radius: AppBorder.radiusXLarge,
              padding: AppSpacing.allLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _result!.mainStyleName,
                    style: AppTypography.h2.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _result!.whyItFits,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textGrey,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      DreamyStatPill(
                        label: '${_result!.coinsUsed} coins used',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      DreamyStatPill(
                        label: _formatDate(_result!.createdAt),
                        icon: Icons.schedule_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_result!.alternativeSuggestions.isNotEmpty) ...[
              const DreamySectionLabel(
                title: 'Alternative directions',
                subtitle:
                    'Short, clear variations without competing with the image.',
              ),
              const SizedBox(height: AppSpacing.md),
              ..._result!.alternativeSuggestions.map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: DreamyGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.styleName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          suggestion.description,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            DreamyGlassCard(
              radius: AppBorder.radiusXLarge,
              padding: AppSpacing.allLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DreamySectionLabel(
                    title: 'Barber note',
                    subtitle: 'Keep this handy for your next salon visit.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _result!.barberNote,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textDark,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DreamySecondaryButton(
                    label: 'Copy note',
                    icon: Icons.copy_rounded,
                    onTap: () async {
                      await Clipboard.setData(
                          ClipboardData(text: _result!.barberNote));
                      Get.snackbar(
                        'Copied',
                        'Barber note copied to clipboard.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const DreamyPrimaryButton(
              label: 'Create another preview',
              onTap: AppRoutes.toGenerate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileImage(String path, {required String label}) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return DreamyImageFallback(label: label);
      },
    );
  }

  String _formatDate(DateTime value) {
    return '${value.month}/${value.day}/${value.year}';
  }
}
