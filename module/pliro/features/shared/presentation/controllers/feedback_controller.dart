import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pliro/pliro/features/shared/presentation/pages/feedback_page.dart';

/// Feedback controller
class FeedbackController extends GetxController {
  final contentController = TextEditingController();

  FeedbackType selectedType = FeedbackType.general;
  bool isSubmitting = false;

  // Speech to text - lazy initialization
  SpeechToText? _speechToText;
  bool _isListening = false;
  bool _isInitializing = false;

  bool get canSubmit => contentController.text.trim().isNotEmpty;
  bool get isListening => _isListening;

  void selectType(FeedbackType type) {
    selectedType = type;
    update();
  }

  /// Toggle voice input - lazy initialization
  Future<void> toggleVoiceInput() async {
    // If already listening, stop it
    if (_isListening) {
      await _stopListening();
      return;
    }

    // Prevent duplicate initialization
    if (_isInitializing) {
      return;
    }

    _isInitializing = true;
    update();

    try {
      // Lazy initialization: create SpeechToText instance only when needed
      if (_speechToText == null) {
        _speechToText = SpeechToText();

        // Initialize speech to text
        final isInitialized = await _speechToText!.initialize(
          onError: (error) {
            debugPrint('Speech recognition error: $error');
            _showErrorToast('Speech recognition error. Please try again.');
            _setInitializingAndListening(false, false);
          },
        );

        if (!isInitialized) {
          _showErrorToast(
              'Failed to initialize speech recognition. Please check your permissions.');
          _setInitializingAndListening(false, false);
          return;
        }
      }

      // Request permissions on first button click
      final micStatus = await Permission.microphone.request();
      final speechStatus = await Permission.speech.request();

      if (micStatus.isDenied || speechStatus.isDenied) {
        _showErrorToast(
            'Microphone and speech recognition permissions are required for voice input.');
        _setInitializingAndListening(false, false);
        return;
      }

      if (micStatus.isPermanentlyDenied || speechStatus.isPermanentlyDenied) {
        _showErrorToast(
            'Permissions are permanently denied. Please enable them in app settings.');
        _setInitializingAndListening(false, false);
        return;
      }

      // Start listening
      await _speechToText!.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          if (recognizedWords.isNotEmpty) {
            // Append recognized text to existing content
            final currentText = contentController.text;
            contentController.text = currentText.isEmpty
                ? recognizedWords
                : '$currentText $recognizedWords';
            // Move cursor to end
            contentController.selection = TextSelection.fromPosition(
              TextPosition(offset: contentController.text.length),
            );
            update();
          }

          // Update listening state based on final result
          if (result.finalResult) {
            _setListening(false);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      );

      _setInitializingAndListening(false, true);
    } catch (e) {
      debugPrint('Voice input error: $e');
      _showErrorToast('Failed to start voice input. Please try again.');
      _setInitializingAndListening(false, false);
    }
  }

  /// Stop listening
  Future<void> _stopListening() async {
    if (_speechToText != null && _isListening) {
      await _speechToText!.stop();
      _setListening(false);
    }
  }

  /// Set initializing and listening states together
  void _setInitializingAndListening(bool initializing, bool listening) {
    _isInitializing = initializing;
    _isListening = listening;
    update();
  }

  /// Set listening state
  void _setListening(bool listening) {
    _isListening = listening;
    update();
  }

  /// Show error toast message
  void _showErrorToast(String message) {
    if (Get.overlayContext != null) {
      ScaffoldMessenger.of(Get.overlayContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> onSubmit() async {
    if (!canSubmit) return;

    // Stop voice input if listening
    if (_isListening) {
      await _stopListening();
    }

    isSubmitting = true;
    update();

    try {
      // TODO: Send feedback to server
      await Future.delayed(const Duration(seconds: 2));

      isSubmitting = false;
      update();

      // Show success dialog
      AwesomeDialog(
        context: Get.overlayContext!,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Thank You!',
        desc: 'Your feedback has been submitted successfully.',
        btnOkOnPress: () {
          Get.back();
          contentController.clear();
        },
      ).show();
    } catch (e) {
      isSubmitting = false;
      update();

      AwesomeDialog(
        context: Get.overlayContext!,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Submission Failed',
        desc: 'Failed to submit feedback. Please try again.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  void onClose() {
    // Stop listening and release speech resources
    if (_speechToText != null && _isListening) {
      _speechToText!.stop();
      _speechToText = null;
    }
    contentController.dispose();
    super.onClose();
  }
}
