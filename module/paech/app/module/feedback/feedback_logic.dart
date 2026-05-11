import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class FeedbackLogic extends GetxController {
  final TextEditingController problemController = TextEditingController();

  final SpeechToText _speechToText = SpeechToText();

  final RxBool isSpeechEnabled = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isSubmitting = false.obs;
  
  // 用于跟踪已确认的文本，避免重复
  String _confirmedText = '';
  // 用于跟踪本次录音会话中最后的部分结果，避免最终结果重复
  String _lastPartialResult = '';
  // 用于跟踪本次会话是否已经追加过最终结果
  bool _sessionResultAdded = false;

  final RxList<String> quickTags = <String>[
    'Bug',
    'Suggestion',
    'Payment',
    'UI',
    'Performance',
  ].obs;

  final RxString selectedTag = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  /// This has to happen only once per app
  Future<void> _initSpeech() async {
    isSpeechEnabled.value = await _speechToText.initialize(
      onError: (error) {
        debugPrint('SpeechToText initialize error: $error');
      },
      onStatus: (status) {
        debugPrint('SpeechToText initialize status: $status');
      },
    );
    debugPrint('SpeechToText initialize enabled=${isSpeechEnabled.value}');
  }

  @override
  void onClose() {
    problemController.dispose();
    _speechToText.cancel();
    super.onClose();
  }

  void selectTag(String tag) {
    if (selectedTag.value == tag) {
      selectedTag.value = '';
      return;
    }
    selectedTag.value = tag;
  }

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  /// Each time to start a speech recognition session
  Future<void> _startListening() async {
    if (!isSpeechEnabled.value) {
      Get.snackbar(
        'Voice Input',
        'Speech recognition is not available on this device.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
      );
      return;
    }

    // 记录开始录音时的已确认文本
    _confirmedText = problemController.text.trim();
    _lastPartialResult = ''; // 重置部分结果
    _sessionResultAdded = false; // 重置追加标志
    isRecording.value = true;
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  /// Manually stop the active speech recognition session
  Future<void> _stopListening() async {
    await _speechToText.stop();
    isRecording.value = false;
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    // 直接使用识别结果，让系统自动使用设备语言
    final recognized = result.recognizedWords.trim();
    if (recognized.isEmpty) return;

    if (result.finalResult) {
      // 最终结果：追加本次会话的识别内容到已确认文本
      // 每个会话只追加一次，避免重复
      if (!_sessionResultAdded && recognized.isNotEmpty) {
        final newText = _confirmedText.isEmpty 
            ? recognized 
            : '$_confirmedText $recognized';
        
        _confirmedText = newText; // 更新已确认的文本
        problemController
          ..text = newText
          ..selection = TextSelection.collapsed(offset: newText.length);
        
        _sessionResultAdded = true; // 标记已追加
      }
      _lastPartialResult = ''; // 重置部分结果
    } else {
      // 部分结果：只用于实时显示，不保存到已确认文本
      // 显示：已确认文本 + 当前正在识别的部分
      _lastPartialResult = recognized; // 记录部分结果
      final displayText = _confirmedText.isEmpty 
          ? recognized 
          : '$_confirmedText $recognized';
      
      problemController
        ..text = displayText
        ..selection = TextSelection.collapsed(offset: displayText.length);
    }
  }

  Future<void> submitFeedback() async {
    if (isSubmitting.value) return;

    final problem = problemController.text.trim();
    if (problem.isEmpty) {
      Get.snackbar(
        'Feedback',
        'Please describe the issue before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700));

      Get.snackbar(
        'Thank You!',
        'Your feedback has been submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFFC8A57E),
        colorText: Colors.white,
      );

      problemController.clear();
      selectedTag.value = '';
    } finally {
      isSubmitting.value = false;
    }
  }
}
