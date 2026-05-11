import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../emotion/emotion_logic.dart';
import '../emotion/emotion_models.dart';
import '../coins/coins_logic.dart';
import '../../data/story_ai_service.dart';

class HomeLogic extends GetxController {
  final selectedEmotion = Rxn<EmotionType>();
  final intensity = 5.obs;
  final noteController = TextEditingController();
  final pickedImage = Rxn<XFile>();
  final isListening = false.obs;
  final isGeneratingAi = false.obs;

  final _imagePicker = ImagePicker();
  final _speech = stt.SpeechToText();

  final _advice = {
    EmotionType.happy: const _EmotionAdvice(
      title: 'Embrace the Joy',
      suggestion: 'Share your happiness with others or capture this moment in a photo or journal entry.',
    ),
    EmotionType.sad: const _EmotionAdvice(
      title: 'It\'s Okay to Feel Sad',
      suggestion: 'Try deep breathing exercises or express your feelings through journaling. Consider reaching out to someone you trust.',
    ),
    EmotionType.calm: const _EmotionAdvice(
      title: 'Beautiful Balance',
      suggestion: 'Maintain this peaceful state through meditation or a mindful walk. Notice the present moment.',
    ),
    EmotionType.anxious: const _EmotionAdvice(
      title: 'Let\'s Ground Together',
      suggestion: 'Practice the 5-4-3-2-1 technique: Notice 5 things you see, 4 you can touch, 3 you hear, 2 you smell, and 1 you taste.',
    ),
    EmotionType.angry: const _EmotionAdvice(
      title: 'Channel This Energy',
      suggestion: 'Take deep breaths and count to 10. Physical activity or writing down your thoughts can help process this feeling.',
    ),
    EmotionType.excited: const _EmotionAdvice(
      title: 'Ride This Wave',
      suggestion: 'Channel this energy into something creative or productive. Share your excitement with people who uplift you.',
    ),
  };

  void selectEmotion(EmotionType emotion) {
    selectedEmotion.value = emotion;
  }

  _EmotionAdvice getAdvice(EmotionType emotion) => _advice[emotion]!;

  String imageForEmotion(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.happy:
        return 'https://images.unsplash.com/photo-1591021802639-72a355b39886?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400';
      case EmotionType.sad:
        return 'https://images.unsplash.com/photo-1764677224091-d300d12df5f6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400';
      case EmotionType.calm:
        return 'https://images.unsplash.com/photo-1766524791322-8753e582e652?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400';
      case EmotionType.anxious:
        return 'https://images.unsplash.com/photo-1625662171040-8d196a082232?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400';
      case EmotionType.angry:
        return 'https://images.unsplash.com/photo-1758521540924-a061adde98ed?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400';
      case EmotionType.excited:
        return 'https://images.unsplash.com/photo-1758274526671-ad18176acb01?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=400';
    }
  }

  String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      pickedImage.value = image;
    }
  }

  Future<void> toggleListening() async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      return;
    }

    isListening.value = true;
    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      onResult: (result) {
        if (result.recognizedWords.isEmpty) {
          return;
        }
        noteController.text = result.recognizedWords;
        noteController.selection = TextSelection.fromPosition(
          TextPosition(offset: noteController.text.length),
        );
        if (result.finalResult) {
          isListening.value = false;
        }
      },
    );
  }

  Future<void> saveEntry(EmotionLogic emotionLogic) async {
    final emotion = selectedEmotion.value;
    if (emotion == null) return;

    // 尝试扣费（使用 AI 分析）
    final coinsLogic = Get.find<CoinsLogic>();
    if (!coinsLogic.useAI()) {
      // 余额不足，不保存记录
      return;
    }

    // 如果用户上传了照片，调用 AI 生成故事
    String? aiTitle;
    String? aiStory;
    
    if (pickedImage.value != null) {
      isGeneratingAi.value = true;
      try {
        final imageFile = File(pickedImage.value!.path);
        print('🤖 Starting AI story generation...');
        final storyResult = await StoryAiService().generateStory(imageFile);
        aiTitle = storyResult.title;
        aiStory = storyResult.story;
        print('✅ AI story generated: $aiTitle');
      } catch (e) {
        print('❌ AI story generation failed: $e');
        // 失败时使用默认建议
        final advice = getAdvice(emotion);
        aiTitle = advice.title;
        aiStory = advice.suggestion;
      } finally {
        isGeneratingAi.value = false;
      }
    } else {
      // 没有照片时使用默认建议
      final advice = getAdvice(emotion);
      aiTitle = advice.title;
      aiStory = advice.suggestion;
    }

    final entry = EmotionEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emotion: emotion,
      intensity: intensity.value,
      note: noteController.text,
      timestamp: DateTime.now(),
      imagePath: pickedImage.value?.path,
      aiStoryTitle: aiTitle,
      aiStoryContent: aiStory,
    );

    emotionLogic.addEntry(entry);
    selectedEmotion.value = null;
    intensity.value = 5;
    noteController.clear();
    pickedImage.value = null;
    isListening.value = false;
  }

  @override
  void onClose() {
    noteController.dispose();
    _speech.stop();
    super.onClose();
  }
}

class _EmotionAdvice {
  const _EmotionAdvice({required this.title, required this.suggestion});

  final String title;
  final String suggestion;
}
