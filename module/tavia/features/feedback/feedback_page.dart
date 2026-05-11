import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/dialog_widget.dart';
import '../../core/widgets/tavia_ui.dart';
import '../../shared/constants/app_constants.dart';

/// Feedback page with speech-to-text support.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const List<String> _feedbackTypes = <String>[
    'Bug',
    'Praise',
    'UI',
    'Idea',
  ];

  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  bool _isListening = false;
  bool _speechEnabled = false;
  String? _selectedType;

  bool get _canSubmit => _textController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    bool available = false;
    try {
      available = await _speechToText.initialize(
        onError: _handleSpeechError,
        onStatus: _handleSpeechStatus,
      );
    } catch (_) {
      available = false;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _speechEnabled = available;
    });
  }

  Future<void> _toggleVoiceInput() async {
    FocusScope.of(context).unfocus();

    if (_isListening) {
      await _speechToText.stop();
      if (!mounted) {
        return;
      }
      setState(() {
        _isListening = false;
      });
      return;
    }

    final microphoneStatus = await Permission.microphone.request();
    if (!microphoneStatus.isGranted) {
      if (!mounted) {
        return;
      }
      AppDialog.showToast(
        context,
        message: 'Microphone permission is required for voice input.',
        icon: Icons.mic_off_outlined,
      );
      return;
    }

    final speechStatus = await Permission.speech.request();
    if (!speechStatus.isGranted) {
      if (!mounted) {
        return;
      }
      AppDialog.showToast(
        context,
        message: 'Speech recognition permission is required.',
        icon: Icons.mic_off_outlined,
      );
      return;
    }

    if (!_speechEnabled) {
      await _initSpeech();
    }

    if (!_speechEnabled) {
      if (!mounted) {
        return;
      }
      AppDialog.showToast(
        context,
        message: 'Speech recognition is not available on this device.',
        icon: Icons.mic_off_outlined,
      );
      return;
    }

    setState(() {
      _isListening = true;
    });

    try {
      await _speechToText.listen(
        onResult: _handleSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isListening = false;
      });
      AppDialog.showToast(
        context,
        message: 'Could not start voice input.',
        icon: Icons.mic_off_outlined,
      );
    }
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) {
      return;
    }

    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = false;
    });

    AppDialog.showToast(
      context,
      message: 'Speech recognition error: ${error.errorMsg}',
      icon: Icons.mic_off_outlined,
    );
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) {
      return;
    }

    final words = result.recognizedWords.trim();
    if (words.isEmpty) {
      return;
    }

    setState(() {
      _textController.value = TextEditingValue(
        text: words,
        selection: TextSelection.collapsed(offset: words.length),
      );
    });
  }

  void _selectFeedbackType(String type) {
    setState(() {
      _selectedType = _selectedType == type ? null : type;
    });
  }

  Future<void> _submitFeedback() async {
    FocusScope.of(context).unfocus();

    if (!_canSubmit) {
      AppDialog.showErrorDialog(
        context,
        title: 'Empty Feedback',
        message: 'Please write something before sending feedback.',
      );
      return;
    }

    AppDialog.showLoadingDialog(
      context,
      message: 'Sending feedback...',
    );

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      AppDialog.hideLoadingDialog();
      return;
    }

    AppDialog.hideLoadingDialog();
    AppDialog.showToast(
      context,
      message: _selectedType == null
          ? 'Thanks for the feedback'
          : 'Thanks for the $_selectedType feedback',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = AppConstants.spacingXxl +
        mediaQuery.padding.bottom +
        mediaQuery.viewInsets.bottom;

    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minHeight = constraints.maxHeight -
                  AppConstants.spacingMd -
                  bottomPadding;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppConstants.spacingLg,
                  AppConstants.spacingMd,
                  AppConstants.spacingLg,
                  bottomPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: minHeight > 0 ? minHeight : 0,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppConstants.spacingXl),
                        _buildFeedbackTypesCard(),
                        const SizedBox(height: AppConstants.spacingLg),
                        _buildComposerCard(),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TaviaIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Text(
          'Feedback',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildComposerCard() {
    return SizedBox(
      width: double.infinity,
      child: TaviaPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What should feel better?',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              'A short note is enough.',
              style: AppTextStyles.captionMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: _textController,
              minLines: 6,
              maxLines: 6,
              maxLength: 500,
              cursorColor: AppColors.primaryMain,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _selectedType == null
                    ? 'Share your feedback here...'
                    : 'Share your $_selectedType feedback...',
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Row(
              children: [
                Material(
                  color: _isListening
                      ? AppColors.primaryMain.withValues(alpha: 0.14)
                      : AppColors.surfaceStrong.withValues(alpha: 0.78),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _toggleVoiceInput,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(
                        _isListening
                            ? Icons.stop_circle_outlined
                            : Icons.mic_none_rounded,
                        size: 22,
                        color: _isListening
                            ? AppColors.primaryMain
                            : (_speechEnabled
                                ? AppColors.textPrimary
                                : AppColors.textDisabled),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: TaviaPrimaryButton(
                    label: 'Send',
                    onPressed: _canSubmit ? _submitFeedback : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTypesCard() {
    return SizedBox(
      width: double.infinity,
      child: TaviaPanel(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Wrap(
          spacing: AppConstants.spacingSm,
          runSpacing: AppConstants.spacingSm,
          children: _feedbackTypes.map((type) {
            return _SuggestionChip(
              label: type,
              selected: _selectedType == type,
              onTap: () => _selectFeedbackType(type),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SuggestionChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryMain.withValues(alpha: 0.12)
          : AppColors.surfaceStrong.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: 10,
          ),
          child: Text(
            label,
            style: AppTextStyles.captionMedium.copyWith(
              color: selected ? AppColors.primaryMain : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
