import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_border_radius.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/cherish_card.dart';
import '../../routes/app_pages.dart';

/// Home Page - Community Square (Keeyo Community Layout)
/// Shows user-generated content with social interactions
/// Enhanced with Erin Flink's unique design elements
class HomePage extends StatefulWidget {
  final bool showBottomNav;

  const HomePage({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const Color _berryPrimary = Color(0xFF9F3F68);
  static const Color _berrySecondary = Color(0xFFB86A86);
  static const Color _berryActive = Color(0xFF8F355B);
  static const Color _navShellStart = Color(0xFFFFFCFE);
  static const Color _navShellEnd = Color(0xFFFFF4F8);
  static const Color _navActiveStart = Color(0xFFFFAFCB);
  static const Color _navActiveEnd = Color(0xFFFFD978);

  late AnimationController _gradientController;
  late AnimationController _particleController;
  bool _isLoading = true;
  List<CherishCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _loadCards();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    _cards = allCherishData;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated gradient background with floating particles
          _buildAnimatedBackground(),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFFFFEAF4),
                expandedHeight: 170,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final topPadding = MediaQuery.of(context).padding.top;
                    final collapsedHeight = kToolbarHeight + topPadding;
                    final isCollapsed =
                        constraints.maxHeight <= collapsedHeight + 12;

                    return FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      title: isCollapsed
                          ? const Text(
                              'Community',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _berryPrimary,
                              ),
                            )
                          : null,
                      background: SafeArea(
                        bottom: false,
                        child: _buildHeader(showSubtitle: !isCollapsed),
                      ),
                    );
                  },
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.textInverse),
                    ),
                  ),
                )
              else if (_cards.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    120,
                  ),
                  sliver: SliverList.builder(
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(_cards[index], index);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNav() : null,
    );
  }

  /// Animated background with floating particles (Erin Flink's unique element)
  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFEAF4),
                Color(0xFFFFCFE4),
                Color(0xFFFFE8B8),
                Color(0xFFFFF7E8),
              ],
            ),
          ),
        ),

        // Floating particles
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _FloatingParticlePainter(_particleController.value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader({bool showSubtitle = true}) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Community',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _berryPrimary,
            ),
          ),
          if (showSubtitle) ...[
            AppSpacing.gapSM,
            Text(
              'Discover amazing happy moments',
              style: AppTextStyles.captionStyle.copyWith(
                color: _berrySecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: _berrySecondary.withOpacity(0.5),
          ),
          AppSpacing.gapMD,
          Text(
            'No posts yet',
            style: AppTextStyles.h3Style.copyWith(
              color: _berryPrimary,
            ),
          ),
          AppSpacing.gapSM,
          Text(
            'Be the first to share your happy moment!',
            style: AppTextStyles.captionStyle.copyWith(
              color: _berrySecondary.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(CherishCard card, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: GestureDetector(
                onTap: () => AppRoutes.toDetail(card),
                child: _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero image with subtle gradient overlay
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppBorderRadius.lg),
                            ),
                            child: Image.asset(
                              _resolveAssetPath(card.assetImg),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: AppColors.primaryGradient
                                          .map((c) => c.withOpacity(0.3))
                                          .toList(),
                                    ),
                                  ),
                                  child: const Icon(Icons.image,
                                      size: 48, color: AppColors.textSecondary),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.22),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: AppSpacing.paddingMD,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSpacing.gapSM,
                            Text(
                              card.meta.oneLineMoment,
                              style: AppTextStyles.h3Style.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _berryPrimary,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpacing.gapSM,
                            if (card.visualPoetry.cherishTags.isNotEmpty)
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: card.visualPoetry.cherishTags
                                    .take(3)
                                    .map((tag) => _buildTagChip(tag))
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: AppBorderRadius.borderRadiusLG,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.borderRadiusLG,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.78),
                Colors.white.withOpacity(0.62),
                Colors.white.withOpacity(0.50),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.72),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.borderRadiusLG,
              color: Colors.white.withOpacity(0.22),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  String _resolveAssetPath(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('assets/')) return trimmed;
    final match = RegExp(r'^A\.assets_minne_(\d+)$').firstMatch(trimmed);
    if (match != null) return 'assets/minne/${match.group(1)}.jpg';
    return trimmed;
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.34),
        borderRadius: AppBorderRadius.borderRadiusSM,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: AppTextStyles.smallStyle.copyWith(
          color: _berrySecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_navShellStart, _navShellEnd],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.82),
              ),
              boxShadow: [
                BoxShadow(
                  color: _berrySecondary.withOpacity(0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
                ...AppShadows.shadowSM,
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(Icons.home, 'Home', true),
                _buildNavIcon(Icons.add_circle_outline, 'Create', false),
                _buildNavIcon(Icons.history, 'History', false),
                _buildNavIcon(Icons.person_outline, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (label == 'Create') {
          AppRoutes.toCreate();
        } else if (label == 'History') {
          AppRoutes.toHistory();
        } else if (label == 'Profile') {
          AppRoutes.toProfile();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: isActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [_navActiveStart, _navActiveEnd],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _navActiveStart.withOpacity(0.26),
                    blurRadius: 10,
                    offset: const Offset(-2, 4),
                  ),
                  BoxShadow(
                    color: _navActiveEnd.withOpacity(0.36),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? _berryActive : _berrySecondary,
            ),
            AppSpacing.gapXS,
            Text(
              label,
              style: AppTextStyles.smallStyle.copyWith(
                color: isActive ? _berryActive : _berrySecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/// Custom painter for floating particles (Erin Flink's unique design element)
class _FloatingParticlePainter extends CustomPainter {
  final double animationValue;

  _FloatingParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final particles = [
      // Position, size, speed, color opacity
      {'x': 0.1, 'y': 0.2, 'size': 4.0, 'speed': 0.3, 'opacity': 0.15},
      {'x': 0.3, 'y': 0.5, 'size': 6.0, 'speed': 0.5, 'opacity': 0.1},
      {'x': 0.5, 'y': 0.3, 'size': 3.0, 'speed': 0.4, 'opacity': 0.12},
      {'x': 0.7, 'y': 0.7, 'size': 5.0, 'speed': 0.6, 'opacity': 0.08},
      {'x': 0.9, 'y': 0.4, 'size': 4.0, 'speed': 0.35, 'opacity': 0.14},
      {'x': 0.2, 'y': 0.8, 'size': 7.0, 'speed': 0.45, 'opacity': 0.1},
      {'x': 0.8, 'y': 0.1, 'size': 3.5, 'speed': 0.55, 'opacity': 0.16},
      {'x': 0.4, 'y': 0.6, 'size': 5.5, 'speed': 0.38, 'opacity': 0.11},
    ];

    for (var particle in particles) {
      final x = (particle['x'] as double) * size.width;
      final baseY = (particle['y'] as double) * size.height;
      final speed = particle['speed'] as double;
      final particleSize = particle['size'] as double;
      final opacity = particle['opacity'] as double;

      // Calculate floating position
      final yOffset = math.sin((animationValue * 2 * math.pi * speed) +
                               (x * 0.01)) *
                      30;
      final y = baseY + yOffset;

      final paint = Paint()
        ..color = AppColors.textInverse.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
