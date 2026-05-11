import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mimiu/mimiu/app/widgets/gradient_text.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBack = false,
    this.centerTitle = false,
    this.useGradientTitle = true,
    this.titleColor = Colors.white,
    this.backColor,
    this.titleWeight = FontWeight.w900,
    this.titleSize = 34,
    this.padding = const EdgeInsets.fromLTRB(24, 14, 24, 14),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;
  final bool centerTitle;
  final bool useGradientTitle;
  final Color titleColor;
  final Color? backColor;
  final FontWeight titleWeight;
  final double titleSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final resolvedBackColor = backColor ??
        (useGradientTitle ? const Color(0xFFFDE68A) : const Color(0xFFFBBF24));
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.92),
            Colors.black.withValues(alpha: 0.70),
            Colors.black.withValues(alpha: 0.00),
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Stack(
            children: [
              if (!centerTitle)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (showBack) ...[
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                  ),
                                  color: resolvedBackColor,
                                  iconSize: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: _titleWidget(
                                  title: title,
                                  titleSize: titleSize,
                                  titleWeight: titleWeight,
                                  useGradientTitle: useGradientTitle,
                                  titleColor: titleColor,
                                ),
                              ),
                            ],
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 14),
                      trailing!,
                    ],
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (showBack)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                ),
                                color: resolvedBackColor,
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: showBack ? 44 : 0,
                              right: trailing != null ? 44 : 0,
                            ),
                            child: Center(
                              child: _titleWidget(
                                title: title,
                                titleSize: titleSize,
                                titleWeight: titleWeight,
                                useGradientTitle: useGradientTitle,
                                titleColor: titleColor,
                              ),
                            ),
                          ),
                          if (trailing != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: trailing!,
                            ),
                        ],
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _titleWidget({
    required String title,
    required double titleSize,
    required FontWeight titleWeight,
    required bool useGradientTitle,
    required Color titleColor,
  }) {
    if (!useGradientTitle) {
      return Text(
        title,
        style: TextStyle(
          fontSize: titleSize,
          fontWeight: titleWeight,
          height: 1.0,
          color: titleColor,
          decoration: TextDecoration.none,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }
    return GradientText(
      title,
      gradient: const LinearGradient(
        colors: [
          Colors.white,
          Color(0xFFFDE68A),
          Color(0xFFFBBF24),
        ],
      ),
      style: TextStyle(
        fontSize: titleSize,
        fontWeight: titleWeight,
        height: 1.0,
        decoration: TextDecoration.none,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  static Widget _blurOrb({
    required double size,
    required Color color,
    required double blur,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur / 6, sigmaY: blur / 6),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
