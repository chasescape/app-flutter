import 'dart:io';

import 'package:flira/flira/app/modules/nav/flira_state.dart';
import 'package:flira/flira/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'chat_logic.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatLogic logic = Get.put(ChatLogic());
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final SpeechToText _speechToText = SpeechToText();

  bool _showTips = true;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (logic.isAiTyping.value) return;

    final bool hasInput = _inputController.text.trim().isNotEmpty || logic.uploadedPhoto.value != null;
    if (!hasInput) return;

    _inputController.clear();

    await logic.sendMessage();

    final String? generatedEntryId = logic.lastGeneratedEntryId.value;
    if (generatedEntryId != null) {
      logic.lastGeneratedEntryId.value = null;
      await Get.toNamed(AppRoutes.detail, arguments: generatedEntryId);

      // 从详情页返回后，重置为初始聊天态
      logic.restartSession();
      _inputController.clear();
      if (mounted) {
        setState(() {
          _isListening = false;
          _showTips = true;
        });
      }
      return;
    }

    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }


  Future<bool> _requestPhotoPermission() async {
    PermissionStatus status;

    if (Platform.isIOS) {
      status = await Permission.photos.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.camera.request();
      }
    } else {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      Get.snackbar(
        'Permission required',
        'Please enable photo permission in Settings.',
        mainButton: TextButton(
          onPressed: openAppSettings,
          child: const Text('Open Settings'),
        ),
      );
      return false;
    }

    Get.snackbar('Permission denied', 'Photo access was denied.');
    return false;
  }

  Future<bool> _requestMicPermission() async {
    final PermissionStatus status = await Permission.microphone.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      Get.snackbar(
        'Permission required',
        'Please enable microphone permission in Settings.',
        mainButton: TextButton(
          onPressed: openAppSettings,
          child: const Text('Open Settings'),
        ),
      );
      return false;
    }

    Get.snackbar('Permission denied', 'Microphone access was denied.');
    return false;
  }

  Future<void> _pickImage() async {
    final bool granted = await _requestPhotoPermission();
    if (!granted) return;

    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (picked == null) return;

    logic.setPhotoPath(picked.path);
  }

  Future<void> _toggleSpeech() async {
    if (_isListening) {
      await _speechToText.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final bool granted = await _requestMicPermission();
    if (!granted) return;

    final bool available = await _speechToText.initialize(
      onStatus: (String status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );

    if (!available) {
      Get.snackbar('Voice unavailable', 'Speech recognition is not available on this device.');
      return;
    }

    if (mounted) setState(() => _isListening = true);

    await _speechToText.listen(
      listenMode: ListenMode.confirmation,
      onResult: (result) {
        final String words = result.recognizedWords.trim();
        if (words.isEmpty) return;

        _inputController.text = words;
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _inputController.text.length),
        );
        logic.setInput(words);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          backgroundColor: const Color(0xFFF8ECF0),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                _TopBar(
                  coins: FliraState.coins.value,
                  onRestart: () {
                    logic.restartSession();
                    _inputController.clear();
                    if (mounted) {
                      setState(() {
                        _isListening = false;
                        _showTips = true;
                      });
                    }
                  },
                ),
                if (_showTips)
                  _TipsCard(
                    onClose: () => setState(() => _showTips = false),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    itemCount: logic.messages.length + (logic.isAiTyping.value ? 1 : 0),
                    itemBuilder: (_, int index) {
                      if (logic.isAiTyping.value && index == logic.messages.length) {
                        return const _TypingRow();
                      }

                      final ChatMessage msg = logic.messages[index];
                      final bool isUser = msg.role == 'user';
                      return _MessageBubble(message: msg, isUser: isUser);
                    },
                  ),
                ),
                _Composer(
                  controller: _inputController,
                  photoUrl: logic.uploadedPhoto.value,
                  isListening: _isListening,
                  isSendLocked: logic.isAiTyping.value,
                  onChange: logic.setInput,
                  onPickPhoto: _pickImage,
                  onToggleMic: _toggleSpeech,
                  onRemovePhoto: logic.removePhoto,
                  onSend: _send,
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.coins, required this.onRestart});

  final int coins;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Chat with Flira',
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xFFFF8FA3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'AI Diary Assistant',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9C8D97)),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'restart') {
                onRestart();
              }
            },
            itemBuilder: (_) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'restart',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF6A5D64)),
                    SizedBox(width: 8),
                    Text('Restart session'),
                  ],
                ),
              ),
            ],
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFFF9C769), Color(0xFFF4B84F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x33F4B84F),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$coins',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF9C8D97)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.progress, required this.value});

  final int progress;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Share 3 moments to create your diary',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7E7078)),
                ),
              ),
              Text(
                '$progress/3',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFE97495),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8E3E6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF596AD)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7FA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF9DCE5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF59AAE),
              ),
              child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'How it works',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF3E3137),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '✨  Share 3 life moments through chat, photos, or voice',
                    style: TextStyle(fontSize: 14, color: Color(0xFF5B4D54), height: 1.45),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '📖  AI will create a beautiful diary entry for you',
                    style: TextStyle(fontSize: 14, color: Color(0xFF5B4D54), height: 1.45),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '🪙  10  Each diary creation costs 10 coins',
                    style: TextStyle(fontSize: 14, color: Color(0xFF5B4D54), height: 1.45),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFFF0ECEF),
                child: Icon(Icons.close, size: 14, color: Color(0xFFA29AA0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isUser});

  final ChatMessage message;
  final bool isUser;

  String get _timeText =>
      '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFFF8A9BD), Color(0xFFF08FA9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border.all(color: const Color(0xFFFFD5E2), width: 1),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x33E985A2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Color(0x1AFFFFFF),
                      blurRadius: 2,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    if (message.photoUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (message.photoUrl!.startsWith('http'))
                              ? Image.network(
                                  message.photoUrl!,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(message.photoUrl!),
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    if (message.content.isNotEmpty)
                      const SizedBox.shrink()
                    else
                      const SizedBox.shrink(),
                    if (message.content.isNotEmpty)
                      const SizedBox.shrink()
                    else
                      const SizedBox.shrink(),
                    if (message.content.isNotEmpty)
                      Text(
                        message.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24 / 2,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          shadows: <Shadow>[
                            Shadow(
                              color: Color(0x33000000),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _timeText,
              style: const TextStyle(fontSize: 12, color: Color(0xFFA59AA0)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              CircleAvatar(
                radius: 11,
                backgroundColor: Color(0xFFF28EAA),
                child: Icon(Icons.favorite_rounded, size: 11, color: Colors.white),
              ),
              SizedBox(width: 8),
              Text(
                'Flira',
                style: TextStyle(
                  color: Color(0xFFAA9FA6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 325),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: const Color(0xFFF1E6EB)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 30 / 2,
                color: Color(0xFF3D353A),
                height: 1.42,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _timeText,
            style: const TextStyle(fontSize: 12, color: Color(0xFFA59AA0)),
          ),
        ],
      ),
    );
  }
}

class _TypingRow extends StatelessWidget {
  const _TypingRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFF59AAE),
            child: Icon(Icons.favorite_rounded, size: 14, color: Colors.white),
          ),
          SizedBox(width: 8),
          Text('Flira is typing...', style: TextStyle(color: Color(0xFF8F828A))),
        ],
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({
    required this.controller,
    required this.photoUrl,
    required this.isListening,
    required this.isSendLocked,
    required this.onChange,
    required this.onPickPhoto,
    required this.onToggleMic,
    required this.onRemovePhoto,
    required this.onSend,
  });

  final TextEditingController controller;
  final String? photoUrl;
  final bool isListening;
  final bool isSendLocked;
  final ValueChanged<String> onChange;
  final VoidCallback onPickPhoto;
  final VoidCallback onToggleMic;
  final VoidCallback onRemovePhoto;
  final VoidCallback onSend;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        if (_isFocused != _focusNode.hasFocus) {
          setState(() {
            _isFocused = _focusNode.hasFocus;
          });
        }
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCFD),
        border: Border(
          top: BorderSide(color: Color(0xFFF3DFE7)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.photoUrl != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: widget.photoUrl!.startsWith('http')
                          ? Image.network(widget.photoUrl!, width: 80, height: 100, fit: BoxFit.cover)
                          : Image.file(File(widget.photoUrl!), width: 80, height: 100, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: -8,
                      top: -8,
                      child: GestureDetector(
                        onTap: widget.onRemovePhoto,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF04A94),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.photoUrl != null) const SizedBox(height: 6),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: widget.onPickPhoto,
                icon: const Icon(Icons.photo_camera_outlined, color: Color(0xFFF38BA7)),
              ),
              IconButton(
                onPressed: widget.onToggleMic,
                icon: Icon(
                  widget.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: widget.isListening ? const Color(0xFFE75A88) : const Color(0xFFF38BA7),
                ),
              ),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isFocused ? const Color(0xFFF38BA7) : const Color(0xFFF1D7E0),
                      width: _isFocused ? 1.25 : 1,
                    ),
                    color: const Color(0xFFFFFCFD),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    focusNode: _focusNode,
                    controller: widget.controller,
                    onChanged: widget.onChange,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Share your thoughts...',
                      hintStyle: TextStyle(color: Color(0xFFB8ADB3), fontSize: 29 / 2),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.isSendLocked ? null : widget.onSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isSendLocked
                        ? const Color(0xFFE5CBD5)
                        : const Color(0xFFF7A4BB),
                  ),
                  child: widget.isSendLocked
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 19),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
