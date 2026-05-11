import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/explore_card/explore_card.dart';
import 'history_logic.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late final HistoryLogic logic;
  late final AnimationController _animationController;
  late final Animation<double> _summaryFade;
  late final Animation<Offset> _summarySlide;
  late final Animation<double> _recentFade;
  late final Animation<Offset> _recentSlide;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    logic = Get.put(HistoryLogic());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _summaryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _summarySlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _recentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.65, curve: Curves.easeOut),
      ),
    );
    _recentSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.65, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmDialog(BuildContext context, int index) {
    final entry = logic.entries[index];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black26,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 22),
              const Text(
                'Delete History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2A26),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${entry.title}"?\n\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: const Color(0xFF2D2A26).withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D2A26),
                        side: const BorderSide(color: Color(0xFFE8E0D7)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        logic.removeHistoryEntry(index);
                        Get.snackbar(
                          'Deleted',
                          'History entry removed',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          backgroundColor: const Color(0xFF2D2A26),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD8B792)
                            .withValues(alpha: 0.85),
                        foregroundColor: const Color(0xff130e14),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Delete'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1EA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Get.back(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFF2D2A26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generation History',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2A26),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your personalized style tips',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8D857C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8E0D7)),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewportHeight = constraints.maxHeight;
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FadeTransition(
                          opacity: _summaryFade,
                          child: SlideTransition(
                            position: _summarySlide,
                            child: _SummaryCard(theme: theme),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeTransition(
                          opacity: _recentFade,
                          child: SlideTransition(
                            position: _recentSlide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Recent generations',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                        color: const Color(0xFF4A3C2E),
                                      ),
                                    ),
                                    const Spacer(),
                                    Obx(() {
                                      final canClear = logic.entries.isNotEmpty;
                                      return InkWell(
                                        onTap: canClear ? logic.clearHistory : null,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          child: Text(
                                            'Clear',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: canClear
                                                  ? const Color(0xFFC8A57E)
                                                  : const Color(0xFFB8B0A6),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Obx(() {
                                  if (logic.entries.isEmpty) {
                                    return const _EmptyState();
                                  }
                                  return _AnimatedHistoryGrid(
                                    scrollOffset: _scrollOffset,
                                    viewportHeight: viewportHeight,
                                    logic: logic,
                                    onDeleteConfirm: _showDeleteConfirmDialog,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 历史列表：滚入视口时淡入 + 上移
class _AnimatedHistoryGrid extends StatelessWidget {
  const _AnimatedHistoryGrid({
    required this.scrollOffset,
    required this.viewportHeight,
    required this.logic,
    required this.onDeleteConfirm,
  });

  final double scrollOffset;
  final double viewportHeight;
  final HistoryLogic logic;
  final void Function(BuildContext context, int index) onDeleteConfirm;

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 2;
    const crossAxisSpacing = 12.0;
    const mainAxisSpacing = 12.0;
    const itemHeight = 336.0;
    const gridTopOffset = 170.0;
    const rowHeight = itemHeight + mainAxisSpacing;

    final entries = logic.entries;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        mainAxisExtent: itemHeight,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ crossAxisCount;
        final itemTop = gridTopOffset + row * rowHeight;
        final delta = scrollOffset + viewportHeight - itemTop;
        final t = (delta / 140).clamp(0.0, 1.0);
        final opacity = t;
        final translateY = (1 - t) * 20.0;

        final entry = entries[index];
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: ExploreCard(
              title: entry.title,
              subtitle: entry.subtitle,
              imagePath: entry.imagePath,
              onTap: () {
                Get.toNamed(
                  '/details',
                  arguments: {
                    'imagePath': entry.imagePath,
                    'title': entry.title,
                    'description': entry.subtitle,
                    'tips': entry.tips,
                  },
                );
              },
              onLongPress: () => onDeleteConfirm(context, index),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD8B792),
            Color(0xFFC8A57E),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generated content at a glance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Review your history and generated results anytime.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE8E0D7),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D2A26).withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8A57E).withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  color: Color(0xFF4A3C2E),
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No history yet',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2D2A26),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your recent generations will show up here once you start exploring.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8D857C),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE8E0D7)),
                    foregroundColor: const Color(0xFF4A3C2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Go back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
