import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/utils/app_overlay.dart';
import '../../core/widgets/app_button.dart';

/// Feedback Page - User Feedback with Voice Input
/// Allows users to submit feedback with text and voice input
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const Color _berryPrimary = Color(0xFF8F355B);
  static const Color _berrySecondary = Color(0xFFB06A84);
  static const Color _pageTop = Color(0xFFFFEAF4);
  static const Color _pageMid = Color(0xFFFFD7E7);
  static const Color _pageBottom = Color(0xFFFFF5DF);
  static const Color _cardBg = Color(0xFFFFFCFE);
  static const List<Color> _actionGradient = [
    Color(0xFFFFB6CF),
    Color(0xFFFFDC88),
  ];

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  String _selectedType = 'Bug';
  bool _isListening = false;
  bool _isSubmitting = false;
  bool _speechEnabled = false;
  String _voiceText = '';

  final List<String> _feedbackTypes = [
    'Bug',
    'Feature Request',
    'Pricing',
    'Account',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contactController.dispose();
    if (_isListening) {
      _speechToText.stop();
    }
    super.dispose();
  }

  /// Initialize speech recognition
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        setState(() => _isListening = false);
        AppOverlay.showToast(
          context,
          message: 'Speech recognition error: ${error.errorMsg}',
          type: ToastType.error,
        );
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    setState(() {});
  }

  /// Toggle voice input
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      return;
    }

    // Request microphone permission
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      AppOverlay.showToast(
        context,
        message: 'Microphone permission is required for voice input',
        type: ToastType.warning,
      );
      return;
    }

    // Request speech recognition permission (iOS)
    final speechStatus = await Permission.speech.request();
    if (!speechStatus.isGranted) {
      AppOverlay.showToast(
        context,
        message: 'Speech recognition permission is required',
        type: ToastType.warning,
      );
      return;
    }

    if (!_speechEnabled) {
      AppOverlay.showToast(
        context,
        message: 'Speech recognition not available',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isListening = true;
      _voiceText = '';
    });

    await _speechToText.listen(
      onResult: (result) {
        final words = result.recognizedWords;
        setState(() {
          _voiceText = words;
          _contentController.value = TextEditingValue(
            text: words,
            selection: TextSelection.collapsed(offset: words.length),
          );
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _pageTop,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _berryPrimary),
        title: const Text(
          'Feedback',
          style: TextStyle(
            color: _berryPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_pageTop, _pageMid, _pageBottom],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: AppSpacing.paddingMD,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Text(
                    'Feedback Type',
                    style: AppTextStyles.h3Style.copyWith(color: _berryPrimary),
                  ),
                  AppSpacing.gapSM,
                  _buildSectionCard(child: _buildTypeSelector()),

                  AppSpacing.gapLG,

                  Text(
                    'Description',
                    style: AppTextStyles.h3Style.copyWith(color: _berryPrimary),
                  ),
                  AppSpacing.gapSM,
                  _buildSectionCard(
                    child: Stack(
                      children: [
                        TextField(
                          controller: _contentController,
                          maxLines: 8,
                          cursorColor: _berryPrimary,
                          textInputAction: TextInputAction.done,
                          style: AppTextStyles.bodyStyle.copyWith(color: _berryPrimary),
                          decoration: InputDecoration(
                            hintText: 'Please describe your feedback in detail...',
                            hintStyle: AppTextStyles.bodySecondaryStyle.copyWith(
                              color: _berrySecondary.withOpacity(0.85),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.fromLTRB(
                              0,
                              4,
                              0,
                              64,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 56,
                          bottom: 8,
                          child: AnimatedOpacity(
                            opacity: _isListening ? 1 : 0,
                            duration: const Duration(milliseconds: 160),
                            child: IgnorePointer(
                              ignoring: !_isListening,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F6).withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFB6CF).withOpacity(0.75),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.graphic_eq,
                                      size: 18,
                                      color: _berryPrimary,
                                    ),
                                    AppSpacing.gapXS,
                                    Expanded(
                                      child: Text(
                                        _voiceText.isEmpty ? 'Listening...' : _voiceText,
                                        style: AppTextStyles.captionMediumStyle.copyWith(
                                          color: _berryPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _toggleListening,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: _isListening
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFFF8CA8),
                                          Color(0xFFFFB6CF),
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: _actionGradient,
                                      ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD28E).withOpacity(0.26),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isListening ? Icons.stop : Icons.mic,
                                color: _berryPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.gapXL,

                  Theme(
                    data: Theme.of(context).copyWith(
                      elevatedButtonTheme: ElevatedButtonThemeData(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: _berryPrimary,
                          textStyle: AppTextStyles.buttonStyle.copyWith(
                            color: _berryPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFFF566B),
                            Color(0xFFF48DBA),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFFFE7A6),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD28E).withOpacity(0.32),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: AppButton(
                        text: 'Submit Feedback',
                        isExpanded: true,
                        isLoading: _isSubmitting,
                        gradientColors: const [
                          Color(0xFFFF566B),
                          Color(0xFFF48DBA),
                        ],
                        onPressed: _submitFeedback,
                      ),
                    ),
                  ),

                  AppSpacing.gapLG,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _feedbackTypes.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFFFD8E5),
                        Color(0xFFFFEED8),
                      ],
                    )
                  : null,
              color: isSelected ? null : const Color(0xFFF8E7EF),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFE3AF)
                    : Colors.transparent,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD28E).withOpacity(0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              type,
              style: AppTextStyles.captionMediumStyle.copyWith(
                color: isSelected ? _berryPrimary : _berrySecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: _cardBg.withOpacity(0.82),
        borderRadius: AppBorderRadius.borderRadiusLG,
        border: Border.all(
          color: Colors.white.withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _submitFeedback() async {
    if (_contentController.text.trim().isEmpty) {
      AppOverlay.showToast(
        context,
        message: 'Please enter your feedback',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isSubmitting = false);

      // Clear form
      _contentController.clear();
      _contactController.clear();
      _voiceText = '';

      AppOverlay.showToast(
        context,
        message: 'Thank you for your feedback!',
        type: ToastType.success,
      );

      // Go back
      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      AppOverlay.showToast(
        context,
        message: 'Submission failed, please try again',
        type: ToastType.error,
      );
    }
  }
}
