import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/rova_background.dart';
import 'feedback_logic.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FeedbackLogic logic = Get.find<FeedbackLogic>();
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      await _speechToText.initialize();
    } catch (_) {
      // ignore
    }
  }

  Future<bool> _ensurePermissions() async {
    final mic = await Permission.microphone.request();
    final speech = await Permission.speech.request();
    return mic.isGranted && speech.isGranted;
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      return;
    }

    final ok = await _ensurePermissions();
    if (!ok) {
      Get.snackbar(
        'Permission required',
        'Please allow Microphone and Speech Recognition in Settings.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final available = await _speechToText.initialize();
    if (!available) {
      Get.snackbar(
        'Speech unavailable',
        'Speech recognition is not available on this device.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isListening = true);
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      },
      // ignore: deprecated_member_use
      listenMode: ListenMode.dictation,
      // ignore: deprecated_member_use
      partialResults: true,
      // ignore: deprecated_member_use
      cancelOnError: true,
    );
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Empty feedback',
        'Please type something first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Mock submit
    await Future<void>.delayed(const Duration(milliseconds: 500));

    _controller.clear();
    Get.back();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    Get.snackbar(
      'Success',
      'Thanks for your feedback！',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color pink = Color(0xFFE84B7B);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RovaBackground(
        blurSigma: 4,
        overlayColor: const Color(0x22FFFFFF),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x33FFE7EF),
            Color(0x22FFFFFF),
          ],
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 10),
              GlassCard(
                borderRadius: 22,
                blurSigma: 20,
                backgroundColor: const Color(0x55FFFFFF),
                borderColor: const Color(0x55FFFFFF),
                shadowColor: const Color(0x12000000),
                highlight: false,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: pink, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'We would love your thoughts',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tell us what you like, what feels confusing, or what you want next in Rova.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.2,
                              color: Colors.black.withValues(alpha: 0.62),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GlassCard(
                borderRadius: 22,
                blurSigma: 20,
                backgroundColor: const Color(0x66FFFFFF),
                borderColor: const Color(0x66FFFFFF),
                shadowColor: const Color(0x12000000),
                highlight: false,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tell us what you want',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Describe bugs, feature requests, or your ideal manicure styles.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.2,
                        color: Colors.black.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      cursorColor: pink,
                      textInputAction: TextInputAction.done,
                      maxLines: 7,
                      decoration: InputDecoration(
                        hintText: 'Type here…',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.78),
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: pink,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.45),
                              side: BorderSide(
                                color: pink.withValues(alpha: 0.35),
                              ),
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                            ),
                            onPressed: _toggleListening,
                            child: Icon(
                              _isListening
                                  ? Icons.mic_rounded
                                  : Icons.mic_none_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pink,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                elevation: 0,
                              ),
                              onPressed: _submit,
                              child: const Text(
                                'Submit',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
