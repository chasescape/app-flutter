import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_button.dart';
import 'package:cliss/cliss/app/widgets/app_card.dart';
import 'package:cliss/cliss/app/widgets/app_scaffold.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _contentController = TextEditingController();
  SpeechToText? _speechToText;
  FeedbackType _selectedType = FeedbackType.suggestion;
  bool _isListening = false;
  bool _isSubmitting = false;
  bool _isInitializing = false;

  @override
  void dispose() {
    _contentController.dispose();
    _speechToText?.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText?.stop();
      setState(() => _isListening = false);
      return;
    }
    if (_isInitializing) return;

    setState(() => _isInitializing = true);
    try {
      _speechToText ??= SpeechToText();
      final initialized = await _speechToText!.initialize(
        onError: (error) {
          setState(() {
            _isListening = false;
            _isInitializing = false;
          });
          _toast('Voice recognition error: ${error.errorMsg}', error: true);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );
      if (!initialized) {
        setState(() => _isInitializing = false);
        _toast('Failed to initialize speech recognition', error: true);
        return;
      }

      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        setState(() => _isInitializing = false);
        _toast('Microphone permission is required', error: true);
        return;
      }

      setState(() {
        _isInitializing = false;
        _isListening = true;
      });
      await _speechToText!.listen(
        onResult: (result) {
          setState(() => _contentController.text = result.recognizedWords);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (_) {
      setState(() {
        _isListening = false;
        _isInitializing = false;
      });
      _toast('Failed to start voice input', error: true);
    }
  }

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty) {
      _toast('Please enter your feedback', error: true);
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _toast('Thank you for your feedback!');
    Navigator.pop(context);
  }

  void _toast(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.semanticError : AppColors.primaryMain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Feedback')),
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tell us what feels off', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'We kept this form as soft and calm as the rest of the product.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: FeedbackType.values
                      .map(
                        (type) => ChoiceChip(
                      label: Text(type.label),
                      selected: _selectedType == type,
                      checkmarkColor: AppColors.textInverse,
                      onSelected: (_) => setState(() => _selectedType = type),
                    ),
                  )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Your message', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Describe the issue or idea...',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  text: _isListening ? 'Stop Recording' : 'Voice Input',
                  onPressed: _isInitializing ? null : _toggleListening,
                  isSecondary: true,
                  icon: _isListening ? Icons.stop_rounded : Icons.mic_none_rounded,
                  width: double.infinity,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Submit Feedback',
            onPressed: _submit,
            isLoading: _isSubmitting,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

enum FeedbackType {
  suggestion('Suggestion'),
  bug('Bug'),
  other('Other');

  final String label;
  const FeedbackType(this.label);
}
