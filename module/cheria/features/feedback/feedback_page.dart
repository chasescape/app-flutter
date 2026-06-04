import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../app/theme/theme.dart';
import '../../widgets/visuals/sunny_visuals.dart';

/// Feedback Page
/// Voice input and text submission for user feedback
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _textController = TextEditingController();

  // Speech to text instance - lazy initialization
  stt.SpeechToText? _speechToText;
  bool _isListening = false;
  bool _isInitializing = false;
  String _lastRecognizedWords = '';

  @override
  void dispose() {
    _textController.dispose();
    // Stop and release speech recognition
    if (_speechToText != null) {
      _speechToText!.stop();
      _speechToText = null;
    }
    super.dispose();
  }

  /// Toggle voice input
  Future<void> _toggleVoiceInput() async {
    // If currently listening, stop
    if (_isListening) {
      await _stopListening();
      return;
    }

    // Prevent repeated clicks during initialization
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      // Lazy initialization of speech to text
      if (_speechToText == null) {
        _speechToText = stt.SpeechToText();

        final hasSpeech = await _speechToText!.initialize(
          onError: (error) {
            SmartDialog.showToast(
                'Speech recognition error: ${error.errorMsg}');
            setState(() {
              _isListening = false;
              _isInitializing = false;
            });
          },
        );

        if (!hasSpeech) {
          SmartDialog.showToast(
            'Speech recognition not available on this device',
          );
          setState(() {
            _isInitializing = false;
          });
          return;
        }

        // Request microphone and speech recognition permissions
        final micStatus = await Permission.microphone.request();
        final speechStatus = await Permission.speech.request();

        if (!micStatus.isGranted || !speechStatus.isGranted) {
          SmartDialog.showToast(
            'Microphone or speech recognition permission denied. Please grant permissions in settings.',
          );
          setState(() {
            _isInitializing = false;
          });
          return;
        }
      }

      setState(() {
        _isInitializing = false;
      });

      // Start listening
      await _startListening();
    } catch (e) {
      SmartDialog.showToast('Failed to initialize speech recognition');
      setState(() {
        _isInitializing = false;
      });
    }
  }

  /// Start listening to voice input
  Future<void> _startListening() async {
    if (_speechToText == null) return;

    setState(() {
      _isListening = true;
      _lastRecognizedWords = '';
    });

    await _speechToText!.listen(
      onResult: (result) {
        setState(() {
          _lastRecognizedWords = result.recognizedWords;
          if (result.finalResult) {
            // Append to text controller
            final currentText = _textController.text;
            final newText = currentText.isEmpty
                ? _lastRecognizedWords
                : '$currentText $_lastRecognizedWords';
            _textController.text = newText;
            _lastRecognizedWords = '';
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      listenMode: stt.ListenMode.confirmation,
      onSoundLevelChange: (level) {
        // Can be used for visual feedback
      },
    );
  }

  /// Stop listening
  Future<void> _stopListening() async {
    if (_speechToText == null) return;

    await _speechToText!.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// Submit feedback
  Future<void> _submitFeedback() async {
    final feedback = _textController.text.trim();

    if (feedback.isEmpty) {
      SmartDialog.showToast('Please enter your feedback');
      return;
    }

    // Show loading
    SmartDialog.showLoading(
      msg: 'Submitting...',
      backType: SmartBackType.normal,
    );

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Close loading
      SmartDialog.dismiss();

      // Show success message
      SmartDialog.showToast('Thank you for your feedback!');

      // Navigate back
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('Failed to submit feedback. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        centerTitle: true,
      ),
      body: SunnyPage(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input section
              SunnyCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Feedback',
                      style: AppTypography.getBodyTextStyle(
                        const Color(AppColors.textPrimary),
                      ).copyWith(
                        fontWeight: AppTypography.semibold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Text input field
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      cursorColor: const Color(AppColors.primaryMain),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Type your feedback here...',
                        hintStyle: AppTypography.getBodyTextStyle(
                          const Color(AppColors.textSecondary),
                        ).copyWith(
                          color: const Color(AppColors.textSecondary)
                              .withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: const Color(AppColors.backgroundSecondary),
                        border: OutlineInputBorder(
                          borderRadius: AppBorderRadius.allMD,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppBorderRadius.allMD,
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppBorderRadius.allMD,
                          borderSide: const BorderSide(
                            color: Color(AppColors.primaryMain),
                            width: 2,
                          ),
                        ),
                      ),
                      style: AppTypography.getBodyTextStyle(
                        const Color(AppColors.textPrimary),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Voice input button
                    Row(
                      children: [
                        IconButton(
                          onPressed: _isInitializing ? null : _toggleVoiceInput,
                          icon: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            color: _isListening
                                ? const Color(AppColors.error)
                                : const Color(AppColors.primaryMain),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: _isListening
                                ? const Color(AppColors.error).withOpacity(0.1)
                                : const Color(AppColors.primaryMain)
                                    .withOpacity(0.12),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _isInitializing
                                ? 'Initializing...'
                                : _isListening
                                    ? 'Listening... Tap to stop'
                                    : 'Tap to start voice input',
                            style: AppTypography.getSmallTextStyle(
                              _isListening
                                  ? const Color(AppColors.primaryMain)
                                  : const Color(AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Show real-time recognition result
                    if (_lastRecognizedWords.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.primaryMain)
                              .withOpacity(0.12),
                          borderRadius: AppBorderRadius.allMD,
                        ),
                        child: Text(
                          '$_lastRecognizedWords...',
                          style: AppTypography.getSmallTextStyle(
                            const Color(AppColors.primaryMain),
                          ).copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppColors.buttonPrimary),
                    foregroundColor: const Color(AppColors.textInverse),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.allMD,
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Submit Feedback',
                    style: AppTypography.getBodyTextStyle(
                      const Color(AppColors.textInverse),
                    ).copyWith(
                      fontWeight: AppTypography.semibold,
                    ),
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
