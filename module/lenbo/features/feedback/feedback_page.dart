import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lenbo/lenbo/core/theme/app_colors.dart';
import 'package:lenbo/lenbo/core/theme/app_spacing.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _controller.dispose();
    _speechToText.stop();
    super.dispose();
  }

  void _initSpeech() async {
    _speechAvailable = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted && _isListening) {
            setState(() => _isListening = false);
          }
        }
      },
      onError: (error) {
        if (mounted && _isListening) {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      _showSnackBar('Speech recognition is not available on this device.');
      return;
    }

    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        _showSnackBar('Microphone permission is required for voice input.');
        return;
      }

      final speechStatus = await Permission.speech.request();
      if (!speechStatus.isGranted) {
        _showSnackBar('Speech recognition permission is required.');
        return;
      }

      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
      setState(() => _isListening = true);
    }
  }

  void _submitFeedback() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Please enter your feedback before submitting.');
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);

    if (mounted) {
      _showSnackBar('Thank you for your feedback!');
      Get.back();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bgPrimary,
                    AppColors.accentMain.withAlpha(56),
                    AppColors.accentMain.withAlpha(34),
                    AppColors.bgPrimary,
                  ],
                  stops: const [0, 0.38, 0.78, 1],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(56),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(71), width: 0.8),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Icon(
                            Icons.favorite,
                            size: 16,
                            color: Color(0xFFE84C8B),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'We would love your thoughts',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D1420),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tell us what you like, what feels confusing, or what you want next in Rova.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.3,
                                  color: Color(0xFF84556D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(56),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withAlpha(77), width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPinkGlow.withAlpha(36),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tell us what you want',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C1320),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Describe bugs, feature requests, or your ideal manicure styles.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.3,
                            color: Color(0xFF875067),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(209),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            cursorColor: AppColors.secondaryMain,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF44303B),
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(14),
                              hintText: 'Type here...',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF6A5963).withAlpha(217),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleListening,
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _isListening
                                      ? AppColors.secondaryMain
                                      : Colors.white.withAlpha(115),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withAlpha(107),
                                    width: 0.8,
                                  ),
                                ),
                                child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none_rounded,
                                  size: 18,
                                  color: _isListening
                                      ? AppColors.textInverse
                                      : const Color(0xFF8C5A73),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitFeedback,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE94B8D),
                                    foregroundColor: AppColors.textInverse,
                                    disabledBackgroundColor: const Color(0xFFEAA0C0),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AppColors.textInverse,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Submit',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
