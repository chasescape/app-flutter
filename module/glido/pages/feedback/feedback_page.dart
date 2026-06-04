import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../theme/app_theme.dart';
import '../../widgets/glido_ui.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isSpeechEnabled = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initSpeechRecognition();
  }

  Future<void> _initSpeechRecognition() async {
    _isSpeechEnabled = await _speechToText.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    if (_isListening) {
      _speechToText.stop();
    }
    super.dispose();
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required for voice input'),
        ),
      );
    }
  }

  Future<void> _toggleListening() async {
    if (!_isSpeechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available on this device'),
        ),
      );
      return;
    }

    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      await _requestMicrophonePermission();
      return;
    }

    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        setState(() => _feedbackController.text = result.recognizedWords);
        if (result.finalResult) {
          setState(() => _isListening = false);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
    setState(() => _isListening = true);
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: GlidoPageBackground(
        topSafeArea: true,
        padding: const EdgeInsets.only(
          top: kToolbarHeight - AppTheme.spacingMd,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            0,
            AppTheme.spacingMd,
            120,
          ),
          children: [
            GlidoSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your feedback',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText:
                          'Tell us what feels polished, what feels heavy, or what you want to see improved.',
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Row(
                    children: [
                      if (_isSpeechEnabled)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting ? null : _toggleListening,
                            icon: Icon(
                              _isListening
                                  ? Icons.stop_circle_outlined
                                  : Icons.mic_none_rounded,
                            ),
                            label: Text(
                              _isListening ? 'Stop voice input' : 'Use voice',
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
