import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/main_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/perfume_record.dart';
import '../widgets/perfume_image_resolver.dart';
import '../widgets/perfume_artwork.dart';
import '../widgets/record_card.dart';

/// Home page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final mainController = Get.find<MainController>();
    final todayLabel = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      body: Obx(() {
        final featured = controller.recentRecords.isNotEmpty
            ? controller.recentRecords.first
            : null;
        final recentArchive = featured == null
            ? controller.recentRecords.take(2).toList()
            : controller.recentRecords.skip(1).take(2).toList();
        final insightsSubtitle = controller.recentRecords.isEmpty
            ? 'Watch your wearing habits take shape'
            : '${controller.favoriteNoteLabel} feels most like you';
        final shouldGuideCollection = controller.ownedBottleCount == 0;

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _HomeHeader(
                  todayLabel: todayLabel,
                  bottleCount: controller.ownedBottleCount,
                  monthEntries: controller.entriesThisMonth,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ComposerCard(
                        onTap: () => mainController.changeTab(1),
                        eyebrow: shouldGuideCollection
                            ? 'BUILD COLLECTION'
                            : 'UPDATE COLLECTION',
                        title: shouldGuideCollection
                            ? 'Start with your bottles'
                            : 'Add another bottle',
                        subtitle: shouldGuideCollection
                            ? 'Save the perfumes you own first, then your diary can stay fast and simple.'
                            : 'Keep your collection current so every wear note starts with the right fragrance.',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeader(
                        title: 'Latest Memory',
                        actionLabel:
                            featured == null ? 'Open diary' : 'Open diary',
                        onAction: featured == null
                            ? () => mainController.changeTab(1)
                            : () => mainController.changeTab(1),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _LatestMemoryCard(
                        featured: featured,
                        onTap: featured == null
                            ? () => Get.toNamed(AppRoutes.record)
                            : () => _viewRecordDetail(featured),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _QuickRouteCard(
                        title: 'Insights',
                        subtitle: insightsSubtitle,
                        icon: Icons.bar_chart_rounded,
                        onTap: () => mainController.changeTab(3),
                        highlighted: true,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeader(
                        title: 'Recent Diary',
                        actionLabel: 'See all',
                        onAction: () => mainController.changeTab(2),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (controller.isLoading.value &&
                          controller.recentRecords.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (controller.recentRecords.isEmpty)
                        _EmptyState(
                          icon: Icons.auto_stories_outlined,
                          title: 'Your diary is still quiet',
                          message:
                              'Save your bottles in Collection first, then your diary entries will be much faster to create.',
                          actionLabel: 'Open collection',
                          onAction: () => mainController.changeTab(1),
                        )
                      else if (recentArchive.isEmpty)
                        _ArchiveHintCard(
                          onTap: () => mainController.changeTab(2),
                        )
                      else
                        Column(
                          children: recentArchive.map((record) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: RecordCard(
                                record: record,
                                onTap: () => _viewRecordDetail(record),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _viewRecordDetail(PerfumeRecord record) {
    Get.toNamed('${AppRoutes.recordDetail}?id=${record.id}');
  }
}

class _HomeHeader extends StatelessWidget {
  final String todayLabel;
  final int bottleCount;
  final int monthEntries;

  const _HomeHeader({
    required this.todayLabel,
    required this.bottleCount,
    required this.monthEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -56,
            right: -26,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -34,
            bottom: -62,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todayLabel.toUpperCase(),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textInverse.withValues(alpha: 0.74),
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'What did today smell like?',
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.textInverse,
                      fontSize: 34,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'A quiet home for the fragrances you wore, the mood you kept, and the note you want to remember.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textInverse.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      _TopBadge(
                        icon: Icons.local_florist_outlined,
                        label: bottleCount == 0
                            ? 'No bottles yet'
                            : '$bottleCount bottles',
                        dark: true,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _TopBadge(
                        icon: Icons.auto_stories_outlined,
                        label: monthEntries == 0
                            ? 'Fresh month'
                            : '$monthEntries this month',
                        dark: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dark;

  const _TopBadge({
    required this.icon,
    required this.label,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = dark
        ? Colors.white.withValues(alpha: 0.16)
        : AppColors.backgroundTertiary;
    final backgroundColor = dark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.backgroundElevated;
    final iconColor = dark ? AppColors.textInverse : AppColors.primary;
    final textColor = dark
        ? AppColors.textInverse.withValues(alpha: 0.88)
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerCard extends StatelessWidget {
  final VoidCallback onTap;
  final String eyebrow;
  final String title;
  final String subtitle;

  const _ComposerCard({
    required this.onTap,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allLarge,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.allLarge,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 24,
              offset: Offset(0, 16),
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
                    eyebrow,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textInverse.withValues(alpha: 0.74),
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textInverse,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textInverse.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textInverse,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestMemoryCard extends StatelessWidget {
  final PerfumeRecord? featured;
  final VoidCallback onTap;

  const _LatestMemoryCard({
    required this.featured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (featured == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.photo_album_outlined,
              size: 28,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No memory saved yet',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your latest entry will live here with its image, mood, and one line worth remembering.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final artworkImagePath = resolvePerfumeImage(featured!);
    final headline = _headline(featured!);

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allLarge,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PerfumeArtwork(
              title: featured!.perfumeName,
              subtitle: featured!.brand,
              note: featured!.noteType,
              height: 244,
              imagePath: artworkImagePath,
              showNoteChip: false,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              headline,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h2.copyWith(
                fontSize: 26,
                height: 1.25,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${featured!.perfumeName} · ${featured!.brand}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _MetaPill(
                  icon: Icons.wb_twilight_outlined,
                  label: featured!.timeOfDay.displayName,
                ),
                _MetaPill(
                  icon: Icons.calendar_today_outlined,
                  label: featured!.formattedDate,
                ),
                _MetaPill(
                  icon: Icons.self_improvement_outlined,
                  label: featured!.scene.displayName,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _headline(PerfumeRecord record) {
    final note = record.notes?.trim();
    if (note != null && note.isNotEmpty) {
      final normalized = note.replaceAll(RegExp(r'\s+'), ' ').trim();
      return normalized[0].toUpperCase() + normalized.substring(1);
    }

    return 'A ${record.timeOfDay.displayName.toLowerCase()} memory worth keeping.';
  }
}

class _QuickRouteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  const _QuickRouteCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allLarge,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: highlighted
            ? AppTheme.framedCardDecoration(
                color: AppColors.cardBackgroundSecondary,
              )
            : AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: highlighted
                    ? AppColors.backgroundElevated.withValues(alpha: 0.9)
                    : AppColors.backgroundSecondary,
                borderRadius: AppBorderRadius.allMedium,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.backgroundTertiary,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h2),
        TextButton(
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _ArchiveHintCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ArchiveHintCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppTheme.cardDecoration(
        color: AppColors.backgroundElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your newest note is already above',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Keep logging small moments and the diary feed will quietly grow from here.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onTap,
            child: const Text('Open full diary'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingXL,
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Icon(
            icon,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
