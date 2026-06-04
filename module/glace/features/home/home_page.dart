import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/perfume_record.dart';
import '../../services/record_service.dart';
import '../../widgets/glace_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RecordService _recordService = RecordService();
  List<PerfumeRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = _recordService.getAllRecords().take(6).toList();
    });
  }

  void _openDetail(PerfumeRecord record) {
    context.push(
      Routes.recordDetail,
      extra: {
        'record': record,
        'heroTag': 'home-${record.id}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weeklyCount = _recordService.getWeeklyCount();
    final topScent = _recordService.getMostUsedScent() ?? 'Floral';
    final showcaseRecords = _records.take(4).toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 92),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GlaceSectionTitle(
              title: 'Glace',
              subtitle: 'Scent journal',
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 18),
            GlaceSurfaceCard(
              color: Colors.white.withValues(alpha: 0.82),
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(30),
              child: Column(
                children: [
                  _QuickActionCard(
                    icon: Icons.edit_note_rounded,
                    title: 'New entry',
                    subtitle: 'Add today',
                    onTap: () => context.go(Routes.record),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionCard(
                    icon: Icons.grid_view_rounded,
                    title: 'History',
                    subtitle: 'View records',
                    onTap: () => context.push(Routes.history),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GlaceMetricCard(
                          eyebrow: 'THIS WEEK',
                          value: '$weeklyCount',
                          caption: 'entries',
                          light: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlaceMetricCard(
                          eyebrow: 'TOP FAMILY',
                          value: topScent,
                          caption: 'favorite',
                          light: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (showcaseRecords.isEmpty)
              GlaceSurfaceCard(
                color: const Color(0xFFFFFCEB),
                padding: const EdgeInsets.all(14),
                borderRadius: BorderRadius.circular(30),
                onTap: () => context.go(Routes.record),
                child: Column(
                  children: [
                    _HomeEmptyHero(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Start your scent gallery',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add 3 to 4 perfume records and your homepage becomes a visual journal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  _ShowcaseCard(
                    record: showcaseRecords.first,
                    height: 272,
                    heroTag: 'home-${showcaseRecords.first.id}',
                    onTap: () => _openDetail(showcaseRecords.first),
                  ),
                  if (showcaseRecords.length > 1) ...[
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ShowcaseCard(
                            record: showcaseRecords[1],
                            height: 208,
                            heroTag: 'home-${showcaseRecords[1].id}',
                            onTap: () => _openDetail(showcaseRecords[1]),
                          ),
                        ),
                        if (showcaseRecords.length > 2) ...[
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              children: [
                                _ShowcaseCard(
                                  record: showcaseRecords[2],
                                  height: showcaseRecords.length > 3 ? 96 : 208,
                                  heroTag: 'home-${showcaseRecords[2].id}',
                                  compact: showcaseRecords.length > 3,
                                  onTap: () => _openDetail(showcaseRecords[2]),
                                ),
                                if (showcaseRecords.length > 3) ...[
                                  const SizedBox(height: 14),
                                  _ShowcaseCard(
                                    record: showcaseRecords[3],
                                    height: 96,
                                    heroTag: 'home-${showcaseRecords[3].id}',
                                    compact: true,
                                    onTap: () =>
                                        _openDetail(showcaseRecords[3]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEE73),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  final PerfumeRecord record;
  final double height;
  final String heroTag;
  final bool compact;
  final VoidCallback onTap;

  const _ShowcaseCard({
    required this.record,
    required this.height,
    required this.heroTag,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            GlaceHeroImage(
              imagePath: record.photoPath,
              height: height,
              borderRadius: const BorderRadius.all(Radius.circular(28)),
              showGradientOverlay: true,
            ),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  '${record.createdAt.month}/${record.createdAt.day}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: compact
                        ? const SizedBox.shrink()
                        : Text(
                            record.perfumeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (!compact) const SizedBox(width: 10),
                  Container(
                    width: compact ? 38 : 44,
                    height: compact ? 38 : 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.26),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      color: Colors.white,
                      size: 20,
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
}

class _HomeEmptyHero extends StatelessWidget {
  final BorderRadius borderRadius;

  const _HomeEmptyHero({required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.68),
            Colors.white.withValues(alpha: 0.46),
            AppColors.surfaceTint.withValues(alpha: 0.72),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.add_photo_alternate_rounded,
            color: AppColors.primary,
            size: 38,
          ),
        ),
      ),
    );
  }
}
