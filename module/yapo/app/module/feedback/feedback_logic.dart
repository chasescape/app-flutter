import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class FeedbackLogic extends GetxController {
  final selectedType = 'Suggestion'.obs;
  final feedbackController = TextEditingController();
  final isSubmitting = false.obs;

  // 语音识别相关
  final SpeechToText _speechToText = SpeechToText();
  final isListening = false.obs;
  final isInitialized = false.obs;
  final recognizedText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  @override
  void onClose() {
    feedbackController.dispose();
    _speechToText.stop();
    super.onClose();
  }

  /// 初始化语音识别
  Future<void> _initSpeech() async {
    try {
      isInitialized.value = await _speechToText.initialize(
        onError: (error) {
          print('语音识别错误: $error');
          isListening.value = false;
        },
        onStatus: (status) {
          print('语音识别状态: $status');
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
      );
    } catch (e) {
      print('初始化语音识别失败: $e');
      isInitialized.value = false;
    }
  }

  /// 开始/停止语音识别
  Future<void> toggleListening() async {
    if (!isInitialized.value) {
      Get.snackbar(
        'Not Available',
        'Speech recognition is not available on this device',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (isListening.value) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// 开始语音识别
  Future<void> startListening() async {
    if (!isInitialized.value) return;

    // 记录开始识别时的文本位置
    final startText = feedbackController.text;
    final startOffset = startText.length;

    isListening.value = true;
    await _speechToText.listen(
      onResult: (result) {
        // ✅ 修复：只更新从开始识别后的新文本，避免重复
        if (result.recognizedWords.isNotEmpty) {
          if (startText.isEmpty) {
            feedbackController.text = result.recognizedWords;
          } else {
            // 只在原文本后追加一次新识别的文本
            feedbackController.text = '$startText ${result.recognizedWords}';
          }
          // 移动光标到末尾
          feedbackController.selection = TextSelection.fromPosition(
            TextPosition(offset: feedbackController.text.length),
          );
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  /// 停止语音识别
  Future<void> stopListening() async {
    await _speechToText.stop();
    isListening.value = false;
  }

  Future<void> submitFeedback() async {
    final feedback = feedbackController.text.trim();

    if (feedback.isEmpty) {
      Get.snackbar(
        'Empty Feedback',
        'Please enter your feedback before submitting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isSubmitting.value = true;

      // TODO: 调用反馈接口
      // await feedbackService.submitFeedback(
      //   type: selectedType.value,
      //   content: feedback,
      // );

      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 800));

      Get.snackbar(
        'Success',
        'Thank you for your feedback!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10b981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 清空输入
      feedbackController.clear();
      recognizedText.value = '';
      selectedType.value = 'Suggestion';

      // 延迟返回
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
    } catch (e) {
      print('提交反馈失败: $e');
      Get.snackbar(
        'Error',
        'Failed to submit feedback, please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
