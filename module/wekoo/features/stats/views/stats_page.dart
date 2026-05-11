import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../theme/app_theme.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.appBackgroundGradient,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Stats'),
            backgroundColor: Colors.transparent,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStreakCard(controller),
                          const SizedBox(height: 18),
                          _buildWeeklyChart(controller),
                          const SizedBox(height: 18),
                          _buildSummaryCard(controller),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 74,
                    width: double.infinity,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Transform.translate(
                          offset: const Offset(0, 140),
                          child: const _AnimatedWaveBackground(),
                        ),
                      ),
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

  Widget _buildStreakCard(MainController controller) {
    final streak = controller.getStreak();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.secondaryLight),
        boxShadow: AppTheme.shadows,
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.waveMint, AppTheme.waveBlue],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current streak',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$streak days',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.secondaryLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Keep going',
              style: TextStyle(
                color: AppTheme.accentMain,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(MainController controller) {
    final weekData = controller.getWeekData();
    final today = DateTime.now();
    final maxValue = weekData.values.isNotEmpty
        ? weekData.values.reduce((a, b) => a > b ? a : b)
        : 1000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.secondaryLight),
        boxShadow: AppTheme.shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your hydration rhythm over the last 7 days.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 210,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue > 0 ? maxValue * 1.2 : 1000,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final date = today.subtract(Duration(days: 6 - value.toInt()));
                        final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][
                          date.weekday - 1
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dayName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue > 0 ? (maxValue * 1.2) / 4 : 250,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.bgTertiary,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  final date = today.subtract(Duration(days: 6 - index));
                  final dateStr = date.toIso8601String().split('T')[0];
                  final value = weekData[dateStr] ?? 0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value.toDouble(),
                        width: 18,
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppTheme.waveBlue, AppTheme.waveMint],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(MainController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.secondaryLight),
        boxShadow: AppTheme.shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: Icons.water_drop_rounded,
                label: 'Today',
                value: '${controller.todayAmount.value} ml',
              ),
              _buildSummaryItem(
                icon: Icons.calendar_today_outlined,
                label: 'This Week',
                value: '${_getWeekTotal(controller.getWeekData())} ml',
              ),
              _buildSummaryItem(
                icon: Icons.flag_outlined,
                label: 'Daily Goal',
                value: '${controller.settings.value.dailyGoal} ml',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryMain, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  int _getWeekTotal(Map<String, int> weekData) {
    return weekData.values.fold(0, (sum, value) => sum + value);
  }
}

class _AnimatedWaveBackground extends StatefulWidget {
  const _AnimatedWaveBackground();

  @override
  State<_AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<_AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 340,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: const Size(double.infinity, 340),
                painter: _WavePainter(
                  color: AppTheme.waveBlue.withValues(alpha: 0.32),
                  progress: _controller.value,
                  heightFactor: 0.46,
                  amplitude: 20,
                  wavelength: 180,
                ),
              ),
              CustomPaint(
                size: const Size(double.infinity, 320),
                painter: _WavePainter(
                  color: AppTheme.waveMint.withValues(alpha: 0.28),
                  progress: (_controller.value + 0.18) % 1,
                  heightFactor: 0.54,
                  amplitude: 16,
                  wavelength: 150,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.color,
    required this.progress,
    required this.heightFactor,
    required this.amplitude,
    required this.wavelength,
  });

  final Color color;
  final double progress;
  final double heightFactor;
  final double amplitude;
  final double wavelength;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path();
    final double baseHeight = size.height * heightFactor;
    final double shift = progress * wavelength * 2;

    path.moveTo(0, size.height);
    path.lineTo(0, baseHeight);

    for (double x = 0; x <= size.width; x++) {
      final double y = baseHeight +
          math.sin(((x + shift) / wavelength) * 2 * math.pi) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.heightFactor != heightFactor ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.wavelength != wavelength;
  }
}
