import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:achievenote/gozi/routes/global_router.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';
import 'package:achievenote/gozi/widgets/common/app_button.dart';
import 'package:achievenote/gozi/widgets/common/app_card.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';

/// Feedback Page - User feedback and support with voice input
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Speech to text - delayed initialization
  SpeechToText? _speechToText;
  bool _isListening = false;
  bool _isInitializing = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    // Stop listening and release speech resources
    if (_speechToText != null) {
      if (_isListening) {
        _speechToText!.stop();
      }
      _speechToText!.cancel();
    }
    super.dispose();
  }

  /// Initialize speech to text (lazy init - only when user clicks voice button)
  Future<bool> _initializeSpeech() async {
    if (_speechToText != null) {
      return true;
    }

    setState(() {
      _isInitializing = true;
    });

    try {
      _speechToText = SpeechToText();
      final initialized = await _speechToText!.initialize(
        onError: (error) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }

      return initialized;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return false;
    }
  }

  /// Request microphone and speech recognition permissions
  Future<bool> _requestPermissions() async {
    try {
      final microphoneStatus = await Permission.microphone.request();
      final speechStatus = await Permission.speech.request();

      return microphoneStatus.isGranted && speechStatus.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Handle voice input button click
  Future<void> _handleVoiceInput() async {
    // If currently listening, stop
    if (_isListening) {
      await _speechToText?.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }

    // Prevent double click during initialization
    if (_isInitializing) {
      return;
    }

    // Initialize speech to text (lazy init)
    final initialized = await _initializeSpeech();
    if (!initialized) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Speech recognition failed to initialize',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error,
          colorText: AppTheme.primaryWhite,
        );
      }
      return;
    }

    // Request permissions
    final hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      if (mounted) {
        Get.snackbar(
          'Permission Required',
          'Please enable microphone and speech recognition permissions in settings',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error,
          colorText: AppTheme.primaryWhite,
          duration: const Duration(seconds: 4),
        );
      }
      return;
    }

    // Start listening
    await _speechToText?.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });

          // Append recognized text to input
          final recognizedWords = result.recognizedWords;
          if (recognizedWords.isNotEmpty) {
            final currentText = _feedbackController.text;
            _feedbackController.text = currentText.isEmpty
                ? recognizedWords
                : '$currentText $recognizedWords';
          }
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: false,
        cancelOnError: true,
      ),
      onSoundLevelChange: null,
    );

    if (mounted) {
      setState(() {
        _isListening = true;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      // Show success and go back
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Get.snackbar(
          'Thank You',
          'Your feedback has been submitted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.success,
          colorText: AppTheme.primaryWhite,
        );
        GlobalRouter.I.goBack();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        Get.snackbar(
          'Error',
          'Failed to submit feedback: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error,
          colorText: AppTheme.primaryWhite,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feedback Input with Voice Button
              AppCard(
                padding: const EdgeInsets.all(AppTheme.md),
                margin: EdgeInsets.zero,
                borderRadius: AppTheme.radiusXl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _feedbackController,
                            maxLines: 8,
                            maxLength: 500,
                            cursorColor: AppTheme.accentRed,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your feedback';
                              }
                              if (value.trim().length < 10) {
                                return 'Feedback must be at least 10 characters';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText:
                                  'Share your thoughts, suggestions, or report issues...',
                              hintStyle:
                                  TextStyle(color: AppTheme.textDisabled),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.sm),
                        // Voice Input Button
                        InkWell(
                          onTap: _isInitializing ? null : _handleVoiceInput,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? AppTheme.accentRed
                                  : _isInitializing
                                      ? AppTheme.primaryWhite
                                          .withValues(alpha: 0.72)
                                      : AppTheme.accentRed.withValues(
                                          alpha: 0.1,
                                        ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              color: _isListening
                                  ? AppTheme.primaryWhite
                                  : _isInitializing
                                      ? AppTheme.textDisabled
                                      : AppTheme.accentRed,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.xl),

              // Submit Button
              AppButton(
                text: 'Submit Feedback',
                onPressed: _submitFeedback,
                isLoading: _isSubmitting,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
