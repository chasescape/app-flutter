import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'history_logic.dart';

// 统一配色（沿用 Lunar Whisper 风格）
const Color _bg = Color(0xFFF6F4FB);
const Color _surface = Color(0xFFFDFBFF);
const Color _separator = Color(0xFFE6E0EF);
const Color _titleColor = Color(0xFF242129);
const Color _mutedColor = Color(0xFF7C7785);
const Color _accent = Color(0xFF8F6AD8);
const Color _accentDeep = Color(0xFF6F4AD0);

const Color _lunarPink = Color(0xFFEED0F2);
const Color _lunarLavender = Color(0xFF9EBAEB);
const Color _lunarSky = Color(0xFF96DFF5);
const LinearGradient _pageBgGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: [0.0, 0.3, 0.7, 1.0],
  colors: [_lunarPink, _lunarLavender, _lunarSky, _bg],
);

class HistoryPage extends StatelessWidget {
  HistoryPage({Key? key}) : super(key: key);

  final HistoryLogic logic = Get.put(HistoryLogic());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(gradient: _pageBgGradient),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(theme, topPadding),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: _GuidesList(theme: theme, logic: logic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, double topPadding) {
    return Column(
      children: [
        SizedBox(height: topPadding + 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _separator, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: _titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Guides',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                        decoration: TextDecoration.none,
                      ) ??
                      const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                        decoration: TextDecoration.none,
                      ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuidesList extends StatelessWidget {
  const _GuidesList({required this.theme, required this.logic});

  final ThemeData theme;
  final HistoryLogic logic;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final guides = logic.guides;

      if (guides.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _accent.withValues(alpha: 0.08),
                _accent.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _accent.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: _accent,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Tips',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _titleColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No planned guides yet. Create and schedule places in Guides to see history here.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: _mutedColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: guides
            .map(
              (g) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GuideCard(theme: theme, item: g),
              ),
            )
            .toList(),
      );
    });
  }
}

class _GuideCard extends StatefulWidget {
  const _GuideCard({required this.theme, required this.item});

  final ThemeData theme;
  final HistoryGuide item;

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final item = widget.item;

    String? firstDateLabel;
    String? lastDateLabel;
    if (item.steps.isNotEmpty) {
      String extractDate(String step) {
        final parts = step.split('·');
        return parts.first.trim();
      }

      firstDateLabel = extractDate(item.steps.first);
      lastDateLabel = extractDate(item.steps.last);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _separator, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_accent, _accentDeep],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.folder_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _titleColor,
                                  decoration: TextDecoration.none,
                                ) ??
                                const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _titleColor,
                                  decoration: TextDecoration.none,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.summary,
                            style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  color: _mutedColor,
                                  height: 1.4,
                                  decoration: TextDecoration.none,
                                ) ??
                                const TextStyle(
                                  fontSize: 13,
                                  color: _mutedColor,
                                  height: 1.4,
                                  decoration: TextDecoration.none,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 160),
                      turns: _expanded ? 0.5 : 0.0,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _mutedColor,
                      ),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _separator, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(item.steps.length, (index) {
                        final step = item.steps[index];
                        final parts = step.split('·');
                        final dateLabel = parts.isNotEmpty
                            ? parts[0].trim()
                            : '';
                        final timeLabel = parts.length > 1
                            ? parts[1].trim()
                            : '';
                        final title = parts.length > 2
                            ? parts.sublist(2).join('·').trim()
                            : '';
                        final isLast = index == item.steps.length - 1;

                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 左侧日期 + 时间
                              SizedBox(
                                width: 56,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateLabel,
                                      style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: _titleColor,
                                            decoration: TextDecoration.none,
                                          ) ??
                                          const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: _titleColor,
                                            decoration: TextDecoration.none,
                                          ),
                                    ),
                                    if (timeLabel.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        timeLabel,
                                        style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              fontSize: 11,
                                              color: _mutedColor,
                                              decoration: TextDecoration.none,
                                            ) ??
                                            const TextStyle(
                                              fontSize: 11,
                                              color: _mutedColor,
                                              decoration: TextDecoration.none,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // 中间时间线圆点 + 竖线
                              Column(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _accent,
                                    ),
                                  ),
                                  if (!isLast)
                                    Container(
                                      width: 2,
                                      height: 32,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: _accent.withValues(alpha: 0.18),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              // 右侧目的地卡片
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _bg,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    title.isEmpty ? step : title,
                                    style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _titleColor,
                                          decoration: TextDecoration.none,
                                        ) ??
                                        const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _titleColor,
                                          decoration: TextDecoration.none,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
