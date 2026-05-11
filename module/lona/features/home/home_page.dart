import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';
import '../../data/models/saved_result_item.dart';
import '../../routes/app_routes.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 380;

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
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              _buildActionHub(isCompact),
              const SizedBox(height: AppSpacing.xl),
              _buildRecentSection(isCompact),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COMPOSITION GUIDE',
                style: AppTextStyles.eyebrow.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lona',
                style: AppTextStyles.h2.copyWith(height: 1.05),
              ),
              const SizedBox(height: 6),
              const Text(
                'One place to upload, shoot, and revisit your recent frames.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        AppRoundIconButton(
          icon: Icons.settings_rounded,
          onTap: () => Get.toNamed(AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildActionHub(bool isCompact) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.coinsNotifier,
      builder: (context, coins, _) => AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactBalance(
              value: '$coins',
              icon: Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New review',
                        style: AppTextStyles.h2.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pick one path and keep the rest out of the way.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildHeroBadge(isCompact),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildShortcutRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBalance({
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: AppGradients.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 15,
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(width: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text: ' coins',
                    style: AppTextStyles.small,
                  ),
                ],
              ),
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBadge(bool isCompact) {
    final size = isCompact ? 74.0 : 88.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.accent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMain.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_fix_high_rounded,
        size: isCompact ? 30 : 36,
        color: AppColors.textOnDark,
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.whitePill,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  Widget _buildShortcutRow() {
    return Row(
      children: [
        Expanded(
          child: _buildPrimaryActionButton(
            label: 'History',
            icon: Icons.history_rounded,
            onTap: () => Get.toNamed(AppRoutes.history),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildPrimaryActionButton(
            label: 'Image remix',
            icon: Icons.tune_rounded,
            onTap: () => Get.toNamed(AppRoutes.imageEditCreate),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(bool isCompact) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(
            title: 'Recent looks',
            trailing: controller.recentResults.isEmpty
                ? null
                : TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.history),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      textStyle: AppTextStyles.body.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('View all'),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          controller.recentResults.isEmpty
              ? _buildEmptyRecentCard()
              : SizedBox(
                  height: isCompact ? 270 : 294,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.recentResults.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return _buildRecentCard(
                        controller.recentResults[index],
                        isCompact: isCompact,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentCard() {
    return AppSurface(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppGradients.accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_outlined,
              color: AppColors.textOnDark,
              size: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No shots yet',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Analyze or generate an image and your newest results will land here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 170,
            child: _buildPrimaryActionButton(
              label: 'Start review',
              icon: Icons.add_rounded,
              onTap: () => Get.toNamed(AppRoutes.imageEditCreate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCard(
    SavedResultItem item, {
    required bool isCompact,
  }) {
    return GestureDetector(
      onTap: () => controller.openItem(item),
      child: Container(
        width: isCompact ? 214 : 236,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 28,
              offset: Offset(0, 14),
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  File(item.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration:
                          const BoxDecoration(gradient: AppGradients.accent),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 52,
                        color: AppColors.textOnDark,
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.backgroundDark.withValues(alpha: 0.06),
                        AppColors.backgroundDark.withValues(alpha: 0.32),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: AppTag(
                  label: item.badgeLabel,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Row(
                  children: [
                    AppTag(
                      label: _formatDate(item.createdAt),
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.primaryMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
