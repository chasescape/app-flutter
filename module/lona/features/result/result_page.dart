import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/result_controller.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';

class ResultPage extends GetView<ResultController> {
  const ResultPage({super.key});

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
                title: 'Analysis result',
                subtitle: 'FRAME REVIEW',
                actions: [
                  AppRoundIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: controller.reanalyze,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildImageReview(),
              const SizedBox(height: AppSpacing.lg),
              _buildSummaryCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildBulletCard(
                title: 'Issues noticed',
                items: controller.result.issues,
                accent: AppColors.semanticWarning,
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildBulletCard(
                title: 'Suggested improvements',
                items: controller.result.suggestions,
                accent: AppColors.secondaryMain,
                icon: Icons.auto_fix_high_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildBulletCard(
                title: 'Retake steps',
                items: controller.result.retakeSteps,
                accent: AppColors.plumMain,
                icon: Icons.camera_alt_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageReview() {
    return AppSurface(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            child: AspectRatio(
              aspectRatio: 0.86,
              child: Obx(
                () => Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(controller.result.originalImagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(gradient: AppGradients.accent),
                          child: const Icon(
                            Icons.image_outlined,
                            size: 56,
                            color: AppColors.textOnDark,
                          ),
                        );
                      },
                    ),
                    if (controller.showGuide.value)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.85),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                        ),
                        child: CustomPaint(painter: GridPainter()),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _toggleButton(
                    label: 'Original',
                    selected: !controller.showGuide.value,
                    onTap: controller.showGuide.value ? controller.toggleView : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _toggleButton(
                    label: 'Guide overlay',
                    selected: controller.showGuide.value,
                    onTap: controller.showGuide.value ? null : controller.toggleView,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: selected ? AppGradients.whitePill : AppGradients.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: selected ? AppColors.secondaryMain : AppColors.textSecondary,
          shadowColor: Colors.transparent,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionTitle(
            title: 'Overall read',
            subtitle: 'Kept separate from the image so the visual stays clear.',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(controller.result.summary, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildBulletCard({
    required String title,
    required List<String> items,
    required Color accent,
    required IconData icon,
  }) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: AppTextStyles.h3)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(item, style: AppTextStyles.body)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(size.width / 3, 0)
      ..lineTo(size.width / 3, size.height)
      ..moveTo(size.width * 2 / 3, 0)
      ..lineTo(size.width * 2 / 3, size.height)
      ..moveTo(0, size.height / 3)
      ..lineTo(size.width, size.height / 3)
      ..moveTo(0, size.height * 2 / 3)
      ..lineTo(size.width, size.height * 2 / 3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
