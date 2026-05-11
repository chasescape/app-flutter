import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenbo/lenbo/app/routes/app_routes.dart';
import 'package:lenbo/lenbo/app/widgets/ripple_tap_effect.dart';
import 'package:lenbo/lenbo/core/theme/app_colors.dart';
import 'package:lenbo/lenbo/core/theme/app_spacing.dart';
import 'package:lenbo/lenbo/core/theme/app_theme.dart';
import 'package:lenbo/lenbo/data/mock/mock_data.dart';
import 'package:lenbo/lenbo/data/models/plant_analysis.dart';
import 'package:lenbo/lenbo/features/create/create_page.dart';
import 'package:lenbo/lenbo/features/history/history_page.dart';
import 'package:lenbo/lenbo/features/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    _CreateTab(),
    _HistoryTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPinkGlow.withAlpha(38),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(color: AppColors.cardBorderLight.withAlpha(77), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppColors.secondaryMain,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 24),
              activeIcon: Icon(Icons.add_circle, size: 24),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined, size: 24),
              activeIcon: Icon(Icons.history, size: 24),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final featuredPlants = allPlantData.take(3).toList();
    final featuredImagePaths = featuredPlants.map((plant) => plant.assetImg).toSet();
    final trendingPlants =
        allPlantData.where((plant) => !featuredImagePaths.contains(plant.assetImg)).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bgPrimary,
                  AppColors.accentMain.withAlpha(26),
                  AppColors.bgPrimary,
                ],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              const SliverAppBar(
                pinned: true,
                backgroundColor: Color(0xFFFFF2F8),
                foregroundColor: AppColors.textPrimary,
                surfaceTintColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Text(
                  'PlantCare',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: AppTheme.pinkTextGradient.createShader,
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: AppTheme.pinkTextGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FeaturedPlantCard(plant: featuredPlants[index]),
                    ),
                    childCount: featuredPlants.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: AppTheme.pinkTextGradient.createShader,
                        child: const Text(
                          'Trending',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: AppTheme.pinkTextGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _PlantCard(plant: trendingPlants[index]),
                    childCount: trendingPlants.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedPlantCard extends StatelessWidget {
  final PlantAnalysis plant;
  const _FeaturedPlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'featured_${plant.assetImg}';

    return RippleTapEffect(
      onTap: () => _showImagePreview(context, plant, heroTag),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.secondaryMain.withAlpha(36), width: 0.9),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPinkGlow.withAlpha(24),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                  tag: heroTag,
                  child: Image.asset(
                    plant.assetImg,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 28, 14, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(150),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant.plantId.commonName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plant.plantId.scientificName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withAlpha(210),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _FeaturedChip(
                        text: plant.healthCheck.status,
                        color: _healthColor(plant.healthCheck.status),
                        icon: _healthIcon(plant.healthCheck.status),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(235),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: AppColors.cardBorderLight.withAlpha(110), width: 0.6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in_rounded, size: 15, color: AppColors.secondaryMain),
                      SizedBox(width: 4),
                      Text(
                        'Zoom',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryMain,
                          fontWeight: FontWeight.w700,
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
    );
  }

  IconData _healthIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Icons.check_circle;
      case 'needs attention':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _healthColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return AppColors.success;
      case 'needs attention':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }
}

class _FeaturedChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _FeaturedChip({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withAlpha(80), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

void _showImagePreview(BuildContext context, PlantAnalysis plant, String heroTag) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withAlpha(220),
    builder: (_) => _ImagePreviewDialog(
      heroTag: heroTag,
      title: plant.plantId.commonName,
      imagePath: plant.assetImg,
    ),
  );
}

class _ImagePreviewDialog extends StatelessWidget {
  final String heroTag;
  final String title;
  final String imagePath;

  const _ImagePreviewDialog({
    required this.heroTag,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: const ColoredBox(
                  color: Colors.transparent,
                  child: SizedBox.expand(),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: InteractiveViewer(
                    minScale: 0.9,
                    maxScale: 4.0,
                    child: Image.asset(imagePath, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withAlpha(240),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RoundIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(30),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white.withAlpha(240), size: 20),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final PlantAnalysis plant;
  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    return RippleTapEffect(
      onTap: () => AppRoutes.toDetail(plant),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.cardBorderLight.withAlpha(128), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPinkGlow.withAlpha(31),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with subtle neon overlay at bottom
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      plant.assetImg,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    // Gradient overlay at bottom for text readability
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.primaryMain.withAlpha(77),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.plantId.commonName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plant.plantId.scientificName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _healthColor(plant.healthCheck.status).withAlpha(26),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _healthIcon(plant.healthCheck.status),
                              size: 11,
                              color: _healthColor(plant.healthCheck.status),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              plant.healthCheck.status,
                              style: TextStyle(
                                fontSize: 10,
                                color: _healthColor(plant.healthCheck.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(plant.plantId.identificationConfidence * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryMain,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _healthIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Icons.check_circle;
      case 'needs attention':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _healthColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return AppColors.success;
      case 'needs attention':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }
}

class _CreateTab extends StatelessWidget {
  const _CreateTab();

  @override
  Widget build(BuildContext context) {
    return const CreatePage();
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return const HistoryPage();
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

class HistoryPagePlaceholder extends StatelessWidget {
  const HistoryPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.primaryMain,
        foregroundColor: AppColors.textInverse,
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryMain.withAlpha(15),
                border: Border.all(color: AppColors.cardBorderLight.withAlpha(77), width: 0.5),
              ),
              child: Icon(Icons.history, size: 36, color: AppColors.secondaryMain.withAlpha(102)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No history yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start analyzing plants to see results here',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
