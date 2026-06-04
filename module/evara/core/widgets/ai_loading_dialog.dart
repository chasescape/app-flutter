import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

/// 全局 AI 分析 Loading 弹窗
///
/// 特点：
/// - 半透明遮罩屏蔽背景交互
/// - 符合英伦古典风格的美妆工具动画
/// - 静态取消按钮（无 loading 效果）
/// - 动态状态文案
class AiAnalysisLoadingDialog extends StatefulWidget {
  final String message;
  final VoidCallback? onCancel;
  final bool showCancel;

  const AiAnalysisLoadingDialog({
    super.key,
    this.message = 'Analyzing...',
    this.onCancel,
    this.showCancel = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String message = 'Analyzing...',
    VoidCallback? onCancel,
    bool showCancel = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AiAnalysisLoadingDialog(
        message: message,
        onCancel: onCancel,
        showCancel: showCancel,
      ),
    );
  }

  @override
  State<AiAnalysisLoadingDialog> createState() => _AiAnalysisLoadingDialogState();
}

class _AiAnalysisLoadingDialogState extends State<AiAnalysisLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Material(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            decoration: BoxDecoration(
              color: AppTheme.bgPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCosmeticToolAnimation(),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  widget.message,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.body,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.showCancel && widget.onCancel != null) ...[
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildCancelButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 英伦古典风格美妆工具动画
  ///
  /// 动画元素：
  /// - 旋转的复古黄铜色化妆刷框架
  /// - 脉冲的金色核心
  /// - 优雅的渐变效果
  Widget _buildCosmeticToolAnimation() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildRotatingBrush(),
          _buildPulsingCore(),
          _buildStaticOuterRing(),
        ],
      ),
    );
  }

  /// 旋转的化妆刷框架
  Widget _buildRotatingBrush() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: CustomPaint(
            size: const Size(100, 100),
            painter: _BrushFramePainter(),
          ),
        );
      },
    );
  }

  /// 脉冲的金色核心
  Widget _buildPulsingCore() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 0.6 + (_pulseController.value * 0.4);
        final opacity = 0.5 + (_pulseController.value * 0.5);
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentMain.withOpacity(0.8),
                    AppTheme.secondaryMain.withOpacity(0.4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentMain.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 静态外圈装饰
  Widget _buildStaticOuterRing() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.secondaryMain.withOpacity(0.2),
          width: 1,
        ),
      ),
    );
  }

  /// 取消按钮（静态，无 loading 效果）
  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: widget.onCancel,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          side: BorderSide(
            color: AppTheme.textDisabled.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
        child: Text(
          'Cancel',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: AppTheme.body,
          ),
        ),
      ),
    );
  }
}

/// 化妆刷框架绘制器
///
/// 绘制英伦古典风格的复古化妆刷形状
class _BrushFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = AppTheme.secondaryMain.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // 绘制装饰性刷毛图案
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final startRadius = radius * 0.4;
      final endRadius = radius * 0.85;

      final startX = center.dx + math.cos(angle) * startRadius;
      final startY = center.dy + math.sin(angle) * startRadius;
      final endX = center.dx + math.cos(angle) * endRadius;
      final endY = center.dy + math.sin(angle) * endRadius;

      path.moveTo(startX, startY);
      path.lineTo(endX, endY);

      final endX2 = center.dx + math.cos(angle + 0.15) * endRadius;
      final endY2 = center.dy + math.sin(angle + 0.15) * endRadius;

      path.moveTo(endX, endY);
      path.lineTo(endX2, endY2);
    }

    canvas.drawPath(path, paint);

    final goldPaint = Paint()
      ..color = AppTheme.accentMain.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final goldPath = Path();

    for (int i = 0; i < 4; i++) {
      final angle = (i / 4) * 2 * math.pi + math.pi / 8;
      final innerRadius = radius * 0.5;
      final outerRadius = radius * 0.7;

      final startX = center.dx + math.cos(angle) * innerRadius;
      final startY = center.dy + math.sin(angle) * innerRadius;
      final endX = center.dx + math.cos(angle) * outerRadius;
      final endY = center.dy + math.sin(angle) * outerRadius;

      goldPath.moveTo(startX, startY);
      goldPath.lineTo(endX, endY);

      final dotX = center.dx + math.cos(angle) * (outerRadius + 5);
      final dotY = center.dy + math.sin(angle) * (outerRadius + 5);

      canvas.drawCircle(Offset(dotX, dotY), 2, goldPaint);
    }

    canvas.drawPath(goldPath, goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
