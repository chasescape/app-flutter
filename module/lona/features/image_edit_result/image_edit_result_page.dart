import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';
import '../../data/models/image_edit_result.dart';
import '../../routes/app_routes.dart';

enum _ComparisonView {
  before,
  after,
}

class ImageEditResultPage extends StatefulWidget {
  const ImageEditResultPage({super.key});

  @override
  State<ImageEditResultPage> createState() => _ImageEditResultPageState();
}

class _ImageEditResultPageState extends State<ImageEditResultPage> {
  late final ImageEditResult _result;
  _ComparisonView _activeView = _ComparisonView.after;

  bool get _hasBeforeImage => _result.oldImagePaths.isNotEmpty;
  bool get _hasExtraSourceImages => _result.oldImagePaths.length > 1;

  String get _activeImagePath {
    if (_activeView == _ComparisonView.before && _hasBeforeImage) {
      return _result.oldImagePaths.first;
    }
    return _result.resultImagePath;
  }

  String get _activeTagLabel {
    return _activeView == _ComparisonView.before
        ? 'BEFORE REFERENCE'
        : 'AFTER RESULT';
  }

  String get _summaryText {
    if (_activeView == _ComparisonView.before) {
      return 'This is the original source photo used for the remix. '
          'Switch back to After to compare the upgraded framing, cleanup, and overall polish.';
    }
    return _result.subtitle;
  }

  @override
  void initState() {
    super.initState();
    _result = Get.arguments as ImageEditResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              AppTopBar(
                title: _result.title,
                subtitle: 'EDIT RESULT',
                actions: [
                  AppRoundIconButton(
                    icon: Icons.home_rounded,
                    onTap: () => Get.toNamed(AppRoutes.home),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildComparisonHero(),
              const SizedBox(height: AppSpacing.lg),
              _buildSummaryCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildCopySection('Why it works better', _result.whyBetter),
              const SizedBox(height: AppSpacing.lg),
              _buildCopySection('How it works', _result.howItWorks),
              if (_hasExtraSourceImages) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildSourceImages(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasBeforeImage) _buildComparisonToggle(),
        if (_hasBeforeImage) const SizedBox(height: AppSpacing.md),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppGradients.surfaceWarm,
                borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                border: Border.all(color: Colors.white.withValues(alpha: 0.44)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                child: AspectRatio(
                  aspectRatio: 0.84,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _buildHeroImage(
                        path: _activeImagePath,
                        key: ValueKey('${_activeView.name}_$_activeImagePath'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 22,
              left: 22,
              child: AppTag(
                label: _activeTagLabel,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildComparisonPill(
              label: 'After',
              icon: Icons.auto_awesome_rounded,
              isSelected: _activeView == _ComparisonView.after,
              onTap: () => _setActiveView(_ComparisonView.after),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildComparisonPill(
              label: 'Before',
              icon: Icons.history_rounded,
              isSelected: _activeView == _ComparisonView.before,
              onTap: () => _setActiveView(_ComparisonView.before),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final textColor = isSelected ? AppColors.textOnDark : AppColors.textPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: isSelected ? AppGradients.accent : AppGradients.whitePill,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.shadowColor.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.full),
          child: SizedBox(
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTextStyles.button.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage({
    required String path,
    required Key key,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        child: Image.file(
          File(path),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(gradient: AppGradients.accent),
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.textOnDark,
                size: 52,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTag(label: _activeTagLabel),
          const SizedBox(height: AppSpacing.md),
          Text(_summaryText, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Instruction context',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(_result.editInstructionContext, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildCopySection(String title, String content) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          Text(content, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildSourceImages() {
    final extraImages = _result.oldImagePaths.skip(1).toList();
    if (extraImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(
          title: 'Extra source images',
          subtitle:
              'The first source photo is used in the before/after toggle above.',
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: extraImages.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(
                    File(extraImages[index]),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: AppGradients.surfaceWarm,
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _setActiveView(_ComparisonView view) {
    if (_activeView == view) {
      return;
    }
    setState(() {
      _activeView = view;
    });
  }
}
