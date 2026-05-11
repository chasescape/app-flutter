import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riko/riko/app/routes/app_routes.dart';
import 'package:riko/riko/app/services/ai_stylist_service.dart';
import 'package:riko/riko/app/services/advice_store.dart';
import 'package:riko/riko/app/services/coin_store.dart';
import 'package:riko/riko/app/widgets/diffuse_background.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final AiStylistService _aiService = AiStylistService();
  final ImagePicker _imagePicker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final List<_Message> _messages = [
    _Message(
      text: 'Send me an outfit photo and I will style it for you.',
      isMe: false,
    ),
    _Message(
      text: 'Try: What shoes for this? What to wear on a date?',
      isMe: false,
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _handleSend(text: text);
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients == false) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo permission is required.')),
      );
      return;
    }
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await File(file.path).readAsBytes();
    final base64Image = base64Encode(bytes);
    await _handleSend(
      text: _controller.text.trim().isEmpty
          ? 'Please analyze this outfit and suggest matching shoes and accessories.'
          : _controller.text.trim(),
      imageBase64: base64Image,
      imagePath: file.path,
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final mic = await Permission.microphone.request();
    final speech = await Permission.speech.request();
    if (!mic.isGranted || !speech.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is unavailable.')),
      );
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      },
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _handleSend({
    required String text,
    String? imageBase64,
    String? imagePath,
  }) async {
    if (_isSending) return;
    final cost = imagePath != null ? 50 : 10;
    final balance = CoinStore.balance.value;
    if (balance < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough coins. Need $cost coins.')),
      );
      return;
    }
    CoinStore.setBalance(balance - cost);
    setState(() {
      _isSending = true;
      _messages.add(_Message(text: text, isMe: true, imagePath: imagePath));
      _messages.add(const _Message(text: 'Thinking...', isMe: false));
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _aiService.chat(
        text: text,
        imageBase64: imageBase64,
      );
      setState(() {
        _messages.removeLast();
        _messages.add(
          _Message(text: response, isMe: false, imagePath: imagePath),
        );
      });
      AdviceStore.set(
        AdvicePayload(content: response, imagePath: imagePath),
      );
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(
          const _Message(
            text: 'Sorry, something went wrong. Please try again.',
            isMe: false,
          ),
        );
      });
    } finally {
      _isSending = false;
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DiffuseBackground(
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                _ChatHeader(onClear: _clearChat),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _ChatBubble(
                      message: _messages[index],
                    ),
                  ),
                ),
                _Composer(
                  controller: _controller,
                  onSend: _sendText,
                  onPickImage: _pickImage,
                  isSending: _isSending,
                  isListening: _isListening,
                  onToggleListening: _toggleListening,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final VoidCallback onClear;

  const _ChatHeader({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFF4D9E3),
            child: Icon(Icons.style, color: Color(0xFFEE7FA0)),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Riko - AI Style Buddy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B2B2B),
              ),
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFFB0B0B0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final bool isSending;
  final bool isListening;
  final VoidCallback onToggleListening;

  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    required this.isSending,
    required this.isListening,
    required this.onToggleListening,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _CostBadge(label: 'Text advice', coins: 10),
                SizedBox(width: 8),
                _CostBadge(label: 'Image advice', coins: 50),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: isSending ? null : onPickImage,
                icon: const Icon(Icons.photo_camera_outlined),
                color: const Color(0xFFEE7FA0),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF7F1F5),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      onPressed: isSending ? null : onToggleListening,
                      icon: Icon(isListening ? Icons.mic : Icons.mic_none),
                      color: isListening
                          ? const Color(0xFFEE7FA0)
                          : const Color(0xFFB0B0B0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isSending ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE7FA0),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Send', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostBadge extends StatelessWidget {
  final String label;
  final int coins;

  const _CostBadge({required this.label, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF3C6D6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on,
              size: 14, color: Color(0xFFEE7FA0)),
          const SizedBox(width: 4),
          Text(
            '$coins coins',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEE7FA0),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6E6E6E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _Message message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final bubbleColor =
        isMe ? const Color(0xFFEE7FA0) : Colors.white.withOpacity(0.92);
    final textColor = isMe ? Colors.white : const Color(0xFF2B2B2B);
    final shouldShowCard = !isMe && message.text.length > 160;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: shouldShowCard
          ? _AdviceCard(message: message)
          : Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 260),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  if (isMe == false)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.imagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Image.file(
                            File(message.imagePath!),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    message.text,
                    style:
                        TextStyle(color: textColor, height: 1.4, fontSize: 14),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final _Message message;

  const _AdviceCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final preview = _buildPreview(message.text);
    return InkWell(
      onTap: () => Get.toNamed(
        AppRoutes.details,
        arguments: {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': message.text,
          'imagePath': message.imagePath,
        },
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.style, size: 16, color: Color(0xFFEE7FA0)),
                SizedBox(width: 6),
                Text(
                  'Style Advice',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B0B0)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              preview,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6E6E6E),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildPreview(String text) {
    final trimmed = text.replaceAll('\n', ' ').trim();
    return trimmed.length > 180 ? trimmed.substring(0, 180) : trimmed;
  }
}

class _Message {
  final String text;
  final bool isMe;
  final String? imagePath;

  const _Message({
    required this.text,
    required this.isMe,
    this.imagePath,
  });
}
