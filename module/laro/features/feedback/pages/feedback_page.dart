import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as speech;

import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';
import '../../../core/pink_ui.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  speech.SpeechToText? _speechToText;
  bool _isListening = false;
  bool _isInitializing = false;
  String _lastRecognizedWords = '';
  String _dictationSeedText = '';

  @override
  void dispose() {
    _stopListening();
    _speechToText?.cancel();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    if (_isInitializing) {
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    try {
      _speechToText ??= speech.SpeechToText();
      final granted = await _ensureSpeechPermissions();
      if (!granted) {
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
        return;
      }

      final isAvailable = await _speechToText!.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          }
        },
        onError: (error) {
          if (!mounted) {
            return;
          }

          setState(() {
            _isListening = false;
            _isInitializing = false;
          });

          final errorMsg = error.toString().toLowerCase();
          if (errorMsg.contains('permission') ||
              errorMsg.contains('denied') ||
              errorMsg.contains('unauthorized')) {
            _showPermissionDeniedDialog();
          } else {
            _showSnackBar('Speech recognition failed. Please try again.');
          }
        },
      );

      if (!isAvailable) {
        setState(() {
          _isInitializing = false;
        });
        _showSnackBar('Speech recognition is not available on this device.');
        return;
      }

      _dictationSeedText = _feedbackController.text.trim();

      await _speechToText!.listen(
        onResult: (result) {
          if (!mounted) {
            return;
          }

          final spokenText = result.recognizedWords.trim();
          final nextText = _mergeDictationText(
            seedText: _dictationSeedText,
            spokenText: spokenText,
          );

          setState(() {
            _lastRecognizedWords = spokenText;
            _feedbackController.value = TextEditingValue(
              text: nextText,
              selection: TextSelection.collapsed(offset: nextText.length),
            );
            if (result.finalResult) {
              _isListening = false;
            }
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: speech.SpeechListenOptions(
          partialResults: true,
        ),
      );

      if (mounted) {
        setState(() {
          _isListening = true;
          _isInitializing = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isListening = false;
        _isInitializing = false;
      });
      _showSnackBar('Failed to start speech recognition. Please try again.');
    }
  }

  Future<bool> _ensureSpeechPermissions() async {
    final micStatus = await Permission.microphone.request();
    final speechStatus = await Permission.speech.request();

    final granted = micStatus.isGranted && speechStatus.isGranted;
    if (granted) {
      return true;
    }

    if (micStatus.isPermanentlyDenied || speechStatus.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    _showSnackBar('Microphone and speech access are required for voice input.');
    return false;
  }

  String _mergeDictationText({
    required String seedText,
    required String spokenText,
  }) {
    if (seedText.isEmpty) {
      return spokenText;
    }
    if (spokenText.isEmpty) {
      return seedText;
    }
    return '$seedText $spokenText';
  }

  Future<void> _stopListening() async {
    await _speechToText?.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      _showSnackBar('Please enter your feedback.');
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!')),
    );
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      AppRoutes.back();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'To use voice input, please allow microphone access in Settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PinkPageScaffold(
      leading: const PinkBackButton(onTap: AppRoutes.back),
      title: 'Feedback',
      centerTitle: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            PinkGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PinkSectionTitle(
                    title: 'Tell us what feels off',
                    subtitle:
                        'We simplified the page so the writing area stays calm and focused.',
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  TextField(
                    controller: _feedbackController,
                    minLines: 7,
                    maxLines: 10,
                    textInputAction: TextInputAction.done,
                    cursorColor: AppTheme.primaryMain,
                    decoration: const InputDecoration(
                      hintText:
                          'What would make this app feel even more delightful?',
                    ),
                  ),
                  if (_lastRecognizedWords.isNotEmpty && _isListening) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    PinkPill(
                      text: 'Listening: $_lastRecognizedWords',
                      backgroundColor: AppTheme.secondaryLight,
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacingMd),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleVoiceInput,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _isListening
                                ? AppTheme.primaryMain
                                : AppTheme.secondaryLight,
                            shape: BoxShape.circle,
                            boxShadow: [
                              AppTheme.shadow(
                                _isListening
                                    ? AppTheme.primaryMain
                                    : AppTheme.textPrimary,
                                _isListening ? 0.16 : 0.08,
                              ),
                            ],
                          ),
                          child: _isInitializing
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.textInverse,
                                  ),
                                )
                              : Icon(
                                  _isListening
                                      ? Icons.mic_rounded
                                      : Icons.mic_none_rounded,
                                  size: 20,
                                  color: _isListening
                                      ? AppTheme.textInverse
                                      : AppTheme.textPrimary,
                                ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: PinkPrimaryButton(
                          label: 'Submit',
                          onPressed: _submitFeedback,
                          leading: const Icon(Icons.send_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }
}
