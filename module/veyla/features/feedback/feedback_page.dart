import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/pastel_ui.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = <XFile>[];

  SpeechToText? _speechToText;
  bool _isListening = false;
  bool _isInitializing = false;
  bool _isSubmitting = false;
  bool _isPickingImages = false;

  static const int _maxImages = 9;

  @override
  void dispose() {
    _controller.dispose();
    _stopListening();
    _speechToText?.cancel();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final hasText = _controller.text.trim().isNotEmpty;
    final hasImages = _selectedImages.isNotEmpty;

    if (!hasText && !hasImages) {
      // Intentionally keep empty-submit errors silent on this page.
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _selectedImages.clear();
    });
    _controller.clear();

    Get.snackbar(
      'Thank you',
      'Your feedback has been submitted successfully.',
      backgroundColor: AppColors.success,
      colorText: AppColors.textInverse,
      snackPosition: SnackPosition.BOTTOM,
    );

    await Future.delayed(const Duration(seconds: 1));
    Get.back();
  }

  Future<void> _initializeSpeechToText() async {
    if (_speechToText != null) return;

    _speechToText = SpeechToText();
    final hasSpeech = await _speechToText!.initialize(
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _isInitializing = false;
        });
        _showVoicePermissionError();
      },
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'listening' || status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = status == 'listening';
            _isInitializing = false;
          });
        }
      },
    );

    if (!hasSpeech && mounted) {
      setState(() => _isInitializing = false);
      _showVoicePermissionError();
    }
  }

  void _showVoicePermissionError() {
    // Intentionally keep permission errors silent on this page.
  }

  void _showImagePermissionError() {
    // Intentionally keep image permission errors silent on this page.
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _stopListening();
      return;
    }
    if (_isInitializing) return;

    setState(() => _isInitializing = true);

    if (_speechToText == null) {
      await _initializeSpeechToText();
      if (!mounted) return;
    }

    if (_speechToText == null) {
      setState(() => _isInitializing = false);
      return;
    }

    await _startListening();
  }

  Future<void> _startListening() async {
    final statuses = await [
      Permission.microphone,
      Permission.speech,
    ].request();

    final micStatus = statuses[Permission.microphone];
    final speechStatus = statuses[Permission.speech];

    if (!(micStatus?.isGranted ?? false) || !(speechStatus?.isGranted ?? false)) {
      if (!mounted) return;
      setState(() => _isInitializing = false);
      _showVoicePermissionError();
      return;
    }

    await _speechToText!.listen(
      onResult: (SpeechRecognitionResult result) {
        if (!mounted) return;
        setState(() {
          final currentText = _controller.text.trim();
          final recognizedText = result.recognizedWords.trim();
          _controller.text = currentText.isEmpty ? recognizedText : recognizedText;
          _controller.selection = TextSelection.collapsed(
            offset: _controller.text.length,
          );
          _isInitializing = false;
          _isListening = !result.finalResult;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );

    if (!mounted) return;
    setState(() {
      _isListening = true;
      _isInitializing = false;
    });
  }

  Future<void> _stopListening() async {
    await _speechToText?.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  Future<void> _pickImages() async {
    if (_isPickingImages) return;

    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) {
      // Intentionally keep image-limit warnings silent on this page.
      return;
    }

    final photosStatus = await Permission.photos.request();
    if (!photosStatus.isGranted && !photosStatus.isLimited) {
      _showImagePermissionError();
      return;
    }

    setState(() => _isPickingImages = true);

    try {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (!mounted) return;

      if (images.isNotEmpty) {
        final nextImages = <XFile>[
          ..._selectedImages,
          ...images.take(remaining),
        ];

        setState(() {
          _selectedImages
            ..clear()
            ..addAll(nextImages);
        });
      }
    } catch (_) {
      if (mounted) {
        _showImagePermissionError();
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  void _removeImage(XFile image) {
    setState(() => _selectedImages.remove(image));
  }

  @override
  Widget build(BuildContext context) {
    return PastelScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('Feedback'),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildComposerCard(),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textInverse,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textInverse,
                          ),
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposerCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Share your thoughts', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Write a note, attach screenshots, and show us what happened.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 7,
                  minLines: 5,
                  cursorColor: AppColors.accentDark,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: _isListening
                        ? 'Listening...'
                        : _isInitializing
                            ? 'Preparing microphone...'
                            : 'Tell us what happened...',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildImageGrid(),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _buildFooterAction(
                      icon: _isListening ? Icons.stop_circle_rounded : Icons.mic_none_rounded,
                      label: _isListening ? 'Stop' : 'Voice',
                      onTap: _isInitializing ? null : _toggleVoiceInput,
                      isLoading: _isInitializing,
                      accentColor: _isListening ? AppColors.error : AppColors.accentDark,
                    ),
                    const SizedBox(width: 10),
                    _buildFooterAction(
                      icon: Icons.add_photo_alternate_outlined,
                      label: _selectedImages.isEmpty
                          ? 'Add photos'
                          : '${_selectedImages.length}/$_maxImages photos',
                      onTap: _isPickingImages ? null : _pickImages,
                      isLoading: _isPickingImages,
                      accentColor: const Color(0xFF6E6ACF),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    final tiles = <Widget>[
      ..._selectedImages.map(_buildImageTile),
      if (_selectedImages.length < _maxImages) _buildAddImageTile(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Images',
          style: AppTextStyles.small,
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) => tiles[index],
        ),
      ],
    );
  }

  Widget _buildImageTile(XFile file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(file.path),
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeImage(file),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageTile() {
    return GestureDetector(
      onTap: _isPickingImages ? null : _pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD9D1F0),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isPickingImages)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentDark),
                ),
              )
            else ...[
              const Icon(
                Icons.add_rounded,
                size: 28,
                color: AppColors.accentDark,
              ),
              const SizedBox(height: 6),
              Text(
                'Add',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.accentDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooterAction({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color accentColor,
    bool isLoading = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                )
              else
                Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
