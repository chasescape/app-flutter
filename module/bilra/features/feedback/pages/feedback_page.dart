import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/widgets/bilra_ui.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({
    super.key,
    this.returnTab,
  });

  final int? returnTab;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  String _selectedCategory = 'General';

  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _speechInitialized = false;

  final List<String> _categories = const [
    'General',
    'Bug report',
    'Feature request',
    'Performance',
    'UI/UX',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    if (_isListening) {
      _speechToText.stop();
    }
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final available = await _speechToText.initialize(
      onError: (_) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      },
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() {
            _isListening = false;
          });
        }
      },
    );
    if (available && mounted) {
      setState(() {
        _speechInitialized = true;
      });
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechInitialized) {
      _showPrompt(
        title: 'Voice unavailable',
        message: 'Speech recognition is not available on this device.',
      );
      return;
    }

    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      _showPrompt(
        title: 'Permission required',
        message: 'Microphone access is needed for voice feedback input.',
      );
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _feedbackController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(partialResults: true),
    );
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });
    _feedbackController.clear();
    if (!mounted) return;
    AppRoutes.pop(context, true);
  }

  Future<void> _showPrompt({
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(title, style: AppTextStyles.h3),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: BilraBackdrop(
          child: SafeArea(
            bottom: false,
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: [
                  BilraTopBar(
                    title: 'Feedback',
                    subtitle: 'Tell us what feels better or needs polish',
                    leading: BilraIconChipButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => AppRoutes.pop(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BilraGlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We are aiming for a softer, more refined product feeling. Share bugs, rough edges, or ideas for what should feel more premium.',
                          style: AppTextStyles.caption.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Category',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _categories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryMain
                                      : AppColors.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.full,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: AppTextStyles.caption.copyWith(
                                    color: isSelected
                                        ? AppColors.textInverse
                                        : AppColors.primaryMain,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _feedbackController,
                          maxLines: 7,
                          textInputAction: TextInputAction.done,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your feedback.';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Your feedback',
                            hintText: 'What should we improve next?',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        GestureDetector(
                          onTap: _toggleListening,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? AppColors.surfaceTertiary
                                  : AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _isListening
                                        ? AppColors.primaryMain
                                        : AppColors.surfacePrimary,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    _isListening
                                        ? Icons.graphic_eq_rounded
                                        : Icons.mic_none_rounded,
                                    color: _isListening
                                        ? AppColors.textInverse
                                        : AppColors.primaryMain,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    _isListening
                                        ? 'Listening for your feedback...'
                                        : 'Tap to dictate feedback',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BilraPrimaryButton(
                    label: 'Submit feedback',
                    expanded: true,
                    loading: _isSubmitting,
                    onTap: _isSubmitting ? null : _submitFeedback,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
