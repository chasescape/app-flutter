import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _controller = TextEditingController();
  SpeechToText? _speechToText;
  bool _isListening = false;
  bool _isInitializing = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    if (_speechToText != null) {
      _speechToText!.stop();
    }
    super.dispose();
  }

  Future<void> _toggleListening() async {
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
      if (_speechToText == null) {
        _speechToText = SpeechToText();
        final isAvailable = await _speechToText!.initialize(
          onError: (error) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isListening = false;
              _isInitializing = false;
            });
            _showErrorSnackbar('Speech recognition error. Please try again.');
          },
          onStatus: (status) {
            if (!mounted) {
              return;
            }
            if (status == 'done' || status == 'notListening') {
              setState(() {
                _isListening = false;
              });
            }
          },
        );

        if (!isAvailable) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isInitializing = false;
          });
          _showErrorSnackbar(
              'Speech recognition is not available on this device.');
          return;
        }
      }

      final micStatus = await Permission.microphone.request();
      final speechStatus = await Permission.speech.request();

      if (!micStatus.isGranted || !speechStatus.isGranted) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isInitializing = false;
        });
        _showErrorSnackbar(
            'Microphone and speech recognition permissions are required.');
        return;
      }

      await _speechToText!.listen(
        onResult: (result) {
          if (!mounted) {
            return;
          }
          setState(() {
            _controller.value = TextEditingValue(
              text: result.recognizedWords,
              selection: TextSelection.collapsed(
                offset: result.recognizedWords.length,
              ),
            );
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _isListening = true;
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitializing = false;
      });
      _showErrorSnackbar(
          'Failed to start speech recognition. Please try again.');
    }
  }

  Future<void> _stopListening() async {
    if (_speechToText != null) {
      await _speechToText!.stop();
    }
    setState(() {
      _isListening = false;
    });
  }

  void _showErrorSnackbar(String message) {
    Get.dialog<void>(
      _FeedbackStatusDialog(
        title: 'Error',
        message: message,
        buttonText: 'Back',
        icon: Icons.close_rounded,
        onPressed: Get.back,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(18, 12, 18, bottomInset > 0 ? 12 : 20),
            child: Column(
              children: [
                Row(
                  children: [
                    _ActionCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: Get.back,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Feedback', style: AppTextStyles.h3),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16B96B7B),
                        offset: Offset(0, 16),
                        blurRadius: 42,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FeedbackIntroCard(
                        isListening: _isListening,
                        isInitializing: _isInitializing,
                      ),
                      const SizedBox(height: 18),
                      _ComposerCard(
                        controller: _controller,
                        isListening: _isListening,
                        isInitializing: _isInitializing,
                        isSubmitting: _isSubmitting,
                        onVoiceTap: _isSubmitting ? null : _toggleListening,
                        onSubmitTap: _isListening || _isInitializing
                            ? null
                            : _submitFeedback,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (_controller.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your feedback');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    Get.back<void>();

    await Future<void>.delayed(const Duration(milliseconds: 160));

    Get.dialog<void>(
      _FeedbackStatusDialog(
        title: 'Feedback sent',
        message: 'Thank you for helping us improve Welgo.',
        buttonText: 'Back',
        icon: Icons.check_rounded,
        onPressed: Get.back,
      ),
    );
  }
}

class _FeedbackStatusDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IconData icon;
  final VoidCallback onPressed;

  const _FeedbackStatusDialog({
    required this.title,
    required this.message,
    required this.buttonText,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: AppGradients.hero,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.textPrimary,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: buttonText,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackIntroCard extends StatelessWidget {
  final bool isListening;
  final bool isInitializing;

  const _FeedbackIntroCard({
    required this.isListening,
    required this.isInitializing,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = isInitializing
        ? 'Preparing voice input...'
        : isListening
            ? 'Listening now. Tap again to stop.'
            : 'You can type or use voice input for a more natural note.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF6E5ED)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0DDA8E9E),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              gradient: AppGradients.hero,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isListening ? Icons.mic_rounded : Icons.favorite_border_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us what feels good or rough',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: AppTextStyles.small.copyWith(
                    color: isListening
                        ? AppColors.accentDark
                        : AppColors.textSecondary,
                    fontWeight: isListening ? FontWeight.w700 : FontWeight.w500,
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

class _ComposerCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool isInitializing;
  final bool isSubmitting;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onSubmitTap;

  const _ComposerCard({
    required this.controller,
    required this.isListening,
    required this.isInitializing,
    required this.isSubmitting,
    required this.onVoiceTap,
    required this.onSubmitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 360,
        maxHeight: 460,
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF7E6EE)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isListening
                      ? AppColors.accent.withValues(alpha: 0.34)
                      : const Color(0xFFF4DDE6),
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                cursorColor: AppColors.accent,
                textInputAction: TextInputAction.done,
                textAlignVertical: TextAlignVertical.top,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Tell us what you think...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: const Color(0xFFD2C2C9),
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ComposerButton(
                  label: isInitializing
                      ? 'Preparing...'
                      : isListening
                          ? 'Stop'
                          : 'Voice input',
                  icon:
                      isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  onTap: onVoiceTap,
                  isPrimary: false,
                  isLoading: isInitializing,
                  accent: isListening,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ComposerButton(
                  label: 'Submit',
                  icon: null,
                  onTap: onSubmitTap,
                  isPrimary: true,
                  isLoading: isSubmitting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.86),
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _ComposerButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isLoading;
  final bool accent;

  const _ComposerButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    required this.isLoading,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    final foreground = isPrimary
        ? Colors.white
        : accent
            ? AppColors.accent
            : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        child: Ink(
          height: 46,
          decoration: BoxDecoration(
            color: isPrimary
                ? enabled
                    ? AppColors.ink
                    : AppColors.ink.withValues(alpha: 0.45)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
            border: Border.all(
              color: isPrimary
                  ? Colors.transparent
                  : accent
                      ? AppColors.accent.withValues(alpha: 0.35)
                      : const Color(0xFFF0DCE4),
            ),
            boxShadow: isPrimary
                ? const [
                    BoxShadow(
                      color: Color(0x24000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: foreground),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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
}
