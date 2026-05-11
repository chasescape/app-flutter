import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/widgets/page_header.dart';
import 'package:mimiu/mimiu/app/widgets/symmetric_gradient_background.dart';

import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  FeedbackLogic get logic => Get.put(FeedbackLogic());

  @override
  Widget build(BuildContext context) {
    logic;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: SymmetricGradientBackground()),
          SafeArea(
              child: Column(
              children: [
              const PageHeader(
                title: 'Feedback',
                titleSize: 22,
                titleWeight: FontWeight.w800,
                useGradientTitle: false,
                showBack: true,
                centerTitle: true,
                padding: EdgeInsets.fromLTRB(16, 6, 16, 10),
              ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
                    children: [
                      const _TipCard(),
                      _InputCard(logic: logic),
                      const SizedBox(height: 16),
                      Obx(() {
                      return SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed:
                              logic.isSubmitting.value ? null : logic.submit,
                          style: FilledButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFFBBF24).withValues(alpha: 0.88),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                                side: BorderSide(
                                  color: const Color(0xFF92400E)
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                            child: logic.isSubmitting.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Submit',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w900),
                                  ),
                        ),
                      );
                    }),
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

class _InputCard extends StatelessWidget {
  const _InputCard({required this.logic});

  final FeedbackLogic logic;

  @override
  Widget build(BuildContext context) {
    final mutedGold = const Color(0xFFFDE68A).withValues(alpha: 0.55);
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              clipBehavior: Clip.antiAlias,
              child: _goldDispersion(),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              clipBehavior: Clip.antiAlias,
              child: const _BreathingGlow(),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF92400E).withValues(alpha: 0.35),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade900.withValues(alpha: 0.86),
                Colors.black.withValues(alpha: 0.92),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF78350F).withValues(alpha: 0.36),
                blurRadius: 44,
                spreadRadius: 6,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text(
            'Type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFBBF24),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final current = logic.feedbackType.value;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: FeedbackLogic.feedbackTypes
                  .map(
                    (t) => _TypeTag(
                      text: t,
                      selected: t == current,
                      onTap: () => logic.feedbackType.value = t,
                    ),
                  )
                  .toList(),
            );
          }),
          const SizedBox(height: 14),
          const Text(
            'Message',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: logic.controller,
            minLines: 6,
            maxLines: 10,
            cursorColor: const Color(0xFFFBBF24),
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Share your feedback...',
              hintStyle: TextStyle(color: mutedGold),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: const Color(0xFF92400E).withValues(alpha: 0.35),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: const Color(0xFF92400E).withValues(alpha: 0.25),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFFFBBF24),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            final listening = logic.isListening.value;
            return Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: logic.toggleListening,
                      style: FilledButton.styleFrom(
                        backgroundColor: listening
                            ? const Color(0xFF7F1D1D).withValues(alpha: 0.55)
                            : const Color(0xFF78350F).withValues(alpha: 0.55),
                        foregroundColor: const Color(0xFFFDE68A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(
                            color:
                                const Color(0xFF92400E).withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      icon: Icon(
                        listening ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 18,
                      ),
                      label: Text(
                        listening ? 'Listening… Tap to stop' : 'Voice input',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _goldDispersion() {
    return Stack(
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                gradient: const RadialGradient(
                  center: Alignment.center,
                  radius: 1.25,
                  colors: [
                    Color.fromRGBO(251, 191, 36, 0.30), // yellow-400
                    Color.fromRGBO(245, 158, 11, 0.16), // amber-500
                    Color.fromRGBO(0, 0, 0, 0.0),
                  ],
                  stops: [0.0, 0.62, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -30,
          left: -40,
          child: _blob(180, const Color(0xFFFBBF24).withValues(alpha: 0.30)),
        ),
        Positioned(
          bottom: -26,
          right: -38,
          child: _blob(200, const Color(0xFFF59E0B).withValues(alpha: 0.26)),
        ),
        Positioned(
          top: 60,
          right: -42,
          child: _blob(150, const Color(0xFFD97706).withValues(alpha: 0.20)),
        ),
        Positioned(
          bottom: 40,
          left: -44,
          child: _blob(160, const Color(0xFFFBBF24).withValues(alpha: 0.20)),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withValues(alpha: 0.40),
        border: Border.all(
          color: const Color(0xFF92400E).withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFFBBF24), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tip: Choose a type and describe what happened. We read every message.',
              style: TextStyle(
                color: Color(0xFFFDE68A),
                fontSize: 12,
                height: 1.25,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathingGlow extends StatefulWidget {
  const _BreathingGlow();

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1650),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_c.value);
          final a = 0.10 + 0.16 * t;
          final blur = 18 + 16 * t;
          return ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    const Color(0xFFFBBF24).withValues(alpha: a),
                    const Color(0xFFF59E0B).withValues(alpha: a * 0.55),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TypeTag extends StatelessWidget {
  const _TypeTag({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? const Color(0xFFFBBF24).withValues(alpha: 0.70)
        : const Color(0xFF92400E).withValues(alpha: 0.28);
    final bg = selected
        ? const Color(0xFF422006).withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.18);
    final fg = selected ? const Color(0xFFFDE68A) : const Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: bg,
          border: Border.all(color: border, width: selected ? 1.8 : 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1.0,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
