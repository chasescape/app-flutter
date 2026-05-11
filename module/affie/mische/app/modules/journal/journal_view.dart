import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/mische_background.dart';
import '../emotion/emotion_models.dart';
import '../../routes/app_routes.dart';
import 'journal_logic.dart';

class JournalPage extends StatelessWidget {
  JournalPage({super.key});

  final JournalLogic logic = Get.find<JournalLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: MischeBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildHeader(),
                const SizedBox(height: 20),
                if (!logic.hasData) ...[
                  _buildEmptyState(),
                  const SizedBox(height: 300),
                ] else ...[
                  _buildWeeklyOverview(),
                  const SizedBox(height: 20),
                  _buildInsights(context),
                  const SizedBox(height: 20),
                  _buildGallery(),
                  const SizedBox(height: 100),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Emotional Journey',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFFffffff),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Track patterns and celebrate progress',
          style: TextStyle(color: Color(0xFFB0B0B6), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xFF8F3CF0),
                Color(0xFFE94AA8),
                Color(0xFFFF7A4B)
              ]),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.book_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Journey Awaits',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your emotions in the Home tab to unlock personalized insights and beautiful visualizations.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Color(0xFFE1DFE6), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          _buildFeatureRow(
              Icons.trending_up,
              'Weekly Overview',
              'Visualize your mood trends with beautiful charts',
              const Color(0xFFFF7A4B)),
          const SizedBox(height: 12),
          _buildFeatureRow(
              Icons.auto_awesome,
              'AI Insights',
              'Discover patterns and personalized recommendations',
              const Color(0xFFE94AA8)),
          const SizedBox(height: 12),
          _buildFeatureRow(
              Icons.photo_camera,
              'Mood Gallery',
              'Build a visual journal of your emotional moments',
              const Color(0xFF8F3CF0)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
      IconData icon, String title, String subtitle, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.9), color]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFFE1DFE6), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    final data = logic.weekData;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This Week's Overview",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _WeeklyLineChart(data: data, maxAverage: 10),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _MetricCard(
                  title: 'Avg Mood', value: '7.1', color: Color(0xFFFF7A4B)),
              SizedBox(width: 12),
              _MetricCard(
                  title: 'Total Entries',
                  value: '23',
                  color: Color(0xFFE94AA8)),
              SizedBox(width: 12),
              _MetricCard(
                  title: 'Improvement',
                  value: '+15%',
                  color: Color(0xFF8F3CF0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(BuildContext context) {
    return Obx(() {
      final insights = logic.insights;

      if (logic.isLoading.value && insights.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Generating AI Insights...',
            style: TextStyle(color: Color(0xFFB0B0B6), fontSize: 12),
          ),
        );
      }

      if (insights.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Insights',
            style: TextStyle(
                color: Color(0xFFE1E1E6),
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (logic.error.value != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                logic.error.value!,
                style: const TextStyle(color: Color(0xFFB0B0B6), fontSize: 11),
              ),
            ),
          ...insights
              .asMap()
              .entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildInsightCard(context, entry.value, entry.key),
                  ))
              .toList(),
        ],
      );
    });
  }

  Widget _buildInsightCard(BuildContext context, Insight insight, int index) {
    // 获取用户上传的照片
    final entriesWithImages = logic.emotionLogic.entries
        .where((entry) => entry.imagePath != null)
        .toList();

    // 为每个 Insight 卡片分配不同的用户照片
    final hasUserImage =
        entriesWithImages.isNotEmpty && index < entriesWithImages.length;
    final userImagePath =
        hasUserImage ? entriesWithImages[index].imagePath! : null;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.insightDetail, arguments: insight),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 28,
        child: Row(
          children: [
            Container(
              width: 70,
              height: 94,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFE9E6F0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: hasUserImage
                    ? Image.file(
                        File(userImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(insight.imageUrl,
                              fit: BoxFit.cover);
                        },
                      )
                    : Image.network(insight.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: insight.gradient),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Insight',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    insight.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.description,
                    style:
                        const TextStyle(color: Color(0xFFE1DFE6), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery() {
    // 获取所有有照片的心情记录
    final entriesWithImages = logic.emotionLogic.entries
        .where((entry) => entry.imagePath != null)
        .toList();

    // 如果没有照片，使用默认图片
    final images = entriesWithImages.isEmpty
        ? [
            'https://images.unsplash.com/photo-1591021802639-72a355b39886?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
            'https://images.unsplash.com/photo-1764677224091-d300d12df5f6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
            'https://images.unsplash.com/photo-1758521540924-a061adde98ed?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
            'https://images.unsplash.com/photo-1766524791322-8753e582e652?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
            'https://images.unsplash.com/photo-1625662171040-8d196a082232?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
            'https://images.unsplash.com/photo-1573060493914-a7278e31d806?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
          ]
        : entriesWithImages.map((e) => e.imagePath!).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood Gallery',
          style: TextStyle(
              color: Color(0xFFE1E1E6),
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final imagePath = images[index];
            final isLocalImage = entriesWithImages.isNotEmpty;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFE9E6F0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isLocalImage
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF2A2A33),
                            child: const Icon(Icons.broken_image,
                                color: Colors.white54),
                          );
                        },
                      )
                    : Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 18,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Color(0xFFE1DFE6), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyLineChart extends StatelessWidget {
  const _WeeklyLineChart({required this.data, required this.maxAverage});

  final List<WeekMoodData> data;
  final double maxAverage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight;
        final chartWidth = constraints.maxWidth;
        final leftAxisWidth = 30.0;
        final bottomAxisHeight = 24.0;
        final plotHeight = chartHeight - bottomAxisHeight;
        final plotWidth = chartWidth - leftAxisWidth;
        final points = _buildPoints(plotWidth, plotHeight);

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _AxisGridPainter(
                  rows: 6,
                  leftAxisWidth: leftAxisWidth,
                  bottomAxisHeight: bottomAxisHeight,
                ),
              ),
            ),
            Positioned(
              left: leftAxisWidth,
              top: 0,
              right: 0,
              bottom: bottomAxisHeight,
              child: CustomPaint(
                painter: _LinePainter(
                    points: points, color: const Color(0xFFFF7A4B)),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  SizedBox(width: leftAxisWidth),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomAxisHeight),
                      child: Row(
                        children: points.map((point) {
                          return Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                              heightFactor:
                                  (plotHeight - point.dy) / plotHeight,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: leftAxisWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('10',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              Text('8',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              Text('6',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              Text('4',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              Text('2',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                              Text('0',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: bottomAxisHeight,
                    child: Row(
                      children: [
                        SizedBox(width: leftAxisWidth),
                        Expanded(
                          child: Row(
                            children: data.map((day) {
                              return Expanded(
                                child: Center(
                                  child: Text(
                                    day.label,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Offset> _buildPoints(double width, double height) {
    if (data.isEmpty) {
      return [];
    }
    final spacing = width / (data.length - 1);
    return data.asMap().entries.map((entry) {
      final x = spacing * entry.key;
      final normalized = entry.value.average / maxAverage;
      final y = height - (normalized * height);
      return Offset(x, y);
    }).toList();
  }
}

class _AxisGridPainter extends CustomPainter {
  _AxisGridPainter(
      {required this.rows,
      required this.leftAxisWidth,
      required this.bottomAxisHeight});

  final int rows;
  final double leftAxisWidth;
  final double bottomAxisHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A33)
      ..strokeWidth = 1;
    final chartHeight = size.height - bottomAxisHeight;
    for (int i = 0; i < rows; i++) {
      final y = (chartHeight / (rows - 1)) * i;
      canvas.drawLine(Offset(leftAxisWidth, y), Offset(size.width, y), paint);
    }
    canvas.drawLine(
        Offset(leftAxisWidth, 0), Offset(leftAxisWidth, chartHeight), paint);
    canvas.drawLine(Offset(leftAxisWidth, chartHeight),
        Offset(size.width, chartHeight), paint);
  }

  @override
  bool shouldRepaint(covariant _AxisGridPainter oldDelegate) {
    return rows != oldDelegate.rows ||
        leftAxisWidth != oldDelegate.leftAxisWidth ||
        bottomAxisHeight != oldDelegate.bottomAxisHeight;
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.points, required this.color});

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
