import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/main_controller.dart';
import '../../../services/coins_manager.dart';
import '../../../services/tool_charge_service.dart';
import '../../../controllers/result_controller.dart';
import '../../../theme/app_theme.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();
    final CoinsManager coinsManager = CoinsManager.instance;
    final ResultController resultController = Get.find<ResultController>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Share Progress'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              children: [
                _buildCardPreview(mainController, resultController),
                SizedBox(height: AppTheme.spacingXl),
                _buildTemplateSelector(resultController),
                SizedBox(height: AppTheme.spacingXl),
                _buildGenerateButton(coinsManager, resultController),
              ],
            ),
          ),
        ),
        _buildGeneratingOverlay(resultController),
      ],
    );
  }

  Widget _buildCardPreview(
      MainController mainController, ResultController resultController) {
    return Obx(() {
      final displayCard = resultController.currentCard.value;
      final todayAmount = mainController.todayAmount.value;
      final goal = mainController.settings.value.dailyGoal;
      final progress = mainController.getProgress();
      final streak = mainController.getStreak();
      final encouragement =
          displayCard?.aiEncouragement ?? _getStaticEncouragement(progress);

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppTheme.spacingXl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryMain,
              AppTheme.secondaryMain,
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.shadowsElevated,
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              size: 56,
              color: AppTheme.textInverse,
            ),
            SizedBox(height: AppTheme.spacingMd),
            Text(
              'Daily Summary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textInverse,
              ),
            ),
            SizedBox(height: AppTheme.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCardStat(
                  label: 'Total',
                  value: '$todayAmount',
                ),
                _buildCardStat(
                  label: 'Goal',
                  value: '$goal',
                ),
                _buildCardStat(
                  label: 'Progress',
                  value: '$progress%',
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingLg),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                color: AppTheme.bgPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppTheme.textInverse,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '$streak day streak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textInverse,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacingMd),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Text(
                encouragement,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textInverse.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCardStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textInverse,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textInverse.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateSelector(ResultController resultController) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Style',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacingMd),
          Row(
            children: resultController.templates.map((template) {
              final isSelected =
                  resultController.selectedTemplate.value == template;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: AppTheme.spacingSm),
                  child: _buildTemplateOption(
                    template,
                    isSelected,
                    () => resultController.selectTemplate(template),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildTemplateOption(
      String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryMain : AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primaryMain : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label.capitalizeFirst!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(
      CoinsManager coinsManager, ResultController resultController) {
    final ToolChargeService chargeService = ToolChargeService.instance;

    return ValueListenableBuilder(
      valueListenable: coinsManager.coinsNotifier,
      builder: (context, coins, child) {
        return ValueListenableBuilder(
          valueListenable: coinsManager.freeResultsNotifier,
          builder: (context, freeResults, child) {
            final canGenerate =
                freeResults > 0 || chargeService.hasEnoughCoins();

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (freeResults > 0) ...[
                        Text(
                          'Free uses left: $freeResults',
                          style: TextStyle(
                            color: AppTheme.semanticSuccess,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Icon(Icons.monetization_on,
                            color: AppTheme.primaryMain),
                        SizedBox(width: 8),
                        Text(
                          chargeService.getCostText(),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text('Save to Gallery'),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            canGenerate && !resultController.isGenerating.value
                                ? () => resultController.generateResultCard()
                                : null,
                        child: Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGeneratingOverlay(ResultController resultController) {
    return Obx(() {
      if (!resultController.isGenerating.value) {
        return SizedBox.shrink();
      }

      return Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(AppTheme.spacingXl),
            padding: EdgeInsets.all(AppTheme.spacingXl),
            decoration: BoxDecoration(
              color: AppTheme.bgPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWaterDropAnimation(),
                SizedBox(height: AppTheme.spacingLg),
                Obx(() {
                  return Text(
                    resultController.generatingStatus.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  );
                }),
                SizedBox(height: AppTheme.spacingLg),
                OutlinedButton(
                  onPressed: resultController.cancelGeneration,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                  ),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWaterDropAnimation() {
    return SizedBox(
      width: 100,
      height: 100,
      child: _WaterDropAnimation(),
    );
  }

  String _getStaticEncouragement(int progress) {
    if (progress >= 100) {
      return 'You nailed it! Daily goal achieved! 💧';
    } else if (progress >= 75) {
      return 'So close! Keep pushing, you\'ve got this!';
    } else if (progress >= 50) {
      return 'Halfway there! Stay hydrated and keep going!';
    } else if (progress >= 25) {
      return 'Great start! Every sip brings you closer!';
    } else {
      return 'Your hydration journey begins now! Start tracking!';
    }
  }
}

class _WaterDropAnimation extends StatefulWidget {
  @override
  State<_WaterDropAnimation> createState() => _WaterDropAnimationState();
}

class _WaterDropAnimationState extends State<_WaterDropAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fillAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: CustomPaint(
            size: Size(100, 100),
            painter: _WaterDropPainter(_fillAnimation.value),
          ),
        );
      },
    );
  }
}

class _WaterDropPainter extends CustomPainter {
  final double fillLevel;

  _WaterDropPainter(this.fillLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    final bgPaint = Paint()
      ..color = AppTheme.bgSecondary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, bgPaint);

    final fillPaint = Paint()
      ..color = AppTheme.primaryMain.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final fillRadius = radius * fillLevel;
    canvas.drawCircle(center, fillRadius, fillPaint);

    final wavePaint = Paint()
      ..color = AppTheme.primaryMain
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, 3);

    final waveY = center.dy - radius + (radius * 2 * (1 - fillLevel));
    final wavePath = Path();
    final wavePhase = DateTime.now().millisecondsSinceEpoch / 500;

    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = (x - center.dx) / radius;
      final waveYOffset = 5 *
          (1 - fillLevel) *
          (1 + 0.5 * (normalizedX * normalizedX)) *
          (1 + 0.3 * sin((x / 20) + wavePhase));

      if (x == 0) {
        wavePath.moveTo(x, waveY + waveYOffset);
      } else {
        wavePath.lineTo(x, waveY + waveYOffset);
      }
    }

    canvas.drawPath(wavePath, wavePaint);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: '💧',
        style: TextStyle(fontSize: 32),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(center.dx - iconPainter.width / 2,
          center.dy - iconPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
