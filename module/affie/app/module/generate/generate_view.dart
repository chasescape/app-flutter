import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'dart:io';
import 'generate_logic.dart';
import '../coins/coins_logic.dart';
import '../../theme/app_colors.dart';
import '../history/history_logic.dart';

class GeneratePage extends StatelessWidget {
  GeneratePage({super.key});

  final GenerateLogic logic = Get.put(GenerateLogic());
  final CoinsLogic coinsLogic = Get.put(CoinsLogic());
  final HistoryLogic historyLogic = Get.put(HistoryLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            _buildHeader(context),
            const SizedBox(height: 18),
            _buildUploadCard(context),
            const SizedBox(height: 18),
            _buildCostInfoCard(context),
            const SizedBox(height: 20),
            _buildAnalyzeSection(context),
            const SizedBox(height: 22),
            const SizedBox(height: 18),
            _buildHowItWorksSection(context),
            const SizedBox(height: 16),
            _buildTipsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Inspection',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.primaryDark,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload your equipment photo for AI analysis',
                style: TextStyle(
                  color: (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)
                      .withValues(alpha: 0.95),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildCoinSummary(isDark),
      ],
    );
  }

  Widget _buildCostInfoCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkCard : Colors.white)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? AppColors.darkCard : Colors.white)
                      .withOpacity(isDark ? 0.3 : 0.9),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Each analysis costs 100 coins',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient:
                      const LinearGradient(colors: AppColors.gradientSunset),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '100',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
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

  Widget _buildCoinSummary(bool isDark) {
    return Obx(() {
      final balance = coinsLogic.coinBalance.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: AppColors.gradientSunset),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              '$balance',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildUploadCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final imagePath = logic.selectedImage.value;
      final hasImage = imagePath.isNotEmpty;

      return GestureDetector(
        // 有图片时禁用整卡片点击，避免抢占 X 按钮的手势
        onTap: hasImage ? null : () => logic.pickImage(),
        child: Container(
          height: 480,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  AppColors.darkCard.withValues(alpha: 0.75),
                                  AppColors.darkCard.withOpacity(0.55),
                                ]
                              : [
                                  Colors.white.withOpacity(0.75),
                                  Colors.white.withOpacity(0.55),
                                ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DashedBorderPainter(
                      color: AppColors.accent1.withValues(alpha: 0.65),
                      radius: 26,
                    ),
                  ),
                ),
                if (logic.selectedImage.value.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.12),
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!hasImage) ...[
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 86,
                                height: 86,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: isDark
                                      ? AppColors.darkCard
                                      : Colors.white.withOpacity(0.98),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.12)
                                        : AppColors.primary.withOpacity(0.45),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.file_upload_outlined,
                                  color: AppColors.primaryDark,
                                  size: 40,
                                ),
                              ),
                              Positioned(
                                right: -8,
                                top: -8,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: AppColors.gradientSunset,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Upload Equipment Photo',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.primaryDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to select a clear photo of your gear for AI analysis',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else
                        const SizedBox(height: 16),
                        if (!hasImage) ...[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _FormatPill(text: 'JPG'),
                              SizedBox(width: 10),
                              _FormatPill(text: 'PNG'),
                              SizedBox(width: 10),
                              _FormatPill(text: 'HEIC'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.primaryDark,
                            ),
                            onPressed: () => logic.pickImage(),
                            icon: const Icon(
                              Icons.image_outlined,
                              size: 18,
                            ),
                            label: const Text(
                              'Change photo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (hasImage)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => logic.clearImage(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAnalyzeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() {
          final hasImage = logic.selectedImage.value.isNotEmpty;
          final isAnalyzing = logic.isAnalyzing.value;
          final canTap = hasImage && !isAnalyzing;
          return GestureDetector(
            onTap: () {
              if (isAnalyzing) return;
              if (!hasImage) {
                Get.snackbar(
                  'Image required',
                  'Please upload a gear photo before running analysis.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.95),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
                return;
              }

              // 每次分析前先扣 100 金币
              final success = coinsLogic.spendCoins(100);
              if (!success) {
                return;
              }

              logic.analyzeImage().then((_) {
                if (logic.lastAiResult != null) {
                  historyLogic.addAiHistory(logic.lastAiResult!);
                  Get.toNamed(
                    '/detail',
                    arguments: {'aiResult': logic.lastAiResult},
                  );
                  // 生成成功后清空当前占位图片
                  logic.clearImage();
                }
              });
            },
            child: Opacity(
              opacity: canTap ? 1 : 0.6,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: AppColors.gradientSunset,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isAnalyzing
                            ? Icons.hourglass_top_rounded
                            : Icons.camera_enhance_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isAnalyzing ? 'Analyzing...' : 'Analyze with AI',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardBg = isDark
        ? AppColors.darkCard.withValues(alpha: 0.95)
        : AppColors.primaryDark.withOpacity(0.08);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : AppColors.primary.withValues(alpha: 0.45);

    TextStyle titleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : AppColors.textPrimary,
    );

    TextStyle bodyStyle = TextStyle(
      fontSize: 13,
      height: 1.35,
      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 24,
                    color: isDark ? AppColors.accent2 : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 8),
                  Text('How It Works', style: titleStyle),
                ],
              ),
              const SizedBox(height: 12),
              _buildHowStep(
                context,
                index: 1,
                text:
                    'Lay out all your caving equipment on a flat, well‑lit surface.',
                textStyle: bodyStyle,
              ),
              const SizedBox(height: 8),
              _buildHowStep(
                context,
                index: 2,
                text:
                    'Take a clear photo from above so every item is visible and in focus.',
                textStyle: bodyStyle,
              ),
              const SizedBox(height: 8),
              _buildHowStep(
                context,
                index: 3,
                text:
                    'Our AI checks your gear against professional caving safety standards.',
                textStyle: bodyStyle,
              ),
              const SizedBox(height: 8),
              _buildHowStep(
                context,
                index: 4,
                text:
                    'Get instant feedback and recommendations for missing or inadequate items.',
                textStyle: bodyStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowStep(
    BuildContext context, {
    required int index,
    required String text,
    required TextStyle textStyle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.accent1 : AppColors.primary,
          ),
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: textStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = isDark
        ? const LinearGradient(
            colors: [
              Color(0xFF3B260C),
              Color(0xFF2B1C09),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFFFFE0B2),
              Color(0xFFFFF3E0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final titleColor = isDark
        ? Colors.white
        : const Color(0xFF7A4A24); // warm brown for better contrast
    final bodyColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.withOpacity(isDark ? 0.6 : 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: isDark ? const Color(0xFFFFE082) : Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tips for Best Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTipLine(
                'Use natural daylight or bright indoor lighting.',
                bodyColor,
              ),
              _buildTipLine(
                'Avoid strong shadows and reflections on equipment.',
                bodyColor,
              ),
              _buildTipLine(
                'Space items apart so they don’t overlap.',
                bodyColor,
              ),
              _buildTipLine(
                'Include all items you plan to bring on your cave trip.',
                bodyColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipLine(String text, Color color) {
    final isDark = Get.context != null &&
        Theme.of(Get.context!).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: isDark ? const Color(0xFFFFE082) : Colors.black87,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatPill extends StatelessWidget {
  const _FormatPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.18)
              : AppColors.primary.withOpacity(0.35),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark
              ? Colors.white.withOpacity(0.85)
              : AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final dashedPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final path = Path()..addRRect(rrect);
    _drawDashedPath(canvas, path, dashedPaint, dashLength: 6, gapLength: 5);

    final cornerPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const corner = 18.0;
    const inset = 14.0;

    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset + corner, inset),
      cornerPaint,
    );
    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset, inset + corner),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset - corner, inset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset, inset + corner),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset + corner, size.height - inset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset, size.height - inset - corner),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset - corner, size.height - inset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset, size.height - inset - corner),
      cornerPaint,
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        final extract =
            metric.extractPath(distance, next.clamp(0, metric.length));
        canvas.drawPath(extract, paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
