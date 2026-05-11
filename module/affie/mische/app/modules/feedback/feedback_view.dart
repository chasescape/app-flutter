import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/mische_background.dart';
import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  FeedbackPage({Key? key}) : super(key: key);

  final FeedbackLogic logic = Get.put(FeedbackLogic());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0E12),
        body: MischeBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'We’d love your feedback',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tell us what’s working, what’s not, and what you want next. We read every message.',
                          style: TextStyle(
                            color: Color(0xFFB9B9C3),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInputCard(),
                        const SizedBox(height: 16),
                        _buildVoiceCard(),
                        const SizedBox(height: 28),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A22),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A2A33)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(
            child: Text(
              'Feedback',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A33)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your message',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: logic.messageController,
            maxLines: 6,
            minLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Share your thoughts, feature requests, or issues...',
              hintStyle: const TextStyle(color: Color(0xFF7A7A86), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF121219),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22).withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A33)),
      ),
      child: Row(
        children: [
          Obx(
            () => Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: logic.isListening.value
                      ? [const Color(0xFFFF7A4B), const Color(0xFFFF4E88)]
                      : [const Color(0xFF8F3CF0), const Color(0xFFE94AA8)],
                ),
              ),
              child: IconButton(
                onPressed: logic.toggleListening,
                icon: Icon(
                  logic.isListening.value ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(
              () => Text(
                logic.isListening.value ? 'Listening... Tap to stop' : 'Tap to record voice note',
                style: const TextStyle(
                  color: Color(0xFFE1E1E6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: logic.isSubmitting.value ? null : logic.submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E8C),
            disabledBackgroundColor: const Color(0xFFE91E8C).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: logic.isSubmitting.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text(
                  'Send feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
