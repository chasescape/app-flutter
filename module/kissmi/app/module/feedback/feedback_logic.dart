import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FeedbackLogic extends GetxController {
  final RxString selectedTag = 'Bug'.obs;
  final RxBool isSending = false.obs;
  final RxBool isListening = false.obs;
  late final TextEditingController textController;
  late final stt.SpeechToText _speech;

  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController();
    _speech = stt.SpeechToText();
  }

  @override
  void onClose() {
    textController.dispose();
    _speech.stop();
    super.onClose();
  }

  void selectTag(String tag) {
    selectedTag.value = tag;
  }

  Future<void> sendFeedback() async {
    if (isSending.value) return;

    final String content = textController.text.trim();
    if (content.isEmpty) {
      Get.snackbar(
        'Feedback',
        'Please tell us a bit more so we can help.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF111827),
        colorText: Colors.white,
      );
      return;
    }

    isSending.value = true;
    try {
      // TODO: wire up with real feedback API.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      textController.clear();
      Get.snackbar(
        'Thank you!',
        'Your feedback has been received.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF111827),
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> startVoiceInput() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      return;
    }

    final PermissionStatus status = await Permission.microphone.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission',
        'Microphone access denied.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF111827),
        colorText: Colors.white,
      );
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
        }
      },
      onError: (error) {
        isListening.value = false;
        Get.snackbar(
          'Voice error',
          error.errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF111827),
          colorText: Colors.white,
        );
      },
    );

    if (!available) {
      Get.snackbar(
        'Voice',
        'Speech recognition unavailable.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF111827),
        colorText: Colors.white,
      );
      return;
    }

    isListening.value = true;
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          textController.text = result.recognizedWords;
          textController.selection = TextSelection.fromPosition(
            TextPosition(offset: textController.text.length),
          );
        }
      },
    );
  }
}
