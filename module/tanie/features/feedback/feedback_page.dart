import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_button.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _contactController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  final List<String> _types = ['Bug Report', 'Other'];
  String _feedbackType = 'Bug Report';
  bool _isListening = false;
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _speechToText.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) =>
          setState(() => _isListening = status == 'listening'),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _contactController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _feedbackController.text = result.recognizedWords;
          _confidence = result.confidence;
        });
      },
    );
    setState(() => _isListening = true);
  }

  void _submitFeedback() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submitted successfully')),
    );
    context.pop();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: AppBackdrop(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AppIconCircle(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: AppSectionTitle(
                          title: 'Feedback',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Feedback Type', style: AppTextStyles.h3),
                        const SizedBox(height: 14),
                        Row(
                          children: _types.map((type) {
                            final isSelected = _feedbackType == type;
                            final isLast = type == _types.last;

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () =>
                                        setState(() => _feedbackType = type),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 160),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryMain
                                            : AppColors.cardMuted,
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryMain
                                              : AppColors.cardBorder,
                                        ),
                                      ),
                                      child: Text(
                                        type,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.caption.copyWith(
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Feedback', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _feedbackController,
                          maxLines: 7,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your feedback'
                              : null,
                          decoration: const InputDecoration(
                            hintText:
                                'Describe what you liked, what felt off, or what you want next...',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _isListening
                                ? AppColors.accentLight
                                : AppColors.cardMuted,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              AppIconCircle(
                                icon: _isListening
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                onTap: _toggleListening,
                                backgroundColor: _isListening
                                    ? AppColors.error
                                    : AppColors.white,
                                foregroundColor: _isListening
                                    ? AppColors.white
                                    : AppColors.secondaryMain,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isListening
                                          ? 'Listening... tap to stop'
                                          : 'Tap to start voice input',
                                      style: AppTextStyles.bodyLarge,
                                    ),
                                    if (_confidence > 0) ...[
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value: _confidence,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        backgroundColor: AppColors.white,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          AppColors.secondaryMain,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppPrimaryButton(
                    text: 'Submit Feedback',
                    onPressed: _submitFeedback,
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
