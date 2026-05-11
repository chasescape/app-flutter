import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _isListening = false;
  bool _isInitializing = false;
  SpeechToText? _speechToText;

  @override
  void dispose() {
    _speechToText?.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onMicTap() async {
    if (_isListening) {
      await _speechToText?.stop();
      setState(() => _isListening = false);
      return;
    }

    if (_isInitializing) return;
    setState(() => _isInitializing = true);

    if (_speechToText == null) {
      final speech = SpeechToText();
      final available = await speech.initialize(
        onError: (_) => setState(() => _isListening = false),
        onStatus: (status) {
          if (status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );
      if (!available) {
        setState(() => _isInitializing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition is not available on this device.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      _speechToText = speech;
    }

    setState(() => _isInitializing = false);

    _speechToText!.listen(
      onResult: (result) {
        setState(() {
          final text = result.recognizedWords;
          if (text.isNotEmpty) {
            final current = _controller.text;
            _controller.text = current.isEmpty ? text : '$current $text';
            _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
          }
        });
      },
    );
    setState(() => _isListening = true);
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      context.pop();
      await _showSuccessSheet(rootNavigator);
    }
  }

  Future<void> _showSuccessSheet(NavigatorState rootNavigator) async {
    showModalBottomSheet<void>(
      context: rootNavigator.context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
            child: Container(
              height: 104,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A7B5AA6),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback submitted successfully.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Thank you for helping us improve the app.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 1800));
    if (rootNavigator.mounted && rootNavigator.canPop()) {
      rootNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DreamScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 110, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              eyebrow: 'Share',
              title: 'Tell us what would feel even better',
              subtitle: 'Type it out or use the mic for a quick note.',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: 8,
                        cursorColor: AppColors.secondary,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Tell us what you love, what feels off, or what you want next...',
                          contentPadding: EdgeInsets.fromLTRB(16, 16, 56, 16),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12, bottom: 12),
                        child: IconButton(
                          onPressed: _isInitializing ? null : _onMicTap,
                          icon: _isInitializing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                                  color: _isListening ? AppColors.error : AppColors.textSecondary,
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (_isListening) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Listening...',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Send feedback',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _controller.text.trim().isNotEmpty ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
