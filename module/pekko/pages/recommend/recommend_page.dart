import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/recommend_controller.dart';
import '../../controllers/main_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/perfume_record.dart';

/// Recommend page
class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage>
    with TickerProviderStateMixin {
  late AnimationController _perfumeController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _perfumeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _perfumeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecommendController>();
    final mainController = Get.find<MainController>();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
          SliverAppBar(
            title: const Text('Scent Recommendations'),
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.sunsetGradient,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'Describe your occasion and we\'ll suggest scents based on your preferences',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Scene selector
                  const Text('What\'s the occasion?', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.sm),
                  _SceneSelector(),
                  const SizedBox(height: AppSpacing.lg),

                  // Time selector
                  const Text('What time of day?', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.sm),
                  _TimeSelector(),
                  const SizedBox(height: AppSpacing.lg),

                  // Season selector
                  const Text('What season is it?', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.sm),
                  _SeasonSelector(),
                  const SizedBox(height: AppSpacing.xl),

                  // Get recommendations button
                  Obx(
                    () {
                      final cost = controller.cost;
                      final canAfford = mainController.hasFreeUses || mainController.currentCoins >= cost;

                      return Column(
                        children: [
                          if (!mainController.hasFreeUses)
                            Container(
                              padding: AppSpacing.paddingMD,
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: AppBorderRadius.allMedium,
                                border: Border.all(
                                  color: AppColors.warning.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      'Recommendations cost $cost coins',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ||
                                      !controller.isValidInput ||
                                      !canAfford
                                  ? null
                                  : controller.getRecommendations,
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.textInverse,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      mainController.hasFreeUses
                                          ? 'Get Recommendations (Free)'
                                          : 'Get Recommendations ($cost coins)',
                                    ),
                            ),
                          ),
                          if (!canAfford && controller.isValidInput) ...[
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: () => Get.toNamed('/coin-store'),
                              child: const Text('Need more coins?'),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Results
                  Obx(
                    () {
                      if (controller.recommendations.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recommended for you', style: AppTextStyles.h3),
                          const SizedBox(height: AppSpacing.md),
                          ...controller.recommendations.map((rec) {
                            return _RecommendationCard(
                              recommendation: rec,
                              onQuickRecord: () {
                                controller.quickRecordWithRecommendation(rec);
                              },
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
            ],  // 闭合 CustomScrollView 的 slivers
          ),  // 闭合 CustomScrollView
          // Global loading overlay
          Obx(() => controller.isLoading.value
              ? _LoadingOverlay(
                  perfumeController: _perfumeController,
                  pulseController: _pulseController,
                  message: controller.loadingMessage.value,
                  onCancel: controller.cancelRecommendation,
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _SceneSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecommendController>();

    return Obx(
      () => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: UsageScene.values.map((scene) {
          final isSelected = controller.selectedScene.value == scene;
          return ChoiceChip(
            label: Text(scene.displayName),
            selected: isSelected,
            onSelected: (_) => controller.selectScene(scene),
            selectedColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecommendController>();

    return Obx(
      () => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: TimeOfDayType.values.map((time) {
          final isSelected = controller.selectedTime.value == time;
          return ChoiceChip(
            label: Text(time.displayName),
            selected: isSelected,
            onSelected: (_) => controller.selectTime(time),
            selectedColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }
}

class _SeasonSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecommendController>();

    return Obx(
      () => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: Season.values.map((season) {
          final isSelected = controller.selectedSeason.value == season;
          return ChoiceChip(
            label: Text(season.displayName),
            selected: isSelected,
            onSelected: (_) => controller.selectSeason(season),
            selectedColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;
  final VoidCallback onQuickRecord;

  const _RecommendationCard({
    required this.recommendation,
    required this.onQuickRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMD,
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.sunsetGradient,
                  ),
                  borderRadius: AppBorderRadius.allMedium,
                ),
                child: const Icon(
                  Icons.local_florist,
                  color: AppColors.textInverse,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation['name'] as String,
                      style: AppTextStyles.h3,
                    ),
                    Text(
                      recommendation['brand'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppBorderRadius.allMedium,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    recommendation['reason'] as String,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onQuickRecord,
            icon: const Icon(Icons.add),
            label: const Text('Quick Record with This'),
          ),
        ],
      ),
    );
  }
}

/// Global loading overlay with sunset-themed perfume animation
class _LoadingOverlay extends StatefulWidget {
  final AnimationController perfumeController;
  final AnimationController pulseController;
  final String message;
  final VoidCallback onCancel;

  const _LoadingOverlay({
    required this.perfumeController,
    required this.pulseController,
    required this.message,
    required this.onCancel,
  });

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> {
  int _dotCount = 0;
  late Timer _dotTimer;

  @override
  void initState() {
    super.initState();
    widget.perfumeController.repeat();
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _dotTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;

    return Container(
      color: AppColors.backgroundOverlay,
      child: Center(
        child: Container(
          margin: AppSpacing.paddingMD,
          padding: AppSpacing.paddingXL,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sunset-themed perfume bottle animation
              SizedBox(
                width: 120,
                height: 120,
                child: AnimatedBuilder(
                  animation: Listenable.merge([widget.perfumeController, widget.pulseController]),
                  builder: (context, child) {
                    final rotation = widget.perfumeController.value * 2 * 3.14159;
                    final scale = 1.0 + (widget.pulseController.value * 0.1);

                    return Transform.scale(
                      scale: scale,
                      child: CustomPaint(
                        size: const Size(120, 120),
                        painter: _PerfumeBottlePainter(rotation),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Status message with animated dots
              Text(
                '${widget.message}$dots',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Cancel button (static, no loading effect)
              SizedBox(
                width: 140,
                height: 48,
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for sunset-themed perfume bottle animation
class _PerfumeBottlePainter extends CustomPainter {
  final double rotation;

  _PerfumeBottlePainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bottleWidth = 40.0;
    final bottleHeight = 60.0;

    // Create sunset gradient for liquid
    final liquidGradient = LinearGradient(
      colors: AppColors.sunsetGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Animated wave effect for liquid
    final waveOffset = (rotation / (2 * 3.14159)) * 10;

    // Draw bottle outline
    final bottleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: bottleWidth,
        height: bottleHeight,
      ),
      const Radius.circular(8),
    );

    final bottlePaint = Paint()
      ..color = AppColors.cardBackground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(bottleRect, bottlePaint);

    // Draw liquid with wave animation
    final liquidPath = Path();
    final liquidTop = center.dy - bottleHeight / 2 + 15 + waveOffset;

    liquidPath.moveTo(center.dx - bottleWidth / 2 + 4, liquidTop);

    // Animated wave
    for (double x = 0; x <= bottleWidth - 8; x += 2) {
      final y = liquidTop +
          (x / 10) * 3 * (rotation / (2 * 3.14159)).clamp(-1, 1) +
          (x / 20) * 2;
      liquidPath.lineTo(center.dx - bottleWidth / 2 + 4 + x, y);
    }

    liquidPath.lineTo(center.dx + bottleWidth / 2 - 4, center.dy + bottleHeight / 2 - 4);
    liquidPath.lineTo(center.dx - bottleWidth / 2 + 4, center.dy + bottleHeight / 2 - 4);
    liquidPath.close();

    final liquidPaint = Paint()
      ..shader = liquidGradient.createShader(
        Rect.fromCircle(center: center, radius: bottleWidth),
      );

    canvas.drawPath(liquidPath, liquidPaint);

    // Draw cap
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - bottleHeight / 2 - 6),
        width: 20,
        height: 10,
      ),
      const Radius.circular(4),
    );

    final capPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawRRect(capRect, capPaint);

    // Draw floating scent particles
    final particlePaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = rotation + (i * 2 * 3.14159 / 5);
      final radius = 35 + (i * 5);
      final x = center.dx + (radius * (rotation / (2 * 3.14159)).clamp(-1, 1));
      final y = center.dy - bottleHeight / 2 - 20 - (i * 8);

      canvas.drawCircle(Offset(x, y), 3 - (i * 0.4), particlePaint);
    }
  }

  @override
  bool shouldRepaint(_PerfumeBottlePainter oldDelegate) => true;
}
