import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  FeedbackPage({super.key});

  final FeedbackLogic logic = Get.put(FeedbackLogic());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFFFF5F9),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _TopBar(onBack: Get.back),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _HeroCard(),
                      const SizedBox(height: 14),
                      _MoodCard(
                        moods: logic.moods,
                        selectedIndex: logic.selectedMoodIndex.value,
                        onTap: logic.selectMood,
                      ),
                      const SizedBox(height: 14),
                      _InputCard(
                        messageController: logic.messageController,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: logic.isSubmitting.value ? null : logic.sendMessage,
                          icon: logic.isSubmitting.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, color: Colors.white),
                          label: Text(
                            logic.isSubmitting.value ? 'Sending...' : 'Send Feedback',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFF18FA9),
                            disabledBackgroundColor: const Color(0xFFEDB5C5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(
        children: <Widget>[
          _RoundBackButton(onTap: onBack),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 44),
                child: Text(
                  'Feedback',
                  style: TextStyle(
                    fontSize: 32 / 1.4,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF272737),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF303244)),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFA3BB), Color(0xFFF48EAA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0x33FFFFFF),
            child: Icon(Icons.favorite_rounded, color: Colors.white),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'We would love your thoughts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tell us what you like, what feels confusing, or what you want next in Flira.',
                  style: TextStyle(
                    color: Color(0xFFFFF1F6),
                    height: 1.45,
                    fontSize: 13,
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

class _MoodCard extends StatelessWidget {
  const _MoodCard({
    required this.moods,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> moods;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7DEE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'How are you feeling about Flira?',
            style: TextStyle(
              color: Color(0xFF4A3D45),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(moods.length, (int i) {
              final bool selected = i == selectedIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFF5A1B8) : const Color(0xFFFFF3F7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? const Color(0xFFF08DA8) : const Color(0xFFF7DDE6),
                    ),
                  ),
                  child: Text(
                    moods[i],
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF8D7880),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.messageController,
  });

  final TextEditingController messageController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7DEE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Your feedback',
            style: TextStyle(color: Color(0xFF7C666F), fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: messageController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Tell us what we can improve...',
              alignLabelWithHint: true,
              filled: true,
              fillColor: const Color(0xFFFFF8FB),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF4DCE5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF08DA8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
