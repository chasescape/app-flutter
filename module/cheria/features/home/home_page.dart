import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme.dart';
import '../../app/state/app_state.dart';
import '../../app/state/app_state_provider.dart';
import '../../models/novel.dart';
import '../../router/app_router.dart';
import '../../widgets/animations/bounce_in_animation.dart';
import '../../widgets/visuals/sunny_visuals.dart';

/// Home Page
/// Shows quick actions, recent novels, reading stats, and coin balance
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return Scaffold(
      body: SunnyPage(
        showTopDecoration: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(appState: appState),
              const SizedBox(height: AppSpacing.lg),
              _QuickAddCard(),
              const SizedBox(height: AppSpacing.lg),
              _ReadingStatsCard(appState: appState),
              const SizedBox(height: AppSpacing.lg),
              _RecentNovelsSection(appState: appState),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppState appState;

  const _Header({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CheriaLogoMark(size: 52),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cheria',
                  style: AppTypography.getH2TextStyle(
                    const Color(AppColors.textPrimary),
                  ).copyWith(fontWeight: AppTypography.bold),
                ),
                Text(
                  'Bright story shelf',
                  style: AppTypography.getCaptionTextStyle(
                    const Color(AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.coinStore),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: const Color(AppColors.cardElevated),
              borderRadius: AppBorderRadius.allFull,
              border: Border.all(
                color: const Color(AppColors.textInverse),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Color(AppColors.primaryMain),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${appState.coinBalance}',
                  style: AppTypography.getCaptionTextStyle(
                    const Color(AppColors.textPrimary),
                  ).copyWith(
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.editor),
        child: Container(
          height: 148,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(AppColors.backgroundSecondary),
                Color(AppColors.secondaryMain),
              ],
            ),
            borderRadius: AppBorderRadius.allLG,
            border: Border.all(
              color: const Color(AppColors.cardElevated),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(AppColors.accentMain).withOpacity(0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(AppColors.textInverse).withOpacity(0.22),
                  ),
                ),
              ),
              Row(
                children: [
                  const CheriaLogoMark(size: 70, withShadow: false),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Novel',
                          style: AppTypography.getH2TextStyle(
                            const Color(AppColors.textInverse),
                          ).copyWith(
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Drop a story in',
                          style: AppTypography.getCaptionTextStyle(
                            const Color(AppColors.textInverse),
                          ).copyWith(
                            color: const Color(AppColors.textInverse)
                                .withOpacity(0.86),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(AppColors.textInverse),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingStatsCard extends StatelessWidget {
  final AppState appState;

  const _ReadingStatsCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final stats = appState.readingStats;

    return BounceInAnimation(
      delay: const Duration(milliseconds: 300),
      child: SunnyCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Color(AppColors.primaryMain),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  "This Month's Reading",
                  style: AppTypography.getH3TextStyle(
                    const Color(AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.menu_book,
                  label: 'Finished',
                  value: '${stats?.currentMonthBooks ?? 0}',
                  color: const Color(AppColors.accentMain),
                ),
                _StatItem(
                  icon: Icons.schedule,
                  label: 'Reading',
                  value: '${stats?.readingBooks ?? 0}',
                  color: const Color(AppColors.primaryMain),
                ),
                _StatItem(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: stats?.totalReadingTimeDisplay ?? '0m',
                  color: const Color(AppColors.primaryLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: AppBorderRadius.allMD,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.getH3TextStyle(
            const Color(AppColors.textPrimary),
          ).copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.getSmallTextStyle(
            const Color(AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _RecentNovelsSection extends StatelessWidget {
  final AppState appState;

  const _RecentNovelsSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final recentNovels = appState.getRecentNovels();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Color(AppColors.primaryMain),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Recently Read',
                  style: AppTypography.getH3TextStyle(
                    const Color(AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.library),
              style: TextButton.styleFrom(
                foregroundColor: const Color(AppColors.primaryMain),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (recentNovels.isEmpty)
          _EmptyState()
        else
          SizedBox(
            height: 274,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: recentNovels.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                return _NovelCard(novel: recentNovels[index]);
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SunnyCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Color(AppColors.primaryMain),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No reading records yet',
              style: AppTypography.getH3TextStyle(
                const Color(AppColors.textPrimary),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start your reading log',
              style: AppTypography.getCaptionTextStyle(
                const Color(AppColors.textSecondary),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NovelCard extends StatelessWidget {
  final Novel novel;

  const _NovelCard({required this.novel});

  @override
  Widget build(BuildContext context) {
    return BounceInAnimation(
      delay: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.editorDetail(novel.id)),
        child: SizedBox(
          width: 166,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NovelCoverArt(
                novel: novel,
                width: 166,
                height: 210,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                novel.title,
                style: AppTypography.getCaptionTextStyle(
                  const Color(AppColors.textPrimary),
                ).copyWith(fontWeight: AppTypography.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      novel.status.label,
                      style: AppTypography.getSmallTextStyle(
                        const Color(AppColors.textSecondary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(novel.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(NovelStatus status) {
    switch (status) {
      case NovelStatus.toRead:
        return const Color(AppColors.statusToRead);
      case NovelStatus.reading:
        return const Color(AppColors.statusReading);
      case NovelStatus.finished:
        return const Color(AppColors.statusFinished);
      case NovelStatus.paused:
        return const Color(AppColors.statusPaused);
      case NovelStatus.dropped:
        return const Color(AppColors.statusDropped);
    }
  }
}
