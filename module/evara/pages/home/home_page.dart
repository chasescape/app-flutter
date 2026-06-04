import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals/signals_flutter.dart';

import '../../../gen_a/A.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/custom_bottom_nav_bar.dart';
import '../../core/widgets/evara_scaffold.dart';
import '../../features/home/home_controller.dart';
import '../create/create_page.dart';
import '../history/history_page.dart';
import '../settings/settings_page.dart';

/// Home page with gallery-first visual browsing.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = Get.put(HomeController());
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      _HomeTab(),
      HistoryPage(),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return EvaraScaffold(
      safeTop: false,
      child: Watch((context) {
        final index = _controller.currentPage.value;
        return IndexedStack(index: index, children: _pages);
      }),
      bottomNavigationBar: Watch((context) {
        final index = _controller.currentPage.value;
        return CustomBottomNavBar(
          currentIndex: index,
          onTap: _controller.onPageChanged,
        );
      }),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return SafeArea(
      bottom: false,
      child: Watch((context) {
        final isLoading = controller.isLoading.value;
        if (isLoading) {
          return AppWidgets.loading(message: 'Curating your beauty gallery...');
        }

        return RefreshIndicator(
          color: AppTheme.primaryMain,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingLg,
                  AppTheme.spacingLg,
                  AppTheme.spacingLg,
                  AppTheme.spacingLg,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildQuickActions(context),
                    const SizedBox(height: AppTheme.spacingXl),
                    _buildRecentSection(controller),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EvaraSectionTitle(
          eyebrow: 'Create',
          title: 'Start with a striking portrait',
          subtitle: 'Fast capture paths designed around the image, not the form.',
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Shoot now',
                subtitle: 'Camera',
                icon: Icons.photo_camera_front_rounded,
                gradient: AppTheme.primaryGradient,
                onTap: () => _navigateToCreate(context, ImageSource.camera),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _ActionCard(
                title: 'Pick a look',
                subtitle: 'Gallery',
                icon: Icons.collections_rounded,
                gradient: AppTheme.accentGradient,
                onTap: () => _navigateToCreate(context, ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToCreate(BuildContext context, ImageSource source) {
    Get.to(() => CreatePage(initialSource: source));
  }

  Widget _buildRecentSection(HomeController controller) {
    return Watch((context) {
      final recent = controller.recentRecords.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppWidgets.sectionHeader(
            'Recent looks',
            action: 'View all',
            onAction: () => controller.onPageChanged(1),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          if (recent.isEmpty)
            AppWidgets.emptyState(
              message: 'No looks yet.\nCapture one photo to start your Evara gallery.',
              icon: '✨',
              onAction: () => _navigateToCreate(context, ImageSource.camera),
              actionText: 'Create first look',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppTheme.spacingMd),
              itemBuilder: (context, index) {
                return _RecentRecordCard(record: recent[index]);
              },
            ),
        ],
      );
    });
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryMain.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.textInverse),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            Text(
              subtitle.toUpperCase(),
              style: TextStyle(
                color: AppTheme.textInverse.withValues(alpha: 0.86),
                fontSize: AppTheme.small,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textInverse,
                fontSize: AppTheme.h3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const _RecentRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final analysis = record['analysis'] as Map<String, dynamic>;
    final imagePath = analysis['imagePath'] as String;
    final styleTags = (analysis['styleTags'] as List).cast<String>();
    final occasionTags = (analysis['occasionTags'] as List).cast<String>();

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.result,
          arguments: {'record': record},
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: AspectRatio(
          aspectRatio: 1.28,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  A.assets_evara_open,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.14),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    occasionTags.isNotEmpty ? occasionTags.first : 'Look',
                    style: const TextStyle(
                      color: AppTheme.textInverse,
                      fontSize: AppTheme.small,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      styleTags.isNotEmpty ? styleTags.first : 'Beauty Edit',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textInverse,
                        fontSize: AppTheme.h3,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    if (styleTags.length > 1) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: styleTags.skip(1).take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: AppTheme.textInverse,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
