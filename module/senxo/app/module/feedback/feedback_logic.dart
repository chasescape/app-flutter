import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class FeedbackLogic extends GetxController {
  // Text Controllers
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final emailController = TextEditingController();

  // Observable State
  final selectedType = 0.obs;
  final hasAttachment = false.obs;
  
  // Speech to Text
  final SpeechToText _speechToText = SpeechToText();
  final isListening = false.obs;
  final speechText = ''.obs;
  final isSpeechAvailable = false.obs;

  // Feedback Types
  final feedbackTypes = [
    'Bug Report',
    'Feature Request',
    'Improvement',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  @override
  void onClose() {
    subjectController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    _speechToText.stop();
    super.onClose();
  }

  // Initialize Speech Recognition
  Future<void> _initSpeech() async {
    try {
      isSpeechAvailable.value = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          isListening.value = false;
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
      );
      print('Speech recognition available: ${isSpeechAvailable.value}');
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      isSpeechAvailable.value = false;
    }
  }

  // Request Microphone Permission
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Microphone Permission'),
          content: const Text(
            'Microphone permission is required for voice input. Please enable it in Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return false;
    }
    
    return false;
  }

  // Start/Stop Listening
  Future<void> toggleListening() async {
    if (!isSpeechAvailable.value) {
      Get.snackbar(
        'Not Available',
        'Speech recognition is not available on this device',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (isListening.value) {
      // Stop listening
      await _speechToText.stop();
      isListening.value = false;
    } else {
      // Check microphone permission first
      final permissionStatus = await Permission.microphone.status;
      print('Microphone permission status: $permissionStatus');
      
      if (permissionStatus.isDenied) {
        print('Requesting microphone permission...');
        final result = await Permission.microphone.request();
        print('Permission request result: $result');
        
        if (!result.isGranted) {
          Get.snackbar(
            'Permission Denied',
            'Microphone permission is required for voice input',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
          return;
        }
      } else if (permissionStatus.isPermanentlyDenied) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Microphone Permission'),
            content: const Text(
              'Microphone permission is required for voice input. Please enable it in Settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }

      // Start listening
      print('Starting speech recognition...');
      speechText.value = '';
      isListening.value = true;
      
      try {
        await _speechToText.listen(
          onResult: (result) {
            print('Speech result: ${result.recognizedWords}');
            speechText.value = result.recognizedWords;
            // Update description field with recognized text
            if (result.finalResult) {
              final currentText = descriptionController.text;
              final newText = currentText.isEmpty 
                  ? result.recognizedWords 
                  : '$currentText ${result.recognizedWords}';
              descriptionController.text = newText;
              descriptionController.selection = TextSelection.fromPosition(
                TextPosition(offset: descriptionController.text.length),
              );
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        );
      } catch (e) {
        print('Error starting speech recognition: $e');
        isListening.value = false;
        Get.snackbar(
          'Error',
          'Failed to start voice input: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    }
  }

  // Select Feedback Type
  void selectType(int index) {
    selectedType.value = index;
  }

  // Add Attachment
  void addAttachment() {
    // Mock implementation - would use image_picker in real app
    hasAttachment.value = true;
    Get.snackbar(
      'Attachment Added',
      'Screenshot uploaded successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFDAE0),
      colorText: Colors.black87,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // Remove Attachment
  void removeAttachment() {
    hasAttachment.value = false;
  }

  // Validate Form
  bool _validateForm() {
    // Subject is now optional - removed mandatory validation
    
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Description Required',
        'Please provide a detailed description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }

    // Validate email if provided
    if (emailController.text.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailController.text.trim())) {
        Get.snackbar(
          'Invalid Email',
          'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        return false;
      }
    }

    return true;
  }

  // Submit Feedback
  void submitFeedback() {
    if (!_validateForm()) return;

    // Mock submission - would call API in real app
    final feedbackData = {
      'type': feedbackTypes[selectedType.value],
      'subject': subjectController.text.trim(),
      'description': descriptionController.text.trim(),
      'email': emailController.text.trim(),
      'hasAttachment': hasAttachment.value,
    };

    // Show loading
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFDAE0)),
        ),
      ),
      barrierDismissible: false,
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Get.back(); // Close loading dialog

      // Show success message
      Get.snackbar(
        'Feedback Submitted',
        'Thank you for your feedback! We\'ll review it soon.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFDAE0),
        colorText: Colors.black87,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // Clear form
      _clearForm();

      // Navigate back after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    });
  }

  // Clear Form
  void _clearForm() {
    subjectController.clear();
    descriptionController.clear();
    emailController.clear();
    selectedType.value = 0;
    hasAttachment.value = false;
  }
}