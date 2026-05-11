import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widget/kissmi_background.dart';
import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  FeedbackPage({super.key});

  final FeedbackLogic logic = Get.put(FeedbackLogic());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KissmiBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _InfoTip(
                  icon: Icons.tips_and_updates_outlined,
                  text:
                  'Tip: the more specific you are, the easier it is for us to fix issues and improve your experience.',
                ),
                const SizedBox(height: 16),
                Text(
                  'What is this about?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () {
                    final selected = logic.selectedTag.value;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _ChipButton(
                          icon: Icons.bug_report,
                          label: 'Bug',
                          selected: selected == 'Bug',
                          onTap: () => logic.selectTag('Bug'),
                        ),
                        _ChipButton(
                          icon: Icons.lightbulb,
                          label: 'Idea',
                          selected: selected == 'Idea',
                          onTap: () => logic.selectTag('Idea'),
                        ),
                        _ChipButton(
                          icon: Icons.favorite,
                          label: 'Praise',
                          selected: selected == 'Praise',
                          onTap: () => logic.selectTag('Praise'),
                        ),
                        _ChipButton(
                          icon: Icons.chat_bubble_outline,
                          label: 'Chat quality',
                          selected: selected == 'Chat quality',
                          onTap: () => logic.selectTag('Chat quality'),
                        ),
                        _ChipButton(
                          icon: Icons.monetization_on_outlined,
                          label: 'Coins / billing',
                          selected: selected == 'Coins / billing',
                          onTap: () => logic.selectTag('Coins / billing'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                _FeedbackCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        controller: logic.textController,
                        minLines: 4,
                        maxLines: 7,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText:
                          'Tell us what you like, what feels wrong, or what you wish Kissmi could do better.',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Obx(
                            () => InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: logic.startVoiceInput,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: logic.isListening.value ? 0.16 : 0.06,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      logic.isListening.value
                                          ? Icons.mic
                                          : Icons.mic_none,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      logic.isListening.value
                                          ? 'Listening...'
                                          : 'Voice to text',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Obx(
                      () {
                    final sending = logic.isSending.value;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: sending ? null : () => logic.sendFeedback(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: sending
                            ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                            : const Text(
                          'Send Feedback',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B203B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? const Color(0xFFEC4899)
        : Colors.white.withValues(alpha: 0.14);
    final Color backgroundColor = selected
        ? const Color(0xFFEC4899).withValues(alpha: 0.24)
        : const Color(0xFF1B203B).withValues(alpha: 0.9);
    final Color textColor = Colors.white.withValues(
      alpha: selected ? 0.95 : 0.85,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 14,
                color: Colors.white.withValues(alpha: 0.95),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTip extends StatelessWidget {
  const _InfoTip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            size: 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
