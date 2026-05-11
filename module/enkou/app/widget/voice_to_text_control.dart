import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:enkou/enkou/app/widget/app_toast.dart';

class VoiceToTextControl extends StatefulWidget {
  const VoiceToTextControl({
    super.key,
    required this.controller,
    this.iconColor,
  });

  final TextEditingController controller;
  final Color? iconColor;

  @override
  State<VoiceToTextControl> createState() => _VoiceToTextControlState();
}

class _VoiceToTextControlState extends State<VoiceToTextControl> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _lastRecognized = ''; // 记录上次识别的文本，避免重复

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _lastRecognized = ''; // 停止时清空记录
      });
      return;
    }

    if (!_isAvailable) {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          // 当识别完成时清空记录
          if (status == 'done' || status == 'notListening') {
            _lastRecognized = '';
          }
        },
        onError: (error) {
          AppToast.show('', 'Speech error: ${error.errorMsg}', isError: true);
          setState(() {
            _isListening = false;
            _lastRecognized = '';
          });
        },
      );
      if (!_isAvailable) {
        AppToast.short('Speech recognition not available on this device.', isError: true);
        return;
      }
    }

    // 开始新的识别前清空记录
    _lastRecognized = '';

    await _speech.listen(
      onResult: (result) {
        final recognized = result.recognizedWords.trim();
        if (recognized.isEmpty) return;

        // 如果是相同的文本，不重复添加
        if (recognized == _lastRecognized) return;

        // 只在最终结果时写入
        if (result.finalResult) {
          final current = widget.controller.text;
          bool shouldAddSpace = false;
          if (current.isNotEmpty) {
            final lastChar = current[current.length - 1];
            const endPunctuations = ['。', '.', '!', '?', '！', '？'];
            shouldAddSpace = !endPunctuations.contains(lastChar);
          }
          final newText = StringBuffer(current);
          if (shouldAddSpace) {
            newText.write(' ');
          }
          newText.write(recognized);

          widget.controller.text = newText.toString();
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );

          // 记录已添加的文本
          _lastRecognized = recognized;
        }
      },
      listenMode: stt.ListenMode.confirmation, // 改用 confirmation 模式，避免重复
    );

    setState(() {
      _isListening = true;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? Theme.of(context).colorScheme.primary;
    return IconButton(
      onPressed: _toggleListening,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(
        _isListening ? Icons.mic : Icons.mic_none_rounded,
        size: 18,
        color: _isListening ? color : color.withOpacity(0.9),
      ),
    );
  }
}