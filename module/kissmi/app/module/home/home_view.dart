import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../gen_a/A.dart';
import '../../data/chat_store.dart';
import '../../routes/app_routes.dart';
import '../../widget/kissmi_background.dart';
import 'home_logic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeLogic logic = Get.put(HomeLogic());
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _chatBottomKey = GlobalKey();
  int _lastMessageCount = 0;
  bool _wasInChatMode = false;
  late final _KeyboardMetricsObserver _metricsObserver;

  @override
  void initState() {
    super.initState();
    _metricsObserver = _KeyboardMetricsObserver(onChange: _onMetricsChanged);
    WidgetsBinding.instance.addObserver(_metricsObserver);
  }

  void _onMetricsChanged() {
    if (!mounted) return;
    if (!logic.inChatMode) return;
    // Keyboard show/hide changes viewport; keep latest message visible.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = _chatBottomKey.currentContext;
      if (context == null) return;
      await Scrollable.ensureVisible(
        context,
        alignment: 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_metricsObserver);
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeScrollToBottom({
    required bool inChatMode,
    required List<ChatMessage> messages,
    required ScrollController controller,
  }) {
    if (!inChatMode) {
      _wasInChatMode = false;
      _lastMessageCount = messages.length;
      return;
    }

    final bool justEnteredChat = !_wasInChatMode && inChatMode;
    final bool messageCountChanged = messages.length != _lastMessageCount;

    _wasInChatMode = inChatMode;
    _lastMessageCount = messages.length;

    if (!justEnteredChat && !messageCountChanged) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (controller.hasClients) {
        await controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
        return;
      }
      final context = _chatBottomKey.currentContext;
      if (context == null) return;
      await Scrollable.ensureVisible(
        context,
        alignment: 1.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const _ChatHistoryDrawer(),
      resizeToAvoidBottomInset: true,
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
      },
      body: Builder(
        builder: (scaffoldContext) => KissmiBackground(
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: GetBuilder<HomeLogic>(
                    builder: (homeLogic) {
                      final List<ChatMessage> messages = homeLogic.currentMessages;
                      _maybeScrollToBottom(
                        inChatMode: homeLogic.inChatMode,
                        messages: messages,
                        controller: _scrollController,
                      );
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: _TopBar(
                              onMenuTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                SystemChannels.textInput.invokeMethod('TextInput.hide');
                                Scaffold.of(scaffoldContext).openDrawer();
                              },
                              onCalendarTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                Get.toNamed(AppRoutes.date);
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () =>
                                  FocusScope.of(scaffoldContext).unfocus(),
                              child: homeLogic.inChatMode
                                  ? _ChatList(
                                      controller: _scrollController,
                                      messages: messages,
                                      bottomKey: _chatBottomKey,
                                    )
                                  : SingleChildScrollView(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Center(
                                            child: Transform.translate(
                                              offset: const Offset(0, -50),
                                              child: SizedBox(
                                                width: 400,
                                                height: 400,
                                                child: ClipRect(
                                                  child: Align(
                                                    alignment: Alignment.topCenter,
                                                    heightFactor: 0.78,
                                                    child: Lottie.asset(
                                                      A.assets_loading_home,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: const Offset(0, -150),
                                            child: Column(
                                              children: <Widget>[
                                                Center(
                                                  child: DefaultTextStyle(
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white.withValues(alpha: 0.95),
                                                    ),
                                                    child: AnimatedTextKit(
                                                      isRepeatingAnimation: false,
                                                      totalRepeatCount: 1,
                                                      animatedTexts: <AnimatedText>[
                                                        TypewriterAnimatedText(
                                                          'Hi, I am Kissmi',
                                                          speed: const Duration(milliseconds: 60),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Center(
                                                  child: DefaultTextStyle(
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      height: 1.4,
                                                      color: Colors.white.withValues(alpha: 0.72),
                                                    ),
                                                    child: AnimatedTextKit(
                                                      isRepeatingAnimation: false,
                                                      totalRepeatCount: 1,
                                                      animatedTexts: <AnimatedText>[
                                                        TypewriterAnimatedText(
                                                          'Let’s make something magical today.',
                                                          speed: const Duration(milliseconds: 40),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                const _ActionGrid(),
                                                const SizedBox(height: 24),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 0,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(scaffoldContext).viewInsets.bottom + 16,
                    ),
                    child: const _ComposerBar(),
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onMenuTap,
    required this.onCalendarTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _IconChip(
          icon: Icons.menu,
          onTap: onMenuTap,
          size: 42,
          radius: 24,
        ),
        const Spacer(),
        Text(
          'Kissmi',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 0.6,
          ),
        ),
        const Spacer(),
        _IconChip(
          icon: Icons.calendar_month,
          onTap: onCalendarTap,
          size: 42,
          radius: 22,
        ),
      ],
    );
  }
}

class _ComposerBar extends StatefulWidget {
  const _ComposerBar();

  @override
  State<_ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<_ComposerBar> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late final stt.SpeechToText _speech;
  bool _listening = false;

  static const LinearGradient _listeningGradient = LinearGradient(
    colors: <Color>[
      Color(0xFFFF8BD8),
      Color(0xFF7C3AED),
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121528).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          GetBuilder<HomeLogic>(
            builder: (logic) => _IconButton(
              icon: Icons.image_outlined,
              onTap: logic.isSending.value ? () {} : _pickImage,
              disabled: logic.isSending.value,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _InputField(controller: _controller),
          ),
          const SizedBox(width: 8),
          GetBuilder<HomeLogic>(
            builder: (logic) => GestureDetector(
              onLongPress: logic.isSending.value ? null : () => Get.toNamed(AppRoutes.voice),
              child: _VoiceButton(
                listening: _listening,
                onTap: logic.isSending.value ? () {} : _toggleListening,
                disabled: logic.isSending.value,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GetBuilder<HomeLogic>(
            builder: (logic) => _SendButton(
              isSending: logic.isSending.value,
              onTap: logic.isSending.value 
                  ? () {} // 发送中时不响应点击
                  : () {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      _controller.clear();
                      logic.sendTextMessage(text);
                    },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final PermissionStatus status = await _requestPhotoPermission();
    if (!status.isGranted) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bool? confirm = await Get.dialog<bool>(
      Center(
        child: Material(
          color: Colors.transparent,
          child: IntrinsicWidth(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFF7C3AED),
                      Color(0xFFEC4899),
                      Color(0xFF3B82F6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                      blurRadius: 32,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101327).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 0.6,
                    ),
                  ),
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Send this image?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320, maxWidth: 320),
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back<bool>(result: false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back<bool>(result: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6D28D9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Send'),
                        ),
                      ),
                    ],
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
    if (confirm == true) {
      Get.find<HomeLogic>().sendImageMessage(image.path);
    }
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }

    final PermissionStatus status = await _requestMicrophonePermission();
    if (!status.isGranted) return;

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _listening = false);
        }
      },
      onError: (error) {
        setState(() => _listening = false);
        Get.snackbar('Voice error', error.errorMsg);
      },
    );

    if (!available) {
      Get.snackbar('Voice', 'Speech recognition unavailable.');
      return;
    }

    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      },
    );
  }

  Future<PermissionStatus> _requestPhotoPermission() async {
    final PermissionStatus status = await Permission.photos.request();
    if (status.isPermanentlyDenied || status.isRestricted) {
      _showPermissionDialog(
        title: 'Photo access needed',
        message: 'Allow photo access in Settings to pick images.',
      );
    } else if (!status.isGranted) {
      Get.snackbar('Permission', 'Photo access denied.');
    }
    return status;
  }

  Future<PermissionStatus> _requestMicrophonePermission() async {
    final PermissionStatus status = await Permission.microphone.request();
    if (status.isPermanentlyDenied || status.isRestricted) {
      _showPermissionDialog(
        title: 'Microphone access needed',
        message: 'Allow microphone access in Settings to use voice input.',
      );
    } else if (!status.isGranted) {
      Get.snackbar('Permission', 'Microphone access denied.');
    }
    return status;
  }

  void _showPermissionDialog({
    required String title,
    required String message,
  }) {
    Get.dialog<void>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Get.back<void>();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _ChatThread extends StatelessWidget {
  const _ChatThread({required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Start by sharing how you feel today.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
      );
    }
    return Column(
      children: messages
          .map((message) => _ChatBubble(message: message))
          .toList(),
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList({
    required this.controller,
    required this.messages,
    required this.bottomKey,
  });

  final ScrollController controller;
  final List<ChatMessage> messages;
  final Key bottomKey;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Start by sharing how you feel today.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 150),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return SizedBox(key: bottomKey, height: 1);
        }
        return _ChatBubble(message: messages[index]);
      },
    );
  }
}

class _KeyboardMetricsObserver with WidgetsBindingObserver {
  _KeyboardMetricsObserver({required this.onChange});

  final VoidCallback onChange;

  @override
  void didChangeMetrics() {
    onChange();
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF7C3AED),
                    Color(0xFFEC4899),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF1B203B),
                    Color(0xFF2A1439),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: _bubbleContent(),
      ),
    );
  }

  Widget _bubbleContent() {
    if (message.isThinking) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          _ThinkingDot(),
          SizedBox(width: 6),
          _ThinkingDot(delay: 1),
          SizedBox(width: 6),
          _ThinkingDot(delay: 2),
        ],
      );
    }
    if (message.imagePath != null) {
      final file = File(message.imagePath!);
      if (!file.existsSync()) {
        return Text(
          'Image is unavailable (expired or removed).',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13,
            height: 1.35,
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260, maxHeight: 300),
          child: Image.file(
            file,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return Text(
      message.text ?? '',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 13,
        height: 1.35,
      ),
    );
  }
}

class _ThinkingDot extends StatefulWidget {
  const _ThinkingDot({this.delay = 0});

  final int delay;

  @override
  State<_ThinkingDot> createState() => _ThinkingDotState();
}

class _ThinkingDotState extends State<_ThinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _animation = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1B203B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 13,
          color: Colors.white.withValues(alpha: 0.9),
        ),
        cursorColor: Colors.white.withValues(alpha: 0.8),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Type a message...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF1B203B).withValues(alpha: disabled ? 0.5 : 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: disabled ? 0.06 : 0.12),
          ),
        ),
        child: Icon(
          icon, 
          color: Colors.white.withValues(alpha: disabled ? 0.4 : 1.0), 
          size: 18,
        ),
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  const _VoiceButton({
    required this.listening,
    required this.onTap,
    this.disabled = false,
  });

  final bool listening;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          gradient: listening ? _ComposerBarState._listeningGradient : null,
          color: listening
              ? null
              : const Color(0xFF1B203B).withValues(alpha: disabled ? 0.5 : 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: disabled ? 0.06 : 0.12),
          ),
          boxShadow: listening
              ? <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Icon(
          listening ? Icons.mic : Icons.mic_none,
          color: Colors.white.withValues(alpha: disabled ? 0.4 : 1.0),
          size: 18,
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.onTap,
    this.isSending = false,
  });

  final VoidCallback onTap;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSending ? null : onTap, // 发送中时禁用点击
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSending 
                ? <Color>[
                    const Color(0xFFFF8BD8).withValues(alpha: 0.4),
                    const Color(0xFF7C3AED).withValues(alpha: 0.4),
                  ]
                : const <Color>[
                    Color(0xFFFF8BD8),
                    Color(0xFF7C3AED),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF9F7AEA).withValues(alpha: isSending ? 0.2 : 0.55),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.send,
                  size: 18,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    final HomeLogic logic = Get.find<HomeLogic>();
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _ActionTile(
                title: 'Daily Check‑in',
                subtitle: 'Chat to log mood & energy',
                icon: Icons.chat_bubble_outline,
                accent: const Color(0xFF8C7AE6),
                onTap: null,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                title: 'Cycle Insight',
                subtitle: 'Today: do / avoid',
                icon: Icons.calendar_month,
                accent: const Color(0xFFD96C9B),
                onTap: null,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _ActionTile(
                title: 'Photo Mood',
                subtitle: 'Attach a photo for context',
                icon: Icons.image_outlined,
                accent: const Color(0xFF5B6EE1),
                onTap: null,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                title: 'Record Symptoms',
                subtitle: 'Notes & fatigue level',
                icon: Icons.favorite_border,
                accent: const Color(0xFFC66B7E),
                onTap: null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              accent.withValues(alpha: 0.6),
              accent.withValues(alpha: 0.18),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.radius = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF1B203B).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF9864FF).withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.45),
      ),
    );
  }
}

class _ChatHistoryDrawer extends StatelessWidget {
  const _ChatHistoryDrawer();

  @override
  Widget build(BuildContext context) {
    final HomeLogic logic = Get.find<HomeLogic>();
    return Drawer(
      backgroundColor: const Color(0xFF0F1226),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: <Widget>[
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF202544)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    logic.startNewTopic();
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Topic'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GetBuilder<HomeLogic>(
                builder: (logic) => ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: logic.sessions.length,
                  itemBuilder: (context, index) {
                    final session = logic.sessions[index];
                    return Dismissible(
                      key: ValueKey<String>(session.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => logic.deleteSession(session),
                      child: _HistoryTile(
                        title: session.title,
                        subtitle: _formatSessionDate(session.updatedAt),
                        onTap: () {
                          logic.openSession(session);
                          Navigator.of(context).maybePop();
                        },
                        onRename: () => _showRenameDialog(
                          context,
                          initial: session.title,
                          onSave: (value) => logic.renameSession(session, value),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _DrawerProfileButton(
                onTap: () {
                  Navigator.of(context).pop();
                  Get.toNamed(AppRoutes.profile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onRename,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: const CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFF1B203B),
        child: Icon(Icons.chat_bubble, color: Colors.white, size: 16),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
      ),
      onTap: onTap,
      onLongPress: onRename,
    );
  }
}

String _formatSessionDate(DateTime date) {
  final String m = date.month.toString().padLeft(2, '0');
  final String d = date.day.toString().padLeft(2, '0');
  final String h = date.hour.toString().padLeft(2, '0');
  final String min = date.minute.toString().padLeft(2, '0');
  return '${date.year}.$m.$d $h:$min';
}

void _showRenameDialog(
  BuildContext context, {
  required String initial,
  required ValueChanged<String> onSave,
}) {
  final controller = TextEditingController(text: initial);
  Get.dialog<void>(
    AlertDialog(
      title: const Text('Rename Topic'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Topic name'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onSave(controller.text);
            Get.back<void>();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _DrawerProfileButton extends StatelessWidget {
  const _DrawerProfileButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B203B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: const <Widget>[
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF2A1439),
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
