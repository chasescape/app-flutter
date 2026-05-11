import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/checkin_model.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../services/checkin_service.dart';
import '../../services/storage_service.dart';
import '../../services/coins_manager.dart';
import '../../models/coin_package.dart';
import '../../widgets/common/pastel_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CheckInService _checkInService = CheckInService.instance;
  final StorageService _storage = StorageService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;

  int _streak = 0;
  bool _hasCheckedInToday = false;
  bool _isLoading = false;
  String _greeting = '';
  CheckInRecord? _todayRecord;
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _coinsManager.initialize();
    await _loadData();
  }

  Future<void> _loadData() async {
    final streak = _checkInService.getCurrentStreak();
    final hasCheckedInToday = await _storage.hasCheckedInToday();
    final todayRecord = _checkInService.getTodayRecord();
    final wakeTime = _parseTime(_storage.targetWakeTime, const TimeOfDay(hour: 7, minute: 30));
    final sleepTime = _parseTime(_storage.targetSleepTime, const TimeOfDay(hour: 23, minute: 0));

    if (!mounted) return;
    setState(() {
      _streak = streak;
      _hasCheckedInToday = hasCheckedInToday;
      _greeting = _getGreeting();
      _todayRecord = todayRecord;
      _wakeTime = wakeTime;
      _sleepTime = sleepTime;
    });
  }

  TimeOfDay _parseTime(String? value, TimeOfDay fallback) {
    if (value == null || !value.contains(':')) return fallback;
    final parts = value.split(':');
    if (parts.length != 2) return fallback;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? fallback.hour,
      minute: int.tryParse(parts[1]) ?? fallback.minute,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _handleCheckIn() async {
    if (_isLoading) return;

    final canCheckIn = await _checkInService.canCheckIn();
    if (!canCheckIn) {
      _showOutOfCoinsDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    final result = await _checkInService.attemptCheckIn();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (result.success && result.record != null) {
      await _loadData();
      _showCheckInSuccess(result.record!, result.message);
    } else {
      _showErrorDialog(result.message);
    }
  }

  void _showCheckInSuccess(CheckInRecord record, String message) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeroImageCard(
                height: 210,
                label: record.status.displayName,
                icon: Icons.favorite_rounded,
                overlay: Text(
                  record.status.emoji,
                  style: const TextStyle(fontSize: 72),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(record.status.displayName, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                record.motivationalQuote,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(message, style: AppTextStyles.small),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Lovely'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOutOfCoinsDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HeroImageCard(
                height: 180,
                label: 'Need more coins',
                icon: Icons.diamond_outlined,
                overlay: Icon(
                  Icons.monetization_on_rounded,
                  size: 72,
                  color: AppColors.accentDark,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Top up to keep your streak glowing.', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Get more coins to continue your daily ritual.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        AppRoutes.toCoinShop();
                      },
                      child: const Text('Get coins'),
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

  void _showErrorDialog(String message) {
    Get.snackbar(
      'Oops',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.textInverse,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PastelScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopPanel(),
            const SizedBox(height: AppSpacing.lg),
            _buildMainCheckInCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildInsightGrid(),
            const SizedBox(height: AppSpacing.lg),
            _buildBottomHighlights(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: BorderRadius.circular(22),
              boxShadow: AppShadows.sm,
            ),
            child: const Center(
              child: Text(
                '☀️',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text('Morning', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _hasCheckedInToday
                      ? 'Have a nice day.'
                      : 'Have a nice day.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildIconBubble(
            icon: Icons.settings_outlined,
            onTap: AppRoutes.toSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildMainCheckInCard() {
    final timeLabel = _todayRecord?.formattedTime ?? _formatTimeOfDay(_wakeTime);
    final statusLabel = _hasCheckedInToday ? 'Checked in' : 'Ready to check in';
    final helperLabel = _hasCheckedInToday
        ? 'Come back tomorrow for the next gentle streak point.'
        : 'Tap the center ring to save today.';

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMiniStatusChip(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Streak',
                  value: '$_streak days',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMiniStatusChip(
                  icon: Icons.diamond_outlined,
                  label: 'Daily cost',
                  value: '${CoinPackages.dailyCheckInCost} coin',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: _hasCheckedInToday ? null : _handleCheckIn,
            child: AnimatedScale(
              scale: _isLoading ? 0.96 : 1,
              duration: const Duration(milliseconds: 220),
              child: Container(
                width: 230,
                height: 230,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFD8CBFF), Color(0xFFB9B0FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                  ),
                  boxShadow: AppShadows.md,
                ),
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: const Color(0xFFE3DBFF), width: 10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Today Plan',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.accentDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_isLoading)
                        const SizedBox(
                          width: 34,
                          height: 34,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentDark),
                          ),
                        )
                      else
                        Text(
                          timeLabel,
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 40,
                            color: const Color(0xFF5B4FC6),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        statusLabel,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          helperLabel,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.small,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasCheckedInToday ? AppRoutes.toHistory : _handleCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAC97FF),
                foregroundColor: AppColors.textInverse,
              ),
              child: Text(_hasCheckedInToday ? 'Open Timeline' : 'Check In Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightGrid() {
    return Column(
      children: [
        _buildFeatureCard(
          title: 'My Schedule',
          subtitle: 'A softer routine for brighter mornings.',
          child: _buildScheduleVisual(),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildFeatureCard(
          title: 'Focus Hub',
          subtitle: 'See the current pace of your habit.',
          child: _buildFocusHub(),
        ),
        const SizedBox(height: AppSpacing.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildFeatureCard(
                  title: 'Reward Center',
                  subtitle: 'Coins and one-time top-up packs.',
                  onTap: AppRoutes.toCoinShop,
                  expandChild: true,
                  child: _buildRewardCenter(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildFeatureCard(
                  title: 'Recent Update',
                  subtitle: 'The latest mood saved from today.',
                  onTap: AppRoutes.toHistory,
                  expandChild: true,
                  child: _buildRecentUpdate(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomHighlights() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildCompactHighlight(
              title: 'Mood',
              subtitle: _todayRecord?.status.displayName ?? 'Waiting',
              emoji: _todayRecord?.status.emoji ?? '🌤️',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildCompactHighlight(
              title: 'AI Notes',
              subtitle: 'Warm summaries',
              emoji: '✨',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildCompactHighlight(
              title: 'Sleep Goal',
              subtitle: _formatTimeOfDay(_sleepTime),
              emoji: '🌙',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required Widget child,
    VoidCallback? onTap,
    bool expandChild = false,
  }) {
    final content = GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: AppTextStyles.small),
          const SizedBox(height: AppSpacing.md),
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(AppBorderRadius.large),
      onTap: onTap,
      child: content,
    );
  }

  Widget _buildScheduleVisual() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7F2FF), Color(0xFFFFF3E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTimeOfDay(_wakeTime),
            style: AppTextStyles.h2.copyWith(color: const Color(0xFF5B4FC6)),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text('Ideal wake-up window', style: AppTextStyles.small),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Icon(Icons.light_mode_rounded, color: Color(0xFFFFB454)),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Gentle sunrise rhythm',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusHub() {
    return Column(
      children: [
        _buildMetricRow('Consistency', _streak >= 7 ? 'Strong' : 'Growing', Icons.insights_rounded),
        const SizedBox(height: AppSpacing.sm),
        _buildMetricRow('Daily cost', '${CoinPackages.dailyCheckInCost} coin', Icons.bubble_chart_rounded),
        const SizedBox(height: AppSpacing.sm),
        ValueListenableBuilder<int>(
          valueListenable: _coinsManager.coinsNotifier,
          builder: (context, coins, child) {
            return _buildMetricRow('Coins', '$coins', Icons.diamond_outlined);
          },
        ),
      ],
    );
  }

  Widget _buildRewardCenter() {
    return ValueListenableBuilder<int>(
      valueListenable: _coinsManager.coinsNotifier,
      builder: (context, coins, child) {
        return Container(
          height: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F1FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$coins', style: AppTextStyles.h2.copyWith(color: const Color(0xFF5B4FC6))),
              const SizedBox(height: AppSpacing.xs),
              const Text('Current balance', style: AppTextStyles.small),
              const SizedBox(height: AppSpacing.md),
              const Row(
                children: [
                  Icon(Icons.card_giftcard_rounded, color: AppColors.warning),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'One-time packs only',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentUpdate() {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _todayRecord?.status.displayName ?? 'No entry yet',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _todayRecord?.motivationalQuote ?? 'Your next check-in quote will appear here.',
            style: AppTextStyles.small,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHighlight({
    required String title,
    required String subtitle,
    required String emoji,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      radius: AppBorderRadius.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                subtitle,
                style: AppTextStyles.small,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatusChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF7A6CE0)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.small),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accentDark),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTextStyles.caption)),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildIconBubble({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xF7FFFFFF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
