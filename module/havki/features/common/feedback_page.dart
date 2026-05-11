import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:havki/havki/app/theme/app_theme.dart';
import 'package:speech_to_text/speech_to_text.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isSpeechInitialized = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_isListening) {
      _speechToText.stop();
    }
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final available = await _speechToText.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) => setState(() => _isListening = status == 'listening'),
    );
    if (mounted) {
      setState(() => _isSpeechInitialized = available);
    }
  }

  Future<void> _toggleListening() async {
    if (!_isSpeechInitialized) {
      _showDialog('Voice input unavailable', 'Speech recognition is not available on this device.');
      return;
    }
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      return;
    }
    await _speechToText.listen(
      onResult: (result) => setState(() => _controller.text = result.recognizedWords),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
    setState(() => _isListening = true);
  }

  Future<void> _submitFeedback() async {
    if (_controller.text.trim().isEmpty) {
      _showDialog('Empty feedback', 'Please enter your feedback before submitting.');
      return;
    }
    await _showSuccessSheet();
  }

  void _showDialog(String title, String content, {bool closeTwice = false}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (closeTwice) {
                Navigator.pop(context);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.12),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) {
        Future<void>.delayed(const Duration(milliseconds: 1400), () {
          if (sheetContext.mounted) {
            Navigator.pop(sheetContext);
          }
        });

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  boxShadow: AppShadows.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(AppBorderRadius.full),
                      ),
                    ),
                    const Text(
                      'Thanks for the feedback',
                      style: TextStyle(
                        fontSize: AppFontSizes.h3,
                        fontWeight: AppFontWeights.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'We got your note and will take a look.',
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        color: AppColors.textSecondary,
                        height: AppLineHeights.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: AppBackground(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    AppCircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: AppSectionTitle(
                        eyebrow: '',
                        title: 'Feedback',
                        subtitle: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppGlassCard(
                  child: TextField(
                    controller: _controller,
                    maxLines: 10,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts, suggestions, or visual ideas...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleListening,
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                        label: Text(_isListening ? 'Listening...' : 'Voice Input'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitFeedback,
                        child: const Text('Send'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
