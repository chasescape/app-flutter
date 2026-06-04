import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/perfume_record.dart';
import '../../widgets/glace_ui.dart';

class RecordDetailPage extends StatelessWidget {
  final PerfumeRecord record;
  final Object heroTag;

  const RecordDetailPage({
    super.key,
    required this.record,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GlaceScaffold(
      safeArea: false,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: heroTag,
                          child: GlaceHeroImage(
                            imagePath: record.photoPath,
                            height: 480,
                            borderRadius: BorderRadius.circular(36),
                            showGradientOverlay: false,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            GlaceChipPill(
                              icon: Icons.local_florist_rounded,
                              label: record.scentFamily,
                            ),
                            GlaceChipPill(
                              icon: Icons.local_fire_department_rounded,
                              label: record.occasion,
                            ),
                            if ((record.mood ?? '').trim().isNotEmpty)
                              GlaceChipPill(
                                icon: Icons.favorite_border_rounded,
                                label: record.mood!,
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        GlaceSurfaceCard(
                          color: Colors.white.withValues(alpha: 0.80),
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.perfumeName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.7,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                record.brandName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoTile(
                                      label: 'Captured',
                                      value:
                                          '${record.createdAt.year}.${record.createdAt.month.toString().padLeft(2, '0')}.${record.createdAt.day.toString().padLeft(2, '0')}',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoTile(
                                      label: 'Rating',
                                      value: '${record.rating}/5',
                                    ),
                                  ),
                                ],
                              ),
                              if ((record.note ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 18),
                                const Text(
                                  'Mood note',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHighlight,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xl),
                                  ),
                                  child: Text(
                                    record.note!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.55,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 16,
              child: _TopButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: 16,
              left: 72,
              right: 72,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    record.brandName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.7),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 16,
              child: _TopButton(
                icon: Icons.favorite_border_rounded,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
