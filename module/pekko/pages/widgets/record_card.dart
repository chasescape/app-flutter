import 'package:flutter/material.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/perfume_record.dart';
import 'perfume_image_resolver.dart';
import 'perfume_artwork.dart';

/// Reusable image-first record card widget.
class RecordCard extends StatelessWidget {
  final PerfumeRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RecordCard({
    super.key,
    required this.record,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final artworkImagePath = resolvePerfumeImage(record);
    final diaryText = _diaryText(record);
    final moodLabel = _moodLabel(record.moodRating);

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.allLarge,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'record-art-${record.id}',
              child: Material(
                color: Colors.transparent,
                child: PerfumeArtwork(
                  title: record.perfumeName,
                  subtitle: record.brand,
                  note: record.noteType,
                  height: 228,
                  imagePath: artworkImagePath,
                  showNoteChip: false,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: AppBorderRadius.allLarge,
                border: Border.all(
                  color: AppColors.accentDark.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diary note',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    diaryText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 24,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${record.perfumeName} · ${record.brand}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _InfoPill(
                  icon: Icons.access_time_rounded,
                  label: record.timeOfDay.displayName,
                ),
                _InfoPill(
                  icon: Icons.mood_rounded,
                  label: moodLabel,
                ),
                _InfoPill(
                  icon: Icons.schedule_rounded,
                  label: record.formattedTime,
                ),
                _InfoPill(
                  icon: Icons.mood_rounded,
                  label: _moodLabel(record.moodRating),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _diaryText(PerfumeRecord record) {
    final note = record.notes?.trim();
    if (note != null && note.isNotEmpty) {
      return _normalizeCopy(note);
    }

    return 'A ${_moodLabel(record.moodRating).toLowerCase()} ${record.timeOfDay.displayName.toLowerCase()} moment.';
  }

  String _moodLabel(int rating) {
    switch (rating.clamp(1, 5)) {
      case 1:
        return 'Low-key';
      case 2:
        return 'Calm';
      case 3:
        return 'Soft';
      case 4:
        return 'Happy';
      case 5:
        return 'Confident';
      default:
        return 'Soft';
    }
  }

  String _normalizeCopy(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return value;
    }

    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
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
        color: AppColors.backgroundElevated,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}
