import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/midora_design.dart';
import '../../core/widgets/midora_open_background.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  String _selectedCategory = 'General';
  bool _isSubmitting = false;
  bool _isListening = false;
  bool _speechEnabled = false;

  final List<String> _categories = const [
    'General',
    'Bug Report',
    'Feature Request',
    'Account Issue',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      _showPermissionWarning(
          'Microphone permission is required for voice input.');
      return;
    }

    if (GetPlatform.isIOS) {
      final speechStatus = await Permission.speech.request();
      if (!speechStatus.isGranted) {
        _showPermissionWarning(
            'Speech recognition permission is required for voice input.');
        return;
      }
    }

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _feedbackController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );

    if (mounted) {
      setState(() => _isListening = true);
    }
  }

  void _showPermissionWarning(String message) {
    Get.snackbar(
      'Permission Required',
      message,
      backgroundColor: AppColors.warning,
      colorText: AppColors.primaryDark,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your feedback',
        backgroundColor: AppColors.error,
        colorText: AppColors.textInverse,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    Get.snackbar(
      'Thank You',
      'Your feedback has been submitted',
      backgroundColor: AppColors.success,
      colorText: AppColors.primaryDark,
      snackPosition: SnackPosition.BOTTOM,
    );
    _feedbackController.clear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MidoraOpenBackground(overlayOpacity: 0.24),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MidoraTopBar(
                    title: 'Feedback',
                    subtitle:
                        'Tell us how Midora can feel even softer and smarter.',
                    leading: MidoraCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  MidoraGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MidoraSectionTitle(
                          title: 'Category',
                          subtitle: 'Pick the topic that fits your note best.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _categories
                              .map(
                                (category) => _CategoryPill(
                                  label: category,
                                  selected: _selectedCategory == category,
                                  onTap: () =>
                                      setState(() => _selectedCategory = category),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MidoraGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MidoraSectionTitle(
                          title: 'Your Note',
                          subtitle: 'Text or voice, whatever feels easier.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _feedbackController,
                          maxLines: 7,
                          cursorColor: AppColors.primaryLight,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textInverse),
                          decoration: const InputDecoration(
                            hintText: 'Tell us what you think...',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            _VoiceCircleButton(
                              enabled: _speechEnabled,
                              isListening: _isListening,
                              onTap: _toggleListening,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: MidoraPrimaryButton(
                                label: 'Submit',
                                onTap: _isSubmitting ? null : _submitFeedback,
                                isLoading: _isSubmitting,
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

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        selected ? AppColors.primaryDark : AppColors.textInverse;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.borderRadiusFull,
          gradient: selected ? AppColors.buttonGradient : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.10),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.35)
                : AppColors.glassBorderStrong,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.small.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _VoiceCircleButton extends StatelessWidget {
  const _VoiceCircleButton({
    required this.enabled,
    required this.isListening,
    required this.onTap,
  });

  final bool enabled;
  final bool isListening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 46.0;
    final icon = isListening ? Icons.stop_rounded : Icons.mic_rounded;

    return MidoraGlassCard(
      padding: EdgeInsets.zero,
      blur: 12,
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          onPressed: enabled ? onTap : null,
          icon: Icon(
            icon,
            color: enabled ? AppColors.textInverse : AppColors.textMuted,
          ),
          iconSize: 22,
          tooltip: isListening ? 'Stop listening' : 'Voice input',
        ),
      ),
    );
  }
}
