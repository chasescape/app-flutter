import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class FeedbackType {
  final String id;
  final String label;

  FeedbackType({
    required this.id,
    required this.label,
  });
}

class FeedbackController extends GetxController {
  final RxString selectedType = ''.obs;
  final RxString message = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isListening = false.obs;
  final RxBool isInitializing = false.obs;
  final TextEditingController messageController = TextEditingController();

  SpeechToText? _speechToText;
  final RxBool speechEnabled = false.obs;
  String _listeningBaseMessage = '';

  final List<FeedbackType> feedbackTypes = [
    FeedbackType(id: 'bug', label: 'Bug Report'),
    FeedbackType(id: 'feature', label: 'Feature Request'),
    FeedbackType(id: 'ui', label: 'UI/UX'),
    FeedbackType(id: 'other', label: 'Other'),
  ];

  void selectType(String type) {
    selectedType.value = selectedType.value == type ? '' : type;
  }

  void setMessage(String value) {
    message.value = value;
  }

  Future<void> toggleListening() async {
    if (isListening.value) {
      await _stopListening();
      return;
    }

    if (isInitializing.value) {
      return;
    }

    await _startListening();
  }

  Future<void> _startListening() async {
    if (isInitializing.value) return;

    isInitializing.value = true;

    try {
      if (_speechToText == null) {
        _speechToText = SpeechToText();
        bool initialized = await _speechToText!.initialize(
          onError: (error) {
            isListening.value = false;
            _showErrorSnackbar(error.errorMsg);
          },
          onStatus: (status) {
            if (status == 'listening') {
              isListening.value = true;
            } else if (status == 'notListening' || status == 'done') {
              isListening.value = false;
            }
          },
        );

        if (!initialized) {
          _showErrorSnackbar('Speech recognition not available');
          isInitializing.value = false;
          return;
        }

        speechEnabled.value = initialized;
      }

      if (!speechEnabled.value) {
        _showErrorSnackbar('Speech recognition not available');
        isInitializing.value = false;
        return;
      }

      final statuses = await [
        Permission.microphone,
        Permission.speech,
      ].request();

      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        _showErrorSnackbar('Microphone permission is required for voice input');
        isInitializing.value = false;
        return;
      }
      if (statuses[Permission.speech] != PermissionStatus.granted) {
        _showErrorSnackbar('Speech recognition permission is required for voice input');
        isInitializing.value = false;
        return;
      }

      _listeningBaseMessage = messageController.text.trim();

      await _speechToText!.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords.trim();
          if (recognizedWords.isNotEmpty) {
            final prefix =
                _listeningBaseMessage.isEmpty ? '' : '$_listeningBaseMessage ';
            final composedMessage = '$prefix$recognizedWords'.trim();
            _updateMessageText(composedMessage);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Failed to start speech recognition');
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speechToText?.stop();
      isListening.value = false;
      _listeningBaseMessage = messageController.text.trim();
    } catch (e) {
      _showErrorSnackbar('Failed to stop speech recognition');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> submitFeedback() async {
    if (message.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your message',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      await Future.delayed(const Duration(seconds: 2));
      await _stopListening();
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit feedback',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    _speechToText?.cancel();
    messageController.dispose();
    super.onClose();
  }

  void _updateMessageText(String value) {
    if (messageController.text == value && message.value == value) {
      return;
    }
    message.value = value;
    messageController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }
}
