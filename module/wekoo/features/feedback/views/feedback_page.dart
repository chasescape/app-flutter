import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../theme/app_theme.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final int _maxLength = 500;
  final int _maxBugImages = 9;

  SpeechToText? _speechToText;
  final List<File> _bugImages = <File>[];
  bool _isListening = false;
  bool _isInitializing = false;
  bool _isPickingImage = false;

  @override
  void dispose() {
    _speechToText?.stop();
    _speechToText?.cancel();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    if (_isInitializing) return;

    setState(() => _isInitializing = true);

    try {
      _speechToText ??= SpeechToText();

      final isAvailable = await _speechToText!.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _isInitializing = false;
          });
          Get.snackbar(
            'Error',
            'Speech recognition error: ${error.errorMsg}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.semanticError.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        },
      );

      if (!isAvailable) {
        setState(() => _isInitializing = false);
        Get.snackbar(
          'Error',
          'Speech recognition is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.semanticError.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        setState(() => _isInitializing = false);
        Get.snackbar(
          'Permission Required',
          'Microphone permission is required for voice input. Please enable it in settings.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.semanticError.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      await _startListening();
    } catch (e) {
      setState(() => _isInitializing = false);
      Get.snackbar(
        'Error',
        'Failed to initialize speech recognition',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.semanticError.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _startListening() async {
    await _speechToText!.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _feedbackController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
    if (!mounted) return;
    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    await _speechToText?.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  Future<void> _pickBugImage() async {
    if (_isPickingImage) return;
    if (_bugImages.length >= _maxBugImages) return;

    setState(() => _isPickingImage = true);

    try {
      final PermissionStatus photoStatus = await Permission.photos.request();
      final bool hasPermission =
          photoStatus.isGranted || photoStatus.isLimited;

      if (!hasPermission) {
        if (mounted) {
          Get.snackbar(
            'Permission Required',
            'Please allow photo library access to upload bug screenshots.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.semanticError.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        }
        return;
      }

      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 88,
      );

      if (pickedFiles.isEmpty) return;
      if (!mounted) return;

      final remainingCount = _maxBugImages - _bugImages.length;
      final filesToAdd = pickedFiles
          .take(remainingCount)
          .map((file) => File(file.path))
          .toList();

      setState(() {
        _bugImages.addAll(filesToAdd);
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.semanticError.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      Get.snackbar(
        'Notice',
        'Please enter your feedback',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.deepOcean.withValues(alpha: 0.92),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 18,
      );
      return;
    }

    Get.defaultDialog(
      title: 'Submitting...',
      content: const CircularProgressIndicator(),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!Get.isDialogOpen!) return;
      Get.back();
      Get.back();
      Get.snackbar(
        'Thank You',
        'Your feedback has been submitted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.semanticSuccess.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 18,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.appBackgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Feedback'),
              backgroundColor: Colors.transparent,
            ),
            body: Stack(
              children: [
                const Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _FeedbackWaveBackground(),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 18),
                            _buildInputPanel(),
                            const SizedBox(height: 18),
                            _buildBugImagePanel(),
                            const SizedBox(height: 18),
                            _buildActionRow(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 28,
                      width: double.infinity,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.secondaryLight),
        boxShadow: AppTheme.shadows,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We value your feedback',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please share your thoughts to help us improve the hydration experience.',
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.secondaryDark),
        boxShadow: AppTheme.shadows,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppTheme.primaryMain,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Your message',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.secondaryLight.withValues(alpha: 0.9),
                  ),
                ),
                child: TextField(
                  controller: _feedbackController,
                  maxLines: 10,
                  maxLength: _maxLength,
                  cursorColor: AppTheme.primaryMain,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Enter your feedback here...',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(18, 18, 18, 56),
                    counterText: '',
                  ),
                ),
              ),
              Positioned(
                right: 14,
                bottom: 14,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isInitializing ? null : _toggleVoiceInput,
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? AppTheme.semanticError
                            : AppTheme.primaryMain,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadows,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isListening ? 'Listening...' : '',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryMain,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                '${_feedbackController.text.length}/$_maxLength',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryMain,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text('Submit'),
      ),
    );
  }

  Widget _buildBugImagePanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.secondaryDark),
        boxShadow: AppTheme.shadows,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bug_report_outlined,
                color: AppTheme.primaryMain,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Bug screenshot',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload a screenshot to help us understand the issue faster.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.secondaryLight.withValues(alpha: 0.92),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: _bugImages.length < _maxBugImages
                      ? _bugImages.length + 1
                      : _bugImages.length,
                  itemBuilder: (context, index) {
                    if (index == _bugImages.length && _bugImages.length < _maxBugImages) {
                      return _buildAddImageTile();
                    }

                    return _buildImageTile(_bugImages[index], index);
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  '${_bugImages.length}/$_maxBugImages images',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageTile() {
    return GestureDetector(
      onTap: _isPickingImage ? null : _pickBugImage,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryMain.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primaryMain.withValues(alpha: 0.24),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: _isPickingImage
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppTheme.primaryMain,
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: AppTheme.primaryMain,
                      size: 28,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryMain,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageTile(File imageFile, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _bugImages.removeAt(index);
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xCC1B1012),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackWaveBackground extends StatefulWidget {
  const _FeedbackWaveBackground();

  @override
  State<_FeedbackWaveBackground> createState() => _FeedbackWaveBackgroundState();
}

class _FeedbackWaveBackgroundState extends State<_FeedbackWaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 340,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: const Size(double.infinity, 340),
                painter: _WavePainter(
                  color: AppTheme.waveBlue.withValues(alpha: 0.32),
                  progress: _controller.value,
                  heightFactor: 0.46,
                  amplitude: 20,
                  wavelength: 180,
                ),
              ),
              CustomPaint(
                size: const Size(double.infinity, 320),
                painter: _WavePainter(
                  color: AppTheme.waveMint.withValues(alpha: 0.28),
                  progress: (_controller.value + 0.18) % 1,
                  heightFactor: 0.54,
                  amplitude: 16,
                  wavelength: 150,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.color,
    required this.progress,
    required this.heightFactor,
    required this.amplitude,
    required this.wavelength,
  });

  final Color color;
  final double progress;
  final double heightFactor;
  final double amplitude;
  final double wavelength;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path();
    final double baseHeight = size.height * heightFactor;
    final double shift = progress * wavelength * 2;

    path.moveTo(0, size.height);
    path.lineTo(0, baseHeight);

    for (double x = 0; x <= size.width; x++) {
      final double y = baseHeight +
          math.sin(((x + shift) / wavelength) * 2 * math.pi) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.heightFactor != heightFactor ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.wavelength != wavelength;
  }
}
