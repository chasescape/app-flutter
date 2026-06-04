import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/glace_ui.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _controller = TextEditingController();
  bool _submitting = false;
  SpeechToText? _speechToText;
  bool _isListening = false;
  bool _isInitializing = false;

  @override
  void dispose() {
    _speechToText?.stop();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) {
      SmartDialog.showToast('Please enter your feedback');
      return;
    }

    setState(() => _submitting = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _submitting = false);
      SmartDialog.show(
        builder: (_) => AlertDialog(
          title: const Text('Thank you'),
          content: const Text(
            'Your feedback has been submitted successfully.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                SmartDialog.dismiss();
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    });
  }

  void _startVoiceInput() async {
    if (_isListening) {
      _speechToText?.stop();
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
        SmartDialog.showToast(
          'Speech recognition is not available on this device',
        );
        return;
      }
      _speechToText = speech;
    }

    setState(() => _isInitializing = false);

    _speechToText!.listen(
      onResult: (result) {
        if (result.finalResult) {
          final current = _controller.text;
          final separator = current.isEmpty ? '' : ' ';
          _controller.text = '$current$separator${result.recognizedWords}';
        }
      },
      // ignore: deprecated_member_use
      listenMode: ListenMode.dictation,
    );

    setState(() => _isListening = true);
  }

  @override
  Widget build(BuildContext context) {
    return GlaceScaffold(
      appBar: AppBar(
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Feedback',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      safeArea: false,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 92),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlaceSurfaceCard(
                color: Colors.white.withValues(alpha: 0.80),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 8,
                      maxLength: 1000,
                      cursorColor: AppColors.primary,
                      decoration: const InputDecoration(
                        hintText: 'Share your thoughts...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _startVoiceInput,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? AppColors.primary
                                  : AppColors.surfaceHighlight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _isListening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: _isListening
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Submit feedback'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const GlaceGlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Voice input works especially well for quick ideas and one-line refinement notes.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
