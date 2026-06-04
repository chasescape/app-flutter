import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'favio_palette.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<_FeedbackImageAttachment> _selectedImages =
      <_FeedbackImageAttachment>[];

  SpeechToText? _speechToText;
  String _voiceSeedText = '';

  bool _isSubmitting = false;
  bool _isListening = false;
  bool _isInitializingSpeech = false;

  bool get _canSubmit =>
      !_isSubmitting &&
      (_controller.text.trim().isNotEmpty || _selectedImages.isNotEmpty);

  @override
  void dispose() {
    _speechToText?.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isSubmitting) {
      return;
    }

    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 90,
        maxWidth: 1800,
      );

      if (pickedImages.isEmpty) {
        return;
      }

      final List<_FeedbackImageAttachment> nextImages =
          <_FeedbackImageAttachment>[];
      for (final XFile pickedImage in pickedImages) {
        final Uint8List bytes = await pickedImage.readAsBytes();
        nextImages.add(
          _FeedbackImageAttachment(
            bytes: bytes,
            name: _extractFileName(pickedImage.path),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImages
          ..clear()
          ..addAll(nextImages);
      });

      _showMessage(
        nextImages.length == 1
            ? '1 image attached.'
            : '${nextImages.length} images attached.',
      );
    } catch (_) {
      _showMessage('Unable to open the photo library right now.');
    }
  }

  Future<void> _toggleVoiceInput() async {
    if (_isSubmitting || _isInitializingSpeech) {
      return;
    }

    if (_isListening) {
      await _stopListening();
      return;
    }

    final bool ready = await _prepareSpeech();
    if (!ready || _speechToText == null) {
      return;
    }

    _voiceSeedText = _controller.text.trim();
    await _speechToText!.listen(
      onResult: _handleSpeechResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = true;
    });
  }

  Future<bool> _prepareSpeech() async {
    if (_speechToText != null) {
      return true;
    }

    setState(() {
      _isInitializingSpeech = true;
    });

    try {
      final PermissionStatus microphoneStatus =
          await Permission.microphone.request();
      PermissionStatus speechStatus = PermissionStatus.granted;

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        speechStatus = await Permission.speech.request();
      }

      if (!microphoneStatus.isGranted || !speechStatus.isGranted) {
        _showPermissionMessage(
          microphoneStatus.isPermanentlyDenied ||
              speechStatus.isPermanentlyDenied,
        );
        return false;
      }

      final SpeechToText speechToText = SpeechToText();
      final bool initialized = await speechToText.initialize(
        onStatus: _handleSpeechStatus,
        onError: _handleSpeechError,
      );

      if (!initialized) {
        _showMessage('Voice input is unavailable on this device right now.');
        return false;
      }

      _speechToText = speechToText;
      return true;
    } finally {
      if (mounted) {
        setState(() {
          _isInitializingSpeech = false;
        });
      }
    }
  }

  Future<void> _stopListening() async {
    await _speechToText?.stop();
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = false;
    });
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = status == 'listening';
    });
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = false;
    });

    _showMessage(
      error.errorMsg.isEmpty
          ? 'Voice input stopped. Please try again.'
          : 'Voice input stopped. Please try again.',
    );
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    final String transcript = result.recognizedWords.trim();
    final String nextText;

    if (_voiceSeedText.isEmpty) {
      nextText = transcript;
    } else if (transcript.isEmpty) {
      nextText = _voiceSeedText;
    } else {
      nextText = '$_voiceSeedText\n$transcript';
    }

    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      return;
    }

    if (_isListening) {
      await _stopListening();
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback sent. Thank you.'),
      ),
    );
    Navigator.of(context).pop();
  }

  void _removeImageAt(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showPermissionMessage(bool permanentlyDenied) {
    _showMessage(
      permanentlyDenied
          ? 'Microphone or speech access is turned off. Enable it in Settings.'
          : 'Microphone and speech access are required for voice input.',
      action: permanentlyDenied
          ? const SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            )
          : null,
    );
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    if (!mounted) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
        ),
      );
  }

  String _extractFileName(String path) {
    final List<String> parts = path.split(RegExp(r'[\\/]'));
    return parts.isEmpty ? 'attachment.jpg' : parts.last;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAccent = FavioPalette.brandGlow;
    final Color supportAccent = const Color(0xFFB689FF);

    return Scaffold(
      backgroundColor: FavioPalette.backgroundAlt,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              FavioPalette.backgroundTop,
              FavioPalette.backgroundMid,
              FavioPalette.backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              const Positioned.fill(
                child: _FeedbackPersonaBackdrop(),
              ),
              SafeArea(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              backgroundColor: const Color(0xFF121520),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'FEEDBACK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          _FeedbackStatusPill(
                            label: _isListening
                                ? 'Live'
                                : _selectedImages.isNotEmpty
                                    ? 'Ready'
                                    : 'Note',
                            active: _isListening,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 150),
                        children: <Widget>[
                          const _FeedbackHeroCard(),
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _FeedbackActionCard(
                                  icon: Icons.image_outlined,
                                  title: 'Images',
                                  subtitle: _selectedImages.isEmpty
                                      ? 'Upload'
                                      : '${_selectedImages.length} attached',
                                  accent: supportAccent,
                                  onTap: _pickImage,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FeedbackActionCard(
                                  icon: _isListening
                                      ? Icons.stop_circle_outlined
                                      : Icons.keyboard_voice_outlined,
                                  title: _isListening ? 'Stop' : 'Voice',
                                  subtitle: _isInitializingSpeech
                                      ? 'Starting...'
                                      : _isListening
                                          ? 'Listening'
                                          : 'Tap to speak',
                                  accent: primaryAccent,
                                  active: _isListening,
                                  onTap: _toggleVoiceInput,
                                ),
                              ),
                            ],
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: _selectedImages.isEmpty
                                ? const SizedBox.shrink()
                                : Padding(
                                    key: ValueKey<int>(_selectedImages.length),
                                    padding: const EdgeInsets.only(top: 14),
                                    child: _FeedbackAttachmentCard(
                                      images: _selectedImages,
                                      onRemove: _removeImageAt,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F121A),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: FavioPalette.brandShadow.withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Quick note',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Short bug note or idea.',
                                  style: TextStyle(
                                    color: Color(0xFFD3D7E3),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 180,
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    14,
                                    14,
                                    14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A0D14),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _controller,
                                    maxLines: 8,
                                    minLines: 6,
                                    cursorColor: FavioPalette.brandGlow,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.multiline,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText:
                                          'What happened? What should change?',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF8B90A3),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AnimatedBuilder(
                                  animation: _controller,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            _selectedImages.isEmpty
                                                ? 'Images are optional.'
                                                : '${_selectedImages.length} image${_selectedImages.length == 1 ? '' : 's'} ready.',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.70,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${_controller.text.trim().length} chars',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.55,
                                            ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (BuildContext context, Widget? child) {
                              return _FeedbackSubmitButton(
                                enabled: _canSubmit,
                                busy: _isSubmitting,
                                onTap: _submit,
                              );
                            },
                          ),
                        ],
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

class _FeedbackHeroCard extends StatelessWidget {
  const _FeedbackHeroCard();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _FeedbackSlashClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 22, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              FavioPalette.brandBright,
              FavioPalette.brand,
              FavioPalette.brandDark,
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: FavioPalette.brandGlow.withValues(alpha: 0.22),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(
              child: _FeedbackHeroPattern(),
            ),
            Positioned(
              top: 2,
              right: 0,
              child: Transform.rotate(
                angle: -0.14,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'QUICK REPORT',
                  style: TextStyle(
                    color: Color(0xFFF4DFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tell us fast.\nWe will review it.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 0.98,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Add a note, screenshot, or voice.',
                  style: TextStyle(
                    color: Color(0xFFF1DFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackActionCard extends StatelessWidget {
  const _FeedbackActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _FeedbackSlashClipper(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            height: 86,
            padding: const EdgeInsets.fromLTRB(16, 14, 20, 14),
            decoration: BoxDecoration(
              color: active
                  ? accent.withValues(alpha: 0.18)
                  : const Color(0xFF11151D),
              border: Border.all(
                color: active
                    ? accent.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.10),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: active ? 0.22 : 0.10),
                  blurRadius: active ? 18 : 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.48),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 11,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackAttachmentCard extends StatelessWidget {
  const _FeedbackAttachmentCard({
    required this.images,
    required this.onRemove,
  });

  final List<_FeedbackImageAttachment> images;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _FeedbackSlashClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF11151D),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: images.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.02,
          ),
          itemBuilder: (BuildContext context, int index) {
            final _FeedbackImageAttachment image = images[index];
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      image.bytes,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () => onRemove(index),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(38, 38),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.black.withValues(alpha: 0.54),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FeedbackImageAttachment {
  const _FeedbackImageAttachment({
    required this.bytes,
    required this.name,
  });

  final Uint8List bytes;
  final String name;
}

class _FeedbackStatusPill extends StatelessWidget {
  const _FeedbackStatusPill({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFF405A).withValues(alpha: 0.18)
            : const Color(0xFF11151D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? const Color(0xFFFF405A).withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFF405A) : const Color(0xFFB8BECF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSubmitButton extends StatelessWidget {
  const _FeedbackSubmitButton({
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double opacity = enabled ? 1 : 0.44;

    return Opacity(
      opacity: opacity,
      child: ClipPath(
        clipper: _FeedbackSlashClipper(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    FavioPalette.brandBright,
                    FavioPalette.brand,
                    FavioPalette.brandGlow,
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: FavioPalette.brandGlow.withValues(alpha: 0.26),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (busy) ...<Widget>[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    busy ? 'Dispatching...' : 'Send Report',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
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

class _FeedbackPersonaBackdrop extends StatelessWidget {
  const _FeedbackPersonaBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _FeedbackBackdropPainter(),
            ),
          ),
          Positioned(
            top: 86,
            right: -34,
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  color: FavioPalette.brandGlow.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 120,
            child: Transform.rotate(
              angle: -0.22,
              child: Container(
                width: 168,
                height: 18,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackHeroPattern extends StatelessWidget {
  const _FeedbackHeroPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FeedbackHeroPainter(),
    );
  }
}

class _FeedbackSlashClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.08, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.92, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _FeedbackBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint redShape = Paint()..color = FavioPalette.brandShadow;
    final Paint darkShape = Paint()..color = const Color(0xFF101319);
    final Paint whiteLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.2;
    final Paint glowShape = Paint()
      ..color = FavioPalette.brandGlow.withValues(alpha: 0.13);

    final Path leftSlash = Path()
      ..moveTo(0, size.height * 0.12)
      ..lineTo(size.width * 0.27, 0)
      ..lineTo(size.width * 0.14, size.height * 0.42)
      ..lineTo(0, size.height * 0.36)
      ..close();
    canvas.drawPath(leftSlash, redShape);

    final Path rightPanel = Path()
      ..moveTo(size.width * 0.72, size.height * 0.06)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.26)
      ..lineTo(size.width * 0.80, size.height * 0.32)
      ..close();
    canvas.drawPath(rightPanel, darkShape);

    final Path bottomSlash = Path()
      ..moveTo(size.width * 0.64, size.height)
      ..lineTo(size.width, size.height * 0.82)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(bottomSlash, glowShape);

    for (double i = -size.height; i < size.width; i += 26) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        whiteLine,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeedbackHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint stripe = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.2;
    final Paint darkBlock = Paint()
      ..color = Colors.black.withValues(alpha: 0.22);

    for (double y = 8; y < size.height + 30; y += 22) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * 0.74, y - 14),
        stripe,
      );
    }

    final Path shadowPanel = Path()
      ..moveTo(size.width * 0.52, size.height * 0.58)
      ..lineTo(size.width, size.height * 0.44)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.32, size.height)
      ..close();
    canvas.drawPath(shadowPanel, darkBlock);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
