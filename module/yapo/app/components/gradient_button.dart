import 'package:flutter/material.dart';

/// 高性能渐变按钮组件
/// 
/// 特点：
/// - 使用 const 构造函数，避免不必要的重建
/// - 静态渐变配置，减少运行时计算
/// - 可选的加载状态
/// - 简化的阴影效果
/// 
/// 使用示例：
/// ```dart
/// GradientButton(
///   text: 'Buy Now',
///   onPressed: () => print('Clicked'),
///   isLoading: false,
/// )
/// ```
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final List<Color>? disabledGradientColors;
  final Color? shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final Widget? loadingWidget;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 40,
    this.fontSize = 13,
    this.fontWeight = FontWeight.bold,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.borderRadius,
    this.gradientColors,
    this.disabledGradientColors,
    this.shadowColor,
    this.shadowBlurRadius = 8,
    this.shadowOffset = const Offset(0, 3),
    this.loadingWidget,
  });

  // 预定义的渐变样式（静态常量，避免重复创建）
  static const List<Color> primaryGradient = [
    Color(0xFFdb2777),
    Color(0xFF9333ea),
  ];

  static const List<Color> disabledGradient = [
    Color(0xFF6B7280),
    Color(0xFF4B5563),
  ];

  static const Color defaultShadowColor = Color(0xFFec4899);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final effectiveGradientColors = isDisabled
        ? (disabledGradientColors ?? disabledGradient)
        : (gradientColors ?? primaryGradient);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(14);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: effectiveGradientColors,
          ),
          borderRadius: effectiveBorderRadius,
          // 只在非禁用状态显示阴影
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: (shadowColor ?? defaultShadowColor)
                        .withValues(alpha: 0.3),
                    blurRadius: shadowBlurRadius,
                    offset: shadowOffset,
                  ),
                ],
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: effectiveBorderRadius,
          splashColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.2),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: padding,
            alignment: Alignment.center,
            child: isLoading
                ? (loadingWidget ??
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ))
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 小尺寸渐变按钮（预设样式）
class GradientButtonSmall extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GradientButtonSmall({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      height: 32,
      fontSize: 12,
      padding: const EdgeInsets.symmetric(vertical: 6),
      borderRadius: BorderRadius.circular(10),
      shadowBlurRadius: 6,
      shadowOffset: const Offset(0, 2),
    );
  }
}

/// 大尺寸渐变按钮（预设样式）
class GradientButtonLarge extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GradientButtonLarge({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      height: 56,
      fontSize: 16,
      padding: const EdgeInsets.symmetric(vertical: 12),
      borderRadius: BorderRadius.circular(16),
      shadowBlurRadius: 12,
      shadowOffset: const Offset(0, 4),
    );
  }
}

/// 自定义颜色的渐变按钮（预设样式）
class GradientButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color> colors;
  final Color shadowColor;

  const GradientButtonCustom({
    super.key,
    required this.text,
    required this.colors,
    required this.shadowColor,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      gradientColors: colors,
      shadowColor: shadowColor,
    );
  }
}
