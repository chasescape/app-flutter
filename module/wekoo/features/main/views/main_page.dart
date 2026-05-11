import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/coins_manager.dart';
import '../../../theme/app_theme.dart';
import '../../history/views/history_page.dart';
import '../../profile/views/profile_page.dart';
import '../../stats/views/stats_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedTabIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll(const [
      _HomePage(),
      _StatsTabPage(),
      _HistoryTabPage(),
      _ProfileTabPage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_selectedTabIndex),
          child: _pages[_selectedTabIndex],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTheme.parchmentSurface,
          boxShadow: AppTheme.shadows,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_outlined),
              activeIcon: Icon(Icons.water_drop),
              label: 'Today',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
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
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  static const List<int> _quickAmounts = [100, 200, 250, 350];

  MainController get _mainController => Get.find<MainController>();
  CoinsManager get _coinsManager => CoinsManager.instance;

  Future<void> _addDrink(int amount) async {
    await _mainController.addDrink(amount);
    // Get.snackbar(
    //   'Nice sip',
    //   '+$amount ml recorded',
    //   snackPosition: SnackPosition.TOP,
    //   backgroundColor: AppTheme.deepOcean.withValues(alpha: 0.92),
    //   colorText: Colors.white,
    //   margin: const EdgeInsets.all(12),
    //   borderRadius: 18,
    //   duration: const Duration(seconds: 2),
    // );

    if (_mainController.getProgress() >= 100) {
      Get.snackbar(
        'Daily goal complete',
        'You made it today. Keep the streak flowing.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.94),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 18,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.appBackgroundGradient,
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleSpacing: 24,
              title: const Text(
                'Wekoo',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              actions: [
                ValueListenableBuilder<int>(
                  valueListenable: _coinsManager.coinsNotifier,
                  builder: (context, coins, child) {
                    return Container(
                      margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.glassHighlight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.secondaryLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.waterfall_chart,
                            color: AppTheme.accentMain,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$coins',
                            style: const TextStyle(
                              color: AppTheme.accentMain,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 18),
                    _buildProgressCard(),
                    const SizedBox(height: 28),
                    _buildQuickAddSection(),
                    const SizedBox(height: 28),
                    _buildRecentSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xCCFFFFFF), Color(0xB8F2FDFF)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x99FFFFFF)),
          boxShadow: AppTheme.shadows,
        ),
        child: const Row(
          children: [
            _BubbleIcon(icon: Icons.water_drop_rounded),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Wekoo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track your water, build your rhythm, and keep your day feeling light.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AppTheme.textSecondary,
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

  Widget _buildProgressCard() {
    return Obx(() {
      final progress = _mainController.getProgress();
      final todayAmount = _mainController.todayAmount.value;
      final goal = _mainController.settings.value.dailyGoal;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: AppTheme.aquaPrimaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppTheme.shadowsElevated,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -18,
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -20,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s hydration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  progress >= 100 ? 'Goal reached. Nice work.' : 'A few more sips and you are there.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: _AnimatedWaterCup(
                    progress: progress,
                    todayAmount: todayAmount,
                    goal: goal,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricPill(
                        label: 'Drinks',
                        value: '${_mainController.todayCount.value}',
                        icon: Icons.local_drink_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricPill(
                        label: 'Streak',
                        value: '${_mainController.getStreak()}d',
                        icon: Icons.bolt_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricPill(
                        label: 'Goal',
                        value: '$goal ml',
                        icon: Icons.flag_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 88),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick add',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tap a cup size to record water fast.',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.4,
          ),
          itemCount: _quickAmounts.length,
          itemBuilder: (context, index) {
            final amount = _quickAmounts[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 360 + (index * 80)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - value) * 24),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: _QuickAddCard(
                amount: amount,
                onTap: () => _addDrink(amount),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentSection() {
    return Obx(() {
      final recentRecords = _mainController.records.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent sips',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: AppRoutes.toHistory,
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (recentRecords.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGlowGradient,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.secondaryLight),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: 52,
                    color: AppTheme.textDisabled,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Your first water log will show up here.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentRecords.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 340 + (index * 90)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - value) * 18),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGlowGradient,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.secondaryLight),
                    boxShadow: AppTheme.shadows,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.waveMint, AppTheme.waveBlue],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.water_drop_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${record.amount} ml',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(record.dateTime),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.textDisabled,
                          size: 20,
                        ),
                        onPressed: () => _mainController.deleteRecord(record.id),
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      );
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _AnimatedWaterCup extends StatefulWidget {
  const _AnimatedWaterCup({
    required this.progress,
    required this.todayAmount,
    required this.goal,
  });

  final int progress;
  final int todayAmount;
  final int goal;

  @override
  State<_AnimatedWaterCup> createState() => _AnimatedWaterCupState();
}

class _AnimatedWaterCupState extends State<_AnimatedWaterCup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = (widget.progress / 100).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final lift = math.sin(_floatController.value * math.pi) * 4;
        return Transform.translate(
          offset: Offset(0, -lift),
          child: child,
        );
      },
      child: SizedBox(
        width: 190,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 170,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(34),
                  topRight: Radius.circular(34),
                  bottomLeft: Radius.circular(42),
                  bottomRight: Radius.circular(42),
                ),
                border: Border.all(color: Colors.white, width: 8),
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Container(
              width: 148,
              height: 178,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
                color: Colors.white.withValues(alpha: 0.10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.06),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progressValue),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      final fillHeight = 178 * value;
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: fillHeight.clamp(12, 178),
                          width: 148,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xB8FCE6EB),
                                Color(0xCCF5B9C8),
                                Color(0xE6F08FA8),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(value >= 0.92 ? 26 : 18),
                              topRight: Radius.circular(value >= 0.92 ? 26 : 18),
                              bottomLeft: const Radius.circular(34),
                              bottomRight: const Radius.circular(34),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 148,
                      height: 178,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: widget.progress),
                        duration: const Duration(milliseconds: 700),
                        builder: (context, value, child) {
                          return Text(
                            '$value%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.todayAmount} / ${widget.goal} ml',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
}

class _QuickAddCard extends StatefulWidget {
  const _QuickAddCard({
    required this.amount,
    required this.onTap,
  });

  final int amount;
  final VoidCallback onTap;

  @override
  State<_QuickAddCard> createState() => _QuickAddCardState();
}

class _QuickAddCardState extends State<_QuickAddCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGlowGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _pressed ? AppTheme.primaryLight : AppTheme.secondaryLight,
              width: 1.2,
            ),
            boxShadow: _pressed ? const [] : AppTheme.shadows,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.waveMint, AppTheme.waveBlue],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.amount} ml',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Quick log',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
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
}

class _BubbleIcon extends StatelessWidget {
  const _BubbleIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.waveMint, AppTheme.waveBlue],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _StatsTabPage extends StatelessWidget {
  const _StatsTabPage();

  @override
  Widget build(BuildContext context) {
    return StatsPage();
  }
}

class _HistoryTabPage extends StatelessWidget {
  const _HistoryTabPage();

  @override
  Widget build(BuildContext context) {
    return const HistoryPage();
  }
}

class _ProfileTabPage extends StatelessWidget {
  const _ProfileTabPage();

  @override
  Widget build(BuildContext context) {
    return ProfilePage();
  }
}
