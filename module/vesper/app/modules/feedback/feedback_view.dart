import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/widgets/app_background.dart';

import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  FeedbackPage({Key? key}) : super(key: key);

  final FeedbackLogic logic = Get.put(FeedbackLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B1A2B),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2B1A2B)),
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        useImageBackground: true,
        safeArea: false,
        padding: EdgeInsets.zero,
        child: GetBuilder<FeedbackLogic>(
          builder: (logic) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: Stack(
                children: [
                  Positioned(
                    top: 140,
                    left: -40,
                    child: _blurBlob(
                      color: const Color(0xFFFF8AC4).withOpacity(0.35),
                      size: 180,
                    ),
                  ),
                  Positioned(
                    bottom: 200,
                    right: -30,
                    child: _blurBlob(
                      color: const Color(0xFFFFC247).withOpacity(0.25),
                      size: 200,
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _promptCard(),
                          const SizedBox(height: 16),
                          _typeCard(logic),
                          const SizedBox(height: 16),
                          _inputCard(logic),
                          const SizedBox(height: 12),
                          _voiceInputRow(logic),
                          const SizedBox(height: 16),
                          _sendButton(logic),
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
    );
  }

  Widget _promptCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF8AC4).withOpacity(0.35),
            const Color(0xFFFFB6D8).withOpacity(0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: const Text(
        'Tell us what you loved and what we can improve. Your feedback helps us make the training experience better.',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF2B1A2B),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _typeCard(FeedbackLogic logic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B1A2B),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: 'Bug',
                selected: logic.selectedType == 'Bug',
                onTap: () => logic.selectType('Bug'),
              ),
              _Chip(
                label: 'Feature Request',
                selected: logic.selectedType == 'Feature Request',
                onTap: () => logic.selectType('Feature Request'),
              ),
              _Chip(
                label: 'Pricing',
                selected: logic.selectedType == 'Pricing',
                onTap: () => logic.selectType('Pricing'),
              ),
              _Chip(
                label: 'Account',
                selected: logic.selectedType == 'Account',
                onTap: () => logic.selectType('Account'),
              ),
              _Chip(
                label: 'Other',
                selected: logic.selectedType == 'Other',
                onTap: () => logic.selectType('Other'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputCard(FeedbackLogic logic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: logic.textController,
        maxLines: 6,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Share your thoughts…',
          hintStyle: TextStyle(color: Color(0xFF6E5B6F)),
        ),
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF2B1A2B),
        ),
      ),
    );
  }

  Widget _voiceInputRow(FeedbackLogic logic) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Or use voice input',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF2B1A2B).withOpacity(0.8),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: OutlinedButton.icon(
            onPressed: logic.toggleListening,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2B1A2B),
              side: BorderSide(color: Colors.white.withOpacity(0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              backgroundColor: Colors.white.withOpacity(0.7),
            ),
            icon: Icon(
              logic.isListening ? Icons.stop_rounded : Icons.mic_rounded,
              size: 16,
            ),
            label: Text(
              logic.isListening ? 'Stop' : 'Record',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sendButton(FeedbackLogic logic) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5AA9), Color(0xFFFF3A92)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3A92).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextButton(
          onPressed: () {
            if (logic.textController.text.trim().isEmpty) {
              Get.snackbar('Tip', 'Please enter your feedback first.');
              return;
            }
            Get.snackbar('Success', 'Feedback submitted. Thank you!');
            logic.textController.clear();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Send Feedback',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _blurBlob({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFC2E0) : const Color(0xFFFFE8EE),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFFFF86C3)
                : Colors.white.withOpacity(0.9),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B1A2B),
          ),
        ),
      ),
    );
  }
}
