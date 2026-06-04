import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../gen_a/A.dart';
import '../../managers/coins_manager.dart';
import '../../models/app_constants.dart';
import '../../models/tone_record.dart';
import '../../providers/app_state.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/glido_ui.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _RecordsTab(),
    _EditorTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final recentRecords = appState.getRecentRecords(18);
        final featuredRecord =
            recentRecords.isNotEmpty ? recentRecords.first : null;
        final remainingRecords = recentRecords.length > 1
            ? recentRecords.sublist(1)
            : <ToneRecord>[];

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Glido'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: AppTheme.spacingMd),
                child: _CoinBalancePill(),
              ),
            ],
          ),
          body: GlidoPageBackground(
            topSafeArea: true,
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (featuredRecord == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacingMd,
                        AppTheme.spacingMd,
                        AppTheme.spacingMd,
                        270,
                      ),
                      child: _HomeEmptyState(
                        freeCredits: appState.freeCredits,
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacingMd,
                        AppTheme.spacingMd,
                        AppTheme.spacingMd,
                        0,
                      ),
                      child: _FeaturedRecordCard(record: featuredRecord),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacingMd,
                        AppTheme.spacingXl,
                        AppTheme.spacingMd,
                        AppTheme.spacingMd,
                      ),
                      child: GlidoSectionHeader(
                        title: 'Recent frames',
                        trailing: TextButton(
                          onPressed: () => context.push(AppRoutes.library),
                          child: const Text('All'),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingMd,
                      0,
                      AppTheme.spacingMd,
                      128,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _CompactRecordCard(
                            record: remainingRecords[index],
                          );
                        },
                        childCount: remainingRecords.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppTheme.spacingMd,
                        mainAxisSpacing: AppTheme.spacingMd,
                        childAspectRatio: 0.7,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  final int freeCredits;

  const _HomeEmptyState({
    required this.freeCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlidoSurface(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GlidoBrandLockup(
              badgeSize: 108,
              subtitle:
                  'Build a visual library that keeps the photo in charge.',
            ),
            const SizedBox(height: AppTheme.spacingXl),
            Text(
              'Your home feed is ready for large images, bold covers, and light metadata.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            if (freeCredits > 0)
              GlidoPill(
                label: '$freeCredits free card credits waiting',
                icon: Icons.card_giftcard_rounded,
                gradient: AppTheme.limeGradient,
              ),
            const SizedBox(height: AppTheme.spacingLg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.editor),
                child: const Text('Make the first card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedRecordCard extends StatelessWidget {
  final ToneRecord record;

  const _FeaturedRecordCard({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRoutes.toDetail(context, record.id),
      child: GlidoSurface(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlidoRecordImage(
              imagePath: record.afterImagePath,
              height: 336,
              heroTag: glidoRecordHeroTag(record.id),
              placeholderLabel: 'Add an after image to feature this card',
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              record.presetName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: [
                GlidoPill(
                  label: record.sceneTag,
                  gradient: AppTheme.highlightGradient,
                ),
                GlidoPill(
                  label: record.mainMood,
                  color: AppTheme.accentLight,
                ),
                GlidoPill(
                  label: _formatShortDate(record.lastUpdated),
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactRecordCard extends StatelessWidget {
  final ToneRecord record;

  const _CompactRecordCard({
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRoutes.toDetail(context, record.id),
      child: GlidoSurface(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GlidoRecordImage(
                imagePath: record.afterImagePath,
                heroTag: glidoRecordHeroTag(record.id),
                placeholderLabel: 'Image first',
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              record.presetName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.sceneTag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                  _formatShortDate(record.lastUpdated),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorTab extends StatelessWidget {
  const _EditorTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GlidoPageBackground(
            topSafeArea: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMd,
                AppTheme.spacingMd,
                AppTheme.spacingMd,
                278,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GlidoSectionHeader(
                    title: 'Lead with the image',
                    subtitle: 'Give the photo room. Keep details light.',
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  GlidoSurface(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppTheme.radiusLarge),
                          ),
                          child: AspectRatio(
                            aspectRatio: 1.12,
                            child: Image.asset(
                              A.assets_glido_open,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use a bold cover, a short label, and light notes.',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              Wrap(
                                spacing: AppTheme.spacingSm,
                                runSpacing: AppTheme.spacingSm,
                                children: [
                                  const GlidoPill(
                                    label:
                                        '${AppConstants.costPerRecord} coins per save',
                                    gradient: AppTheme.highlightGradient,
                                  ),
                                  if (appState.freeCredits > 0)
                                    GlidoPill(
                                      label:
                                          '${appState.freeCredits} free credits left',
                                      gradient: AppTheme.limeGradient,
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingLg),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.editor),
                                  child: const Text('Open editor'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  const IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: GlidoSurface(
                            child: _CreateTip(
                              icon: Icons.photo_camera_back_outlined,
                              title: 'Show the result',
                              subtitle: 'Let the final image take the lead.',
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingMd),
                        Expanded(
                          child: GlidoSurface(
                            child: _CreateTip(
                              icon: Icons.notes_rounded,
                              title: 'Keep text short',
                              subtitle: 'A title and a few tags are enough.',
                            ),
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
      },
    );
  }
}

class _CreateTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CreateTip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppTheme.highlightGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              icon,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

class _CoinBalancePill extends StatelessWidget {
  const _CoinBalancePill();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CoinsManager(),
      builder: (context, _) {
        return InkWell(
          onTap: () => context.push(AppRoutes.coinStore),
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          child: GlidoPill(
            label: '${CoinsManager().balance}',
            icon: Icons.monetization_on_rounded,
            gradient: AppTheme.highlightGradient,
          ),
        );
      },
    );
  }
}

String _formatShortDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays <= 0) {
    return 'Today';
  }
  if (diff.inDays == 1) {
    return 'Yesterday';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }
  return '${date.month}/${date.day}';
}
