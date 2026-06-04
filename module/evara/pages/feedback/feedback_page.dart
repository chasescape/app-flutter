import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signals/signals_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/evara_scaffold.dart';

/// Feedback page with optional voice input.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final isSubmitting = signal<bool>(false);
  String selectedCategory = 'General';

  SpeechToText? _speechToText;
  bool _isListening = false;
  bool _isInitializing = false;

  final List<String> _categories = [
    'General',
    'Bug Report',
    'Feature Request',
    'UI/UX',
    'Performance',
    'Other',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    if (_speechToText != null && _isListening) {
      _speechToText!.stop();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      SmartDialog.showToast('Please enter your feedback');
      return;
    }

    isSubmitting.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        SmartDialog.showToast('Thank you for your feedback!');
        _feedbackController.clear();
        Get.back();
      }
    } catch (_) {
      if (mounted) {
        SmartDialog.showToast('Failed to submit feedback');
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _speechToText!.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }

    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      if (_speechToText == null) {
        _speechToText = SpeechToText();
        final isAvailable = await _speechToText!.initialize();
        if (!isAvailable) {
          if (mounted) {
            SmartDialog.showToast('Speech recognition not available on this device');
          }
          setState(() {
            _isInitializing = false;
          });
          return;
        }
      }

      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        if (mounted) {
          SmartDialog.showToast('Microphone permission is required for voice input');
        }
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      final speechStatus = await Permission.speech.request();
      if (!speechStatus.isGranted) {
        if (mounted) {
          SmartDialog.showToast('Speech recognition permission is required');
        }
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      await _speechToText!.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _feedbackController.text = result.recognizedWords;
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      if (mounted) {
        setState(() {
          _isListening = true;
          _isInitializing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        SmartDialog.showToast('Failed to start voice input');
      }
      setState(() {
        _isListening = false;
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return EvaraScaffold(
      safeTop: false,
      appBar: AppBar(title: const Text('Feedback')),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingLg,
          110,
          AppTheme.spacingLg,
          AppTheme.spacingXxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EvaraGlassCard(
              blur: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.caption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories
                        .map(
                          (category) => _CategoryChip(
                            label: category,
                            isSelected: selectedCategory == category,
                            onTap: () {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            const Text(
              'Your feedback',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.caption,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            EvaraGlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  TextField(
                    controller: _feedbackController,
                    maxLines: 8,
                    textInputAction: TextInputAction.done,
                    cursorColor: AppTheme.primaryLight,
                    decoration: const InputDecoration(
                      hintText: 'Describe your idea, issue, or polish request...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(AppTheme.spacingMd),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingSm),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: _isInitializing ? null : _toggleVoiceInput,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingMd,
                              vertical: AppTheme.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? AppTheme.error.withValues(alpha: 0.14)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isListening ? Icons.stop : Icons.mic_none_rounded,
                                  color: _isListening
                                      ? AppTheme.error
                                      : AppTheme.textSecondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isListening
                                      ? 'Stop'
                                      : _isInitializing
                                          ? 'Starting...'
                                          : 'Voice input',
                                  style: TextStyle(
                                    color: _isListening
                                        ? AppTheme.error
                                        : AppTheme.textSecondary,
                                    fontSize: AppTheme.caption,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Watch((context) {
              if (isSubmitting.value) {
                return const SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppTheme.accentMain,
                      ),
                    ),
                  ),
                );
              }

              return AppWidgets.gradientButton(
                text: 'Submit feedback',
                onPressed: _submit,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationNormal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppTheme.textInverse
                : AppTheme.textSecondary,
            fontSize: AppTheme.caption,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
