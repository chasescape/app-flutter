import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/widgets/glass_card.dart';
import '../../app/widgets/bounce_in_animation.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _isSubmitting = false;
  bool _speechAvailable = false;
  static const _cardRadius = AppSpacing.borderRadiusXl;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechAvailable = await _speechToText.initialize();
    if (mounted) setState(() {});
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      _showToast('Speech recognition is not available on this device');
      return;
    }

    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _showToast('Microphone permission is required for voice input');
        return;
      }

      await _speechToText.listen(
        onResult: (result) {
          if (!mounted) return;
          final text = result.recognizedWords;
          _controller.value = _controller.value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
            composing: TextRange.empty,
          );
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
        ),
      );
      setState(() => _isListening = true);
    }
  }

  void _submitFeedback() async {
    if (_controller.text.trim().isEmpty) {
      _showToast('Please enter your feedback');
      return;
    }

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showToast('Thank you for your feedback!');
      Navigator.of(context).pop();
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondaryMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: SizedBox.expand(),
        ),
        Positioned(
          left: -120,
          top: 40,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryMain.withValues(alpha: 0.22),
            ),
          ),
        ),
        Positioned(
          right: -140,
          bottom: 80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentMain.withValues(alpha: 0.18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BounceInAnimation(
          delay: const Duration(milliseconds: 80),
          child: Text(
            'We Value Your Feedback',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        BounceInAnimation(
          delay: const Duration(milliseconds: 130),
          child: Text(
            'Tell us what went wrong, what you love, or what we should improve.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.72),
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          height: 1.35,
        );

    final hintStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary.withValues(alpha: 0.5),
          height: 1.35,
        );

    return GlassCard(
      borderRadius: _cardRadius,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.md),
      bgColor: Colors.white.withValues(alpha: 0.10),
      borderColor: Colors.white.withValues(alpha: 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Your message',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              if (_speechAvailable)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 0.5),
                  ),
                  child: Text(
                    _isListening ? 'Listening' : 'Voice',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _isListening
                              ? AppColors.accentMain
                              : AppColors.textPrimary.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            minLines: 6,
            maxLines: 12,
            cursorColor: AppColors.accentMain,
            textInputAction: TextInputAction.done,
            style: textStyle,
            decoration: InputDecoration(
              hintText: 'Share your thoughts, suggestions, or report issues…',
              hintStyle: hintStyle,
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.14), width: 0.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.14), width: 0.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                borderSide: BorderSide(
                    color: AppColors.accentMain.withValues(alpha: 0.85),
                    width: 1.2),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  _speechAvailable
                      ? (_isListening
                          ? 'Speak now. We’ll transcribe in real time.'
                          : 'You can also use voice input.')
                      : 'Voice input is not available on this device.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.65),
                        height: 1.3,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                height: 40,
                child: FilledButton.tonalIcon(
                  onPressed: (_speechAvailable && !_isSubmitting)
                      ? _toggleListening
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 0.5),
                    ),
                  ),
                  icon:
                      Icon(_isListening ? Icons.mic : Icons.mic_none, size: 18),
                  label: Text(
                    _isListening ? 'Stop' : 'Speak',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 12, AppSpacing.lg, AppSpacing.lg),
        child: SizedBox(
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryMain.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSubmitting ? null : _submitFeedback,
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusXl),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit Feedback',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _TransparentTopBar(title: 'Feedback'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      140,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: AppSpacing.lg),
                            BounceInAnimation(
                              delay: const Duration(milliseconds: 180),
                              child: _buildInputCard(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSubmitBar(context),
          ),
        ],
      ),
    );
  }
}

class _TransparentTopBar extends StatelessWidget {
  final String title;

  const _TransparentTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
