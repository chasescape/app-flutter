import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';
import 'package:crushi/crushi/core/widgets/pulse_animation.dart';
import 'package:crushi/crushi/core/widgets/diffuse_background.dart';
import 'package:crushi/crushi/core/widgets/glass_card.dart';
import 'package:crushi/crushi/core/router/global_router.dart';
import 'package:crushi/crushi/data/mock/stoic/mock_data.dart';
import 'package:crushi/crushi/data/models/stoic_card.dart';
import 'package:crushi/crushi/data/generated_history_store.dart';
import 'package:crushi/crushi/env/app_env.dart';
import 'package:crushi/crushi/light_handle.dart';
import 'package:crushi/gen_a/A.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  static const Color _shellBg = Color(0xFF070B16);

  final List<Widget> _pages = const [
    _ExploreTab(),
    _HistoryTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _shellBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () => GlobalRouter.I.goToCreate(),
        backgroundColor: AppColors.primaryMain,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.add, size: 28),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _shellBg,
        selectedItemColor: AppColors.primaryMain,
        unselectedItemColor: const Color(0x80FFFFFF),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ExploreTab extends StatefulWidget {
  const _ExploreTab();

  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab> {
  int _currentPage = 0;
  static const int _pageSize = 5;
  final List<StoicCard> _displayCards = [];

  static const Color _bgBase = Color(0xFF070B16);

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  void _loadNextPage() {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, allStoicCardData.length);
    if (start >= allStoicCardData.length) return;
    setState(() {
      _displayCards.addAll(allStoicCardData.sublist(start, end));
      _currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: DiffuseBackground(base: _bgBase)),
        CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 72,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              titleSpacing: AppSpacing.lg,
              title: Row(
                children: [
                  PulseAnimation(
                    minScale: 0.96,
                    maxScale: 1.04,
                    duration: const Duration(milliseconds: 2200),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryMain, Color(0xFFFF8A00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crushi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: AppColors.textInverse,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Discover wisdom within',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.2,
                            color: Color(0xCCFFFFFF),
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _bgBase.withOpacity(0.95),
                      _bgBase.withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Explore',
                  style: AppTypography.h2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textInverse,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Tap a scene to read and reflect. Create your own when you’re ready.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textInverse.withOpacity(0.72),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index == _displayCards.length) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_currentPage * _pageSize < allStoicCardData.length) {
                          _loadNextPage();
                        }
                      });
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final card = _displayCards[index];
                    return _buildStoicCard(context, card);
                  },
                  childCount: _displayCards.length < allStoicCardData.length
                      ? _displayCards.length + 1
                      : _displayCards.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ],
    );
  }

  Widget _buildStoicCard(BuildContext context, StoicCard card) {
    return GestureDetector(
      onTap: () => GlobalRouter.I.goToDetail(card: card),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.sm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                _buildCardImage(card.assetImg),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.12),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                // Gradient overlay with virtue tag
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.14),
                            ),
                          ),
                          child: Text(
                            card.sceneCard.stoicVirtue.value,
                            style: AppTypography.small.copyWith(
                              color: AppColors.textInverse.withOpacity(0.95),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            card.sceneCard.visualMood.value,
                            style: AppTypography.small.copyWith(
                              color: AppColors.textInverse.withOpacity(0.9),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Text content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.oneLineCapture,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: AppColors.textPrimary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Tags
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: card.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgTertiary,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          tag,
                          style: AppTypography.small.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(String path) {
    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 190,
          color: AppColors.bgTertiary,
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: AppColors.textDisabled),
          ),
        ),
      );
    }
    return Image.asset(
      path,
      width: double.infinity,
      height: 190,
      fit: BoxFit.cover,
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  Widget _glowGlass({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMain.withOpacity(0.16),
            blurRadius: 26,
            spreadRadius: -6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: -8,
          ),
        ],
      ),
      child: GlassCard(
        padding: padding,
        tintOpacity: 0.16,
        borderOpacity: 0.22,
        boxShadow: AppShadows.sm,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w800,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textInverse,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DiffuseBackground(
              base: Color(0xFF070B16),
              bottom: Color(0xFF070B16),
            ),
          ),
          SafeArea(
            child: ValueListenableBuilder<List<StoicCard>>(
              valueListenable: GeneratedHistoryStore.I.items,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: _glowGlass(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primaryMain.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: AppColors.primaryMain.withOpacity(0.25),
                                ),
                              ),
                              child: const Icon(
                                Icons.history_rounded,
                                color: AppColors.primaryMain,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'No history yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textInverse,
                                      fontFamily: AppTypography.fontFamily,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Your creations will appear here.',
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textInverse.withOpacity(0.75),
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
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final card = items[index];
                    return GestureDetector(
                      onTap: () => GlobalRouter.I.goToDetail(card: card),
                      child: _glowGlass(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: SizedBox(
                                width: 76,
                                height: 76,
                                child: card.assetImg.startsWith('/')
                                    ? Image.file(
                                        File(card.assetImg),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const ColoredBox(color: AppColors.bgTertiary),
                                      )
                                    : Image.asset(
                                        card.assetImg,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const ColoredBox(color: AppColors.bgTertiary),
                                      ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.oneLineCapture,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textInverse,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    (card.tags.isNotEmpty)
                                        ? card.tags.take(3).map((e) => '#$e').join(' ')
                                        : 'Tap to view',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textInverse.withOpacity(0.72),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textInverse.withOpacity(0.75),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _isBusy = false;

  Future<void> _runWithLoading(Future<void> Function() fn) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await Future.delayed(const Duration(milliseconds: 320));
      await fn();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const _DeleteAccountDialog(),
    );
    if (ok != true) return;

    await _runWithLoading(() async {
      await LightHandle.deleteAccount();
      if (!mounted) return;
      GlobalRouter.I.goToLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget glass({
      required Widget child,
      EdgeInsetsGeometry? margin,
      EdgeInsetsGeometry? padding,
    }) {
      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
                boxShadow: AppShadows.md,
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(
                color: AppColors.textInverse,
                fontWeight: FontWeight.w800,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            foregroundColor: AppColors.textInverse,
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(child: DiffuseBackground()),
              Positioned.fill(
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          children: [
                            // Profile avatar
                            glass(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.14),
                                    child: ClipOval(
                                      child: Image.asset(
                                        A.assets_crushi_logo,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Stoic Explorer',
                                          style: AppTypography.h3.copyWith(
                                            color: AppColors.textInverse,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Begin your journey',
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.textInverse
                                                .withOpacity(0.72),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            glass(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.history,
                                      color: AppColors.primaryMain,
                                    ),
                                    title: Text(
                                      'Creation History',
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textInverse,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0x99FFFFFF),
                                    ),
                                    onTap: () => GlobalRouter.I.goToHistory(),
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.white.withOpacity(0.22),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.monetization_on,
                                      color: AppColors.primaryMain,
                                    ),
                                    title: Text(
                                      'Coins Store',
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textInverse,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0x99FFFFFF),
                                    ),
                                    onTap: () => GlobalRouter.I.goToCoins(),
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.white.withOpacity(0.22),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.feedback_outlined,
                                      color: AppColors.primaryMain,
                                    ),
                                    title: Text(
                                      'Feedback',
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textInverse,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0x99FFFFFF),
                                    ),
                                    onTap: () => GlobalRouter.I.goToFeedback(),
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.white.withOpacity(0.22),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.privacy_tip_outlined,
                                      color: AppColors.primaryMain,
                                    ),
                                    title: Text(
                                      'Privacy Policy',
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textInverse,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0x99FFFFFF),
                                    ),
                                    onTap: () => GlobalRouter.I.goToAgreement(
                                      url: AppEnv().h5Privacy,
                                      title: 'Privacy Policy',
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.white.withOpacity(0.22),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.description_outlined,
                                      color: AppColors.primaryMain,
                                    ),
                                    title: Text(
                                      'Terms of Service',
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textInverse,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0x99FFFFFF),
                                    ),
                                    onTap: () => GlobalRouter.I.goToAgreement(
                                      url: AppEnv().h5User,
                                      title: 'Terms of Service',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            glass(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      Icons.logout,
                                      color: AppColors.textInverse
                                          .withOpacity(0.85),
                                    ),
                                    title: Text(
                                      'Log Out',
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textInverse,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0x99FFFFFF),
                                    ),
                                    onTap: () => _runWithLoading(() async {
                                      await LightHandle.logout();
                                      if (!mounted) return;
                                      GlobalRouter.I.goToLogin();
                                    }),
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.white.withOpacity(0.22),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.delete_forever,
                                      color: AppColors.error,
                                    ),
                                    title: Text(
                                      'Delete Account',
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0x99FFFFFF),
                                    ),
                                    onTap: _confirmDeleteAccount,
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
              ),
            ],
          ),
        ),
        if (_isBusy)
          Positioned.fill(
            child: Container(
              color: AppColors.overlay,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryMain),
              ),
            ),
          ),
      ],
    );
  }
}

class _DeleteAccountDialog extends StatelessWidget {
  const _DeleteAccountDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMain.withOpacity(0.14),
              blurRadius: 30,
              spreadRadius: -10,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.06),
              blurRadius: 20,
              spreadRadius: -12,
            ),
          ],
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          tintOpacity: 0.16,
          borderOpacity: 0.22,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Delete Account',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textInverse.withOpacity(0.8),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: 'Cancel',
                      background: Colors.white.withOpacity(0.12),
                      foreground: AppColors.textInverse.withOpacity(0.9),
                      border: Colors.white.withOpacity(0.22),
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DialogButton(
                      label: 'Delete',
                      background: AppColors.error.withOpacity(0.22),
                      foreground: AppColors.textInverse,
                      border: AppColors.error.withOpacity(0.35),
                      onTap: () => Navigator.pop(context, true),
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
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textInverse,
            fontFamily: AppTypography.fontFamily,
          ).copyWith(color: foreground),
        ),
      ),
    );
  }
}
