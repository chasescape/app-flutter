import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:permission_handler/permission_handler.dart';
import 'package:riko/riko/app/widgets/diffuse_background.dart';
import 'package:speech_to_text/speech_to_text.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      _showBottomToast(
        context,
        'Please enter your feedback',
        icon: Icons.info_outline,
      );
      return;
    }

    _showBottomToast(
      context,
      'Feedback submitted successfully!',
      icon: Icons.check_circle_outline,
    );

    _feedbackController.clear();
  }

  void _showBottomToast(BuildContext context, String message, {required IconData icon}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _BottomToast(message: message, icon: icon),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 2500), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: DiffuseBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeaderCard(),
                const SizedBox(height: 18),
                _FeedbackForm(controller: _feedbackController),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE7FA0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Submit Feedback',
                      style: TextStyle(fontSize: 15),
                    ),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFF4D9E3),
            child: Icon(Icons.favorite, color: Color(0xFFEE7FA0)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help us improve Riko',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tell us what you want next or what feels off.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackForm extends StatefulWidget {
  final TextEditingController controller;

  const _FeedbackForm({required this.controller});

  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  final Set<String> _selected = <String>{};
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
  }

  Future<bool> _ensureSpeechPermissions() async {
    final mic = await Permission.microphone.request();
    final speech = await Permission.speech.request();
    return mic.isGranted && speech.isGranted;
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    final hasPermission = await _ensureSpeechPermissions();
    if (!hasPermission) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable microphone and speech permissions.'),
        ),
      );
      return;
    }

    final available = await _speechToText.initialize();
    if (!available) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is not available.')),
      );
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        if (!mounted) {
          return;
        }
        setState(() {
          widget.controller.text = result.recognizedWords;
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
        });
      },
    );

    if (mounted) {
      setState(() => _isListening = true);
    }
  }

  void _toggle(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What would you like to improve?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2B2B2B),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: 'Suggestions quality',
                selected: _selected.contains('Suggestions quality'),
                onTap: () => _toggle('Suggestions quality'),
              ),
              _Chip(
                label: 'Style accuracy',
                selected: _selected.contains('Style accuracy'),
                onTap: () => _toggle('Style accuracy'),
              ),
              _Chip(
                label: 'Speed & stability',
                selected: _selected.contains('Speed & stability'),
                onTap: () => _toggle('Speed & stability'),
              ),
              _Chip(
                label: 'Upload experience',
                selected: _selected.contains('Upload experience'),
                onTap: () => _toggle('Upload experience'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              TextField(
                controller: widget.controller,
                maxLines: 6,
                cursorColor: const Color(0xFFEE7FA0),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Tell us what feels off or what you want improved...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFA6A6A6),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F1F5),
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 44, 24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: InkWell(
                  onTap: _toggleListening,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color:
                          _isListening ? const Color(0xFFEE7FA0) : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 18,
                      color:
                          _isListening ? Colors.white : const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isListening)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Listening… tap the mic to stop',
                style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
              ),
            ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 14, color: Color(0xFF9E9E9E)),
              SizedBox(width: 6),
              Text(
                'Your feedback is private and anonymized.',
                style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEE7FA0) : const Color(0xFFF9EEF2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : const Color(0xFF6E6E6E),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BottomToast extends StatefulWidget {
  final String message;
  final IconData icon;

  const _BottomToast({
    required this.message,
    required this.icon,
  });

  @override
  State<_BottomToast> createState() => _BottomToastState();
}

class _BottomToastState extends State<_BottomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2100), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: const Color(0xFF6D7485),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Color(0xFF2B2B2B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
