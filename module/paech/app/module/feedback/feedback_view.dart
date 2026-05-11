import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'feedback_logic.dart';

class FeedbackPage extends StatefulWidget {
  FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with SingleTickerProviderStateMixin {
  late final FeedbackLogic logic;
  late final AnimationController _animationController;
  late final Animation<double> _introFade;
  late final Animation<Offset> _introSlide;
  late final Animation<double> _tagFade;
  late final Animation<Offset> _tagSlide;
  late final Animation<double> _problemFade;
  late final Animation<Offset> _problemSlide;
  late final Animation<double> _submitFade;
  late final Animation<Offset> _submitSlide;

  @override
  void initState() {
    super.initState();
    logic = Get.put(FeedbackLogic());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );
    _introFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _introSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _tagFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
      ),
    );
    _tagSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
      ),
    );
    _problemFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOut),
      ),
    );
    _problemSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOut),
      ),
    );
    _submitFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.65, curve: Curves.easeOut),
      ),
    );
    _submitSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.65, curve: Curves.easeOut),
      ),
    );
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                  Text(
                    'Feedback',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2A26),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8E0D7)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeTransition(
                      opacity: _introFade,
                      child: SlideTransition(
                        position: _introSlide,
                        child: _IntroCard(theme: theme),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _tagFade,
                      child: SlideTransition(
                        position: _tagSlide,
                        child: _TagCard(theme: theme, logic: logic),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _problemFade,
                      child: SlideTransition(
                        position: _problemSlide,
                        child: _ProblemInputCard(theme: theme, logic: logic),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _submitFade,
                      child: SlideTransition(
                        position: _submitSlide,
                        child: _PrimaryAction(theme: theme, logic: logic),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'We typically respond within 1–2 business days. Please do not share sensitive personal information.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8D857C),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.theme});

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
            top: -54,
            right: -54,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
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
                        'Share Your Feedback',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Help us improve by sharing your thoughts and experiences.',
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

class _TagCard extends StatelessWidget {
  const _TagCard({required this.theme, required this.logic});

  final ThemeData theme;
  final FeedbackLogic logic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Category (optional)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: const Color(0xFF4A3C2E),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final tags = logic.quickTags;
            final selected = logic.selectedTag.value;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final tag in tags)
                  _TagChip(
                    label: tag,
                    isSelected: selected == tag,
                    onTap: () => logic.selectTag(tag),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TagChip extends StatefulWidget {
  const _TagChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<_TagChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final bg = isSelected ? const Color(0xFF2D2A26) : const Color(0xFFF2EBE3);
    final fg = isSelected ? Colors.white : const Color(0xFF8B7968);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: widget.onTap,
        onHighlightChanged: (isHighlighted) {
          if (_pressed == isHighlighted) return;
          setState(() => _pressed = isHighlighted);
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          scale: _pressed ? 0.98 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProblemInputCard extends StatelessWidget {
  const _ProblemInputCard({required this.theme, required this.logic});

  final ThemeData theme;
  final FeedbackLogic logic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Describe the problem',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: const Color(0xFF4A3C2E),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3EF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEFE7DE)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              children: [
                TextField(
                  controller: logic.problemController,
                  minLines: 5,
                  maxLines: 10,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText:
                        'Describe what happened, what you expected, and any steps to reproduce the issue...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFB8B0A6),
                      height: 1.35,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF2D2A26),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Obx(() {
                      final isRecording = logic.isRecording.value;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: logic.toggleRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isRecording
                                ? const Color(0xFF2D2A26)
                                : const Color(0xFFF2EBE3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isRecording
                                  ? const Color(0xFF2D2A26)
                                  : const Color(0xFFEFE7DE),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isRecording ? Icons.stop : Icons.mic_none,
                                size: 18,
                                color: isRecording
                                    ? Colors.white
                                    : const Color(0xFF8B7968),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isRecording ? 'Stop Recording' : 'Voice Input',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isRecording
                                      ? Colors.white
                                      : const Color(0xFF8B7968),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _PrimaryAction extends StatefulWidget {
  const _PrimaryAction({required this.theme, required this.logic});

  final ThemeData theme;
  final FeedbackLogic logic;

  @override
  State<_PrimaryAction> createState() => _PrimaryActionState();
}

class _PrimaryActionState extends State<_PrimaryAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSubmitting = widget.logic.isSubmitting.value;

      return GestureDetector(
        onTapDown: (_) {
          if (!isSubmitting) setState(() => _pressed = true);
        },
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: isSubmitting ? null : widget.logic.submitFeedback,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          scale: isSubmitting ? 1.0 : (_pressed ? 0.98 : 1.0),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: isSubmitting
                  ? const Color(0xFF2D2A26).withValues(alpha: 0.7)
                  : const Color(0xFF2D2A26),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Submit',
                    style: widget.theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
