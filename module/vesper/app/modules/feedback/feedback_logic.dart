import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class FeedbackLogic extends GetxController {
  final TextEditingController textController = TextEditingController();
  final SpeechToText _speech = SpeechToText();

  String? selectedType;
  String? selectedPrice;
  bool isListening = false;

  void selectType(String value) {
    selectedType = value;
    update();
  }

  void selectPrice(String value) {
    selectedPrice = value;
    update();
  }

  Future<void> toggleListening() async {
    if (isListening) {
      await _speech.stop();
      isListening = false;
      update();
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      return;
    }

    isListening = true;
    update();

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

  @override
  void onClose() {
    textController.dispose();
    _speech.stop();
    super.onClose();
  }
}
