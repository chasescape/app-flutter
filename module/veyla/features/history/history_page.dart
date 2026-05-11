import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../services/checkin_service.dart';
import '../../models/checkin_model.dart';
import '../../models/achievement_model.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/pastel_ui.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final CheckInService _checkInService = CheckInService.instance;

  List<CheckInRecord> _records = [];
  List<Achievement> _achievements = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  CheckInRecord? _activeRecord;
  bool _isActiveRecordFlipped = false;
  final Map<String, GlobalKey> _recordCardKeys = <String, GlobalKey>{};
  Rect? _activeRecordSourceRect;
  bool _isFloatingCardExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final records = _checkInService.getAllRecords();
    final achievements = await _checkInService.getAchievements();
    final stats = await _checkInService.getStats();

    if (!mounted) return;
    setState(() {
      _records = records;
      _achievements = achievements;
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PastelScaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            ),
            title: const Text('Gallery History'),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentDark),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsSection(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildAchievementsSection(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildRecordsSection(),
                    ],
                  ),
                ),
        ),
        if (_activeRecord != null) _buildFloatingRecordOverlay(_activeRecord!),
      ],
    );
  }

  Widget _buildStatsSection() {
    return GlassCard(
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Total', '${_stats['total'] ?? 0}')),
          Expanded(child: _buildStatItem('Streak', '${_stats['streak'] ?? 0}')),
          Expanded(child: _buildStatItem('Early', '${_stats['early'] ?? 0}')),
          Expanded(child: _buildStatItem('On time', '${_stats['onTime'] ?? 0}')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.accentDark)),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.small),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges ($unlockedCount/${_achievements.length})',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _achievements.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final achievement = _achievements[index];
              return GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                radius: AppBorderRadius.medium,
                child: SizedBox(
                  width: 112,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        achievement.emoji,
                        style: TextStyle(
                          fontSize: 34,
                          color: achievement.isUnlocked ? null : AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        achievement.title,
                        style: AppTextStyles.small.copyWith(
                          color: achievement.isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsSection() {
    if (_records.isEmpty) {
      return const EmptyState(
        title: 'No check-ins yet',
        subtitle: 'Your image-first timeline will show up here after the first ritual.',
        icon: Icons.photo_library_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent activity', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _records.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) {
            final record = _records[index];
            return _buildRecordCard(record);
          },
        ),
      ],
    );
  }

  Widget _buildRecordCard(CheckInRecord record) {
    final cardKey = _recordCardKeys.putIfAbsent(record.id, () => GlobalKey());

    return GestureDetector(
      excludeFromSemantics: true,
      onTap: () {
        final renderObject = cardKey.currentContext?.findRenderObject();
        Rect? sourceRect;
        if (renderObject is RenderBox) {
          final offset = renderObject.localToGlobal(Offset.zero);
          sourceRect = offset & renderObject.size;
        }

        setState(() {
          _activeRecord = record;
          _isActiveRecordFlipped = false;
          _activeRecordSourceRect = sourceRect;
          _isFloatingCardExpanded = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _activeRecord?.id != record.id) return;
          setState(() {
            _isFloatingCardExpanded = true;
          });
        });
      },
      child: KeyedSubtree(
        key: cardKey,
        child: _buildRecordFront(record),
      ),
    );
  }

  Widget _buildFloatingRecordOverlay(CheckInRecord record) {
    final screenSize = MediaQuery.of(context).size;
    final targetWidth = screenSize.width - 40;
    final targetHeight = math.min(screenSize.height * 0.72, 560.0);
    final targetLeft = (screenSize.width - targetWidth) / 2;
    final targetTop = math.max((screenSize.height - targetHeight) / 2, 32.0);
    final sourceRect = _activeRecordSourceRect;

    return Positioned.fill(
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: () {
          setState(() {
            _activeRecord = null;
            _activeRecordSourceRect = null;
            _isFloatingCardExpanded = false;
          });
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.28),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                left: _isFloatingCardExpanded ? targetLeft : (sourceRect?.left ?? targetLeft),
                top: _isFloatingCardExpanded ? targetTop : (sourceRect?.top ?? targetTop),
                width: _isFloatingCardExpanded ? targetWidth : (sourceRect?.width ?? targetWidth),
                height: _isFloatingCardExpanded ? targetHeight : (sourceRect?.height ?? targetHeight),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _isActiveRecordFlipped ? 1 : 0),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    final angle = value * math.pi;
                    final showBack = angle > math.pi / 2;

                    return GestureDetector(
                      excludeFromSemantics: true,
                      onTap: () {
                        setState(() {
                          _isActiveRecordFlipped = !_isActiveRecordFlipped;
                        });
                      },
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(angle),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppBorderRadius.large),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 34,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: showBack
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(math.pi),
                                  child: _buildRecordBack(record),
                                )
                              : _buildRecordFront(record),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recordCardKeys.clear();
    super.dispose();
  }

  Widget _buildRecordFront(CheckInRecord record) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.maxHeight.isFinite;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecordHero(record),
              const SizedBox(height: AppSpacing.md),
              if (hasBoundedHeight)
                Expanded(
                  child: _buildRecordFrontDetails(
                    record,
                    showFooterHint: true,
                  ),
                )
              else
                _buildRecordFrontDetails(record),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecordFrontDetails(
    CheckInRecord record, {
    bool showFooterHint = false,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PaintedText(
                    'Check-in moment',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.accentDark,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _PaintedText(
                    record.status.displayName,
                    style: AppTextStyles.h3,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: _PaintedText(
                '${record.streak} day streak',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.accentDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildRecordMetaChip(
              icon: Icons.calendar_month_rounded,
              label: record.formattedDate,
            ),
            _buildRecordMetaChip(
              icon: Icons.schedule_rounded,
              label: record.formattedTime,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8F4FF),
                Color(0xFFFFFBF7),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFECE5F7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PaintedText(
                'Morning note',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _PaintedText(
                record.motivationalQuote,
                style: AppTextStyles.body.copyWith(
                  fontSize: 15,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.stroke),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.maxHeight.isFinite;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasBoundedHeight)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: content,
                  ),
                )
              else
                content,
              if (showFooterHint) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    _PaintedText(
                      'Tap card to flip for today\'s reflection.',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecordMetaChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.accentDark,
          ),
          const SizedBox(width: 8),
          _PaintedText(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordHero(CheckInRecord record) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
        gradient: AppGradients.hero,
        border: Border.all(color: AppColors.stroke),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Align(
                alignment: const Alignment(0.06, 0.04),
                child: _PaintedText(
                  record.status.emoji,
                  style: const TextStyle(fontSize: 52),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordBack(CheckInRecord record) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D2440),
              Color(0xFF211A31),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1B96B),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF2B213F),
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const _PaintedText(
                          'Today\'s note',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PaintedText(
                    _buildDailyTip(record),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PaintedText(
                    'Tap again to flip back.',
                    style: AppTextStyles.small.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: _PaintedText(
                      record.motivationalQuote,
                      style: const TextStyle(
                        color: Color(0xFFE2D9F2),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
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

  String _buildDailyTip(CheckInRecord record) {
    if (record.streak >= 7) {
      return 'Your rhythm is stable now. Keep the next check-in light and consistent.';
    }
    if (record.status.displayName.toLowerCase().contains('late')) {
      return 'Today can still recover. Shift tonight forward by ten minutes and keep it easy.';
    }
    if (record.status.displayName.toLowerCase().contains('early')) {
      return 'You already built momentum. Protect it with a calm evening and a shorter scroll.';
    }
    return 'One steady check-in matters more than a perfect day. Stay gentle and keep moving.';
  }
}

class _PaintedText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _PaintedText(
    this.text, {
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          textAlign: TextAlign.start,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(
            maxWidth: constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : double.infinity,
          );

        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : textPainter.width;

        return Semantics(
          label: text,
          child: ExcludeSemantics(
            child: CustomPaint(
              size: Size(width, textPainter.height),
              painter: _PaintedTextPainter(textPainter),
            ),
          ),
        );
      },
    );
  }
}

class _PaintedTextPainter extends CustomPainter {
  final TextPainter textPainter;

  const _PaintedTextPainter(this.textPainter);

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant _PaintedTextPainter oldDelegate) {
    return textPainter.text?.toPlainText() !=
            oldDelegate.textPainter.text?.toPlainText() ||
        textPainter.text?.style != oldDelegate.textPainter.text?.style ||
        textPainter.textAlign != oldDelegate.textPainter.textAlign;
  }
}
