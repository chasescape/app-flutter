import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_strings.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/models/app_models.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _contentController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  FeedbackType _selectedType = FeedbackType.bugReport;
  bool _isLoadingSpeech = false;
  bool _isListening = false;
  bool _hasSpeech = false;
  String _dictationSeedText = '';
  String? _localeId;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _contentController.dispose();
    if (_isListening) {
      _speechToText.stop();
    }
    super.dispose();
  }

  Future<void> _initSpeech() async {
    setState(() {
      _isLoadingSpeech = true;
    });

    try {
      final hasSpeech = await _speechToText.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );

      if (hasSpeech) {
        try {
          final systemLocale = await _speechToText.systemLocale();
          _localeId = systemLocale?.localeId;
        } catch (e) {
          debugPrint('Failed to get system locale: $e');
        }
      }
      _hasSpeech = hasSpeech;
    } catch (e) {
      debugPrint('Failed to initialize speech: $e');
      _hasSpeech = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSpeech = false;
        });
      }
    }
  }

  Future<void> _toggleListening() async {
    if (_isLoadingSpeech) {
      return;
    }

    if (_isListening) {
      await _speechToText.stop();
      return;
    }

    if (!_hasSpeech) {
      await _initSpeech();
      if (!_hasSpeech) {
        // _showSnack(
        //   AppStrings.warning,
        //   AppStrings.voiceInputNotAvailable,
        //   backgroundColor: AppColors.warning,
        //   textColor: Colors.black,
        // );
        return;
      }
    }

    _dictationSeedText = _contentController.text.trim();

    final bool? available = await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 8),
      localeId: (_localeId?.isNotEmpty ?? false) ? _localeId : null,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        autoPunctuation: true,
        listenMode: ListenMode.dictation,
        cancelOnError: true,
      ),
    );

    if (!mounted) return;
    if (available == true) {
      setState(() {
        _isListening = true;
      });
    } else {
      // _showSnack(
      //   AppStrings.warning,
      //   'Voice input could not start. Please tap to try again.',
      //   backgroundColor: AppColors.warning,
      //   textColor: Colors.black,
      // );
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    final recognizedWords = result.recognizedWords.trim();
    final nextText = _joinRecognizedText(_dictationSeedText, recognizedWords);
    setState(() {
      if (nextText.isNotEmpty) {
        _contentController.value = TextEditingValue(
          text: nextText,
          selection: TextSelection.collapsed(offset: nextText.length),
        );
      }
      if (result.finalResult) {
        _dictationSeedText = nextText;
      }
    });
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    setState(() {
      _isListening = status == 'listening';
    });
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;

    setState(() {
      _isListening = false;
    });

    if (error.permanent) {
      _hasSpeech = false;
    }

    switch (error.errorMsg) {
      case 'error_no_match':
      case 'error_retry':
        return;
      default:
        // _showSnack(
        //   AppStrings.error,
        //   'Voice input failed: ${error.errorMsg}',
        //   backgroundColor: AppColors.error,
        // );
    }
  }

  String _joinRecognizedText(String prefix, String recognizedWords) {
    if (prefix.isEmpty) {
      return recognizedWords;
    }
    if (recognizedWords.isEmpty) {
      return prefix;
    }
    return '$prefix $recognizedWords';
  }

  Future<void> _submitFeedback() async {
    if (_contentController.text.trim().isEmpty) {
      // _showSnack(
      //   AppStrings.warning,
      //   AppStrings.pleaseFillContent,
      //   backgroundColor: AppColors.warning,
      //   textColor: Colors.black,
      // );
      return;
    }

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.pop(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        content: Text(
          'Thank you for your feedback.',
          style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZeriaScreen(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            ZeriaHeader(
              title: 'Feedback',
              subtitle: 'TELL US WHAT TO IMPROVE',
              leading: ZeriaIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 22),
            ZeriaSurfaceCard(
              radius: 32,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Text(
                    'What kind of feedback is this?',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: FeedbackType.values.map((type) {
                      final selected = _selectedType == type;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient:
                                selected ? AppColors.accentGradient : null,
                            color: selected ? null : AppColors.surfaceTint,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            type.displayName,
                            style: AppTextStyles.small.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text('Your message', style: AppTextStyles.bodyBold),
                  const SizedBox(height: 10),
                  _buildTextFieldCard(
                    controller: _contentController,
                    hintText: AppStrings.feedbackHint,
                    maxLines: 7,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        gradient:
                            (_isListening || _isLoadingSpeech) ? null : AppColors.accentGradient,
                        color:
                            (_isListening || _isLoadingSpeech) ? AppColors.surfaceTint : null,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isLoadingSpeech
                                ? Icons.hourglass_top_rounded
                                : _isListening
                                    ? Icons.stop_circle_outlined
                                    : Icons.mic_none_rounded,
                            color: (_isListening || _isLoadingSpeech)
                                ? AppColors.brandHotPink
                                : Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isLoadingSpeech
                                  ? 'Preparing voice input...'
                                  : _isListening
                                      ? AppStrings.recording
                                      : AppStrings.tapToSpeak,
                              style: AppTextStyles.bodyBold.copyWith(
                                color: (_isListening || _isLoadingSpeech)
                                    ? AppColors.brandHotPink
                                    : Colors.white,
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
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text(AppStrings.submit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldCard({
    required TextEditingController controller,
    required String hintText,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        cursorColor: AppColors.brandHotPink,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}
