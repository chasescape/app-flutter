import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/history_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/perfume_record.dart';
import '../widgets/perfume_image_resolver.dart';
import '../widgets/perfume_artwork.dart';

class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final record = _resolveRecord();
    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scent Detail')),
        body: Center(
          child: Text(
            'This scent entry could not be found.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }
    final artworkImagePath = resolvePerfumeImage(record);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 420,
            pinned: true,
            backgroundColor: AppColors.backgroundPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primary,
                          AppColors.backgroundPrimary,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    top: 90,
                    child: PerfumeStemDecoration(
                      height: 240,
                      color: AppColors.secondary,
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _CircleButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: () => Get.back(),
                              ),
                              const Spacer(),
                              _CircleButton(
                                icon: Icons.ios_share_outlined,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const Spacer(),
                          Hero(
                            tag: 'record-art-${record.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: PerfumeArtwork(
                                title: record.perfumeName,
                                subtitle: record.brand,
                                note: record.noteType,
                                height: 270,
                                dark: true,
                                imagePath: artworkImagePath,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                  Text(
                    record.brand.toUpperCase(),
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    record.perfumeName,
                    style: AppTextStyles.display.copyWith(fontSize: 34),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _summary(record),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _DetailChip(label: record.noteType.displayName),
                      _DetailChip(label: record.scene.displayName),
                      _DetailChip(label: record.season.displayName),
                      _DetailChip(label: record.timeOfDay.displayName),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: _NumberStat(
                          value: '${record.longevity}',
                          label: 'Hours worn',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _NumberStat(
                          value: '${record.moodRating}',
                          label: 'Mood score',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _NumberStat(
                          value: '${record.compliments ?? 0}',
                          label: 'Praise',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DetailSection(
                    title: 'Entry Notes',
                    child: Text(
                      record.notes?.isNotEmpty == true
                          ? record.notes!
                          : 'A quiet, polished fragrance memory with soft detail and a clear impression.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DetailSection(
                    title: 'Moment',
                    child: Column(
                      children: [
                        _MetaRow(label: 'Date', value: record.formattedDate),
                        _MetaRow(label: 'Time', value: record.formattedTime),
                        _MetaRow(
                            label: 'Weather',
                            value: record.weather ?? 'Soft daylight'),
                        _MetaRow(
                            label: 'Outfit',
                            value: record.outfit ?? 'Clean essentials'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Back to diary'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PerfumeRecord? _resolveRecord() {
    final id = Get.parameters['id'];
    if (id == null) return null;

    if (Get.isRegistered<HistoryController>()) {
      final controller = Get.find<HistoryController>();
      for (final record in controller.records) {
        if (record.id == id) return record;
      }
    }

    return null;
  }

  String _summary(PerfumeRecord record) {
    return '${record.scene.displayName} mood, ${record.noteType.displayName.toLowerCase()} profile, worn on ${record.formattedDate}.';
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.textInverse.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.textInverse.withValues(alpha: 0.16),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textInverse,
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;

  const _DetailChip({
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
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.backgroundTertiary,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium,
      ),
    );
  }
}

class _NumberStat extends StatelessWidget {
  final String value;
  final String label;

  const _NumberStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.cardDecoration(color: AppColors.backgroundElevated),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppTheme.cardDecoration(color: AppColors.backgroundElevated),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.small,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
