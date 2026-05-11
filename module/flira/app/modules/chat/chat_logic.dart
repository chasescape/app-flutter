import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:flira/flira/app/modules/nav/flira_state.dart';
import 'package:get/get.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.photoUrl,
    required this.timestamp,
  });

  final String id;
  final String role;
  final String content;
  final String? photoUrl;
  final DateTime timestamp;
}

class ChatLogic extends GetxController {
  static const String _initialAiMessage =
      'Hi girl, tell me a little about your day. Share a few moments and one photo, and I will turn it into your diary.';

  // IMPORTANT: Move this key to server-side or secure config in production.
  static const String _apiKey = 'sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a';

  final dio.Dio _dio = dio.Dio(
    dio.BaseOptions(
      baseUrl: 'https://api.gpt.ge',
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 40),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    ),
  );

  final RxList<ChatMessage> messages = <ChatMessage>[
    ChatMessage(
      id: '1',
      role: 'ai',
      content: _initialAiMessage,
      timestamp: DateTime.now(),
    ),
  ].obs;

  final RxString inputText = ''.obs;
  final RxBool isAiTyping = false.obs;
  final RxnString uploadedPhoto = RxnString();
  final RxBool isDiaryGenerated = false.obs;
  final RxnString lastGeneratedEntryId = RxnString();

  int get userMessageCount => messages.where((ChatMessage m) => m.role == 'user').length;

  int get userTextMessageCount =>
      messages.where((ChatMessage m) => m.role == 'user' && m.content.trim().isNotEmpty).length;

  void setInput(String value) => inputText.value = value;

  void mockPhoto() {
    uploadedPhoto.value =
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80';
  }

  void setPhotoPath(String path) {
    uploadedPhoto.value = path;
  }

  void removePhoto() => uploadedPhoto.value = null;

  Future<void> sendMessage() async {
    if (inputText.value.trim().isEmpty && uploadedPhoto.value == null) return;

    lastGeneratedEntryId.value = null;

    final ChatMessage userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: 'user',
      content: inputText.value.trim(),
      photoUrl: uploadedPhoto.value,
      timestamp: DateTime.now(),
    );

    messages.add(userMessage);
    inputText.value = '';
    uploadedPhoto.value = null;
    isAiTyping.value = true;

    await Future<void>.delayed(const Duration(milliseconds: 350));

    // 规则：用户发送满两条“有文字内容”的消息后，自动生成一篇日记。
    if (userTextMessageCount >= 2) {
      await generateDiary();
      return;
    }

    messages.add(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: 'ai',
        content: _lightweightCoachReply(),
        timestamp: DateTime.now(),
      ),
    );
    isAiTyping.value = false;
  }

  void restartSession() {
    messages
      ..clear()
      ..add(
        ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          role: 'ai',
          content: _initialAiMessage,
          timestamp: DateTime.now(),
        ),
      );

    inputText.value = '';
    uploadedPhoto.value = null;
    isAiTyping.value = false;
    isDiaryGenerated.value = false;
    lastGeneratedEntryId.value = null;
  }

  Future<void> generateDiary() async {
    if (!await FliraState.spendCoins(10)) {
      isAiTyping.value = false;
      Get.snackbar('Coins not enough', 'You need 10 coins to create a diary.');
      return;
    }

    final List<ChatMessage> userMessages =
        messages.where((ChatMessage m) => m.role == 'user').toList(growable: false);

    final String userInput = userMessages
        .map((ChatMessage m) => m.content)
        .where((String e) => e.isNotEmpty)
        .join('\n');

    String? latestPhoto;
    for (final ChatMessage m in userMessages.reversed) {
      if (m.photoUrl != null && m.photoUrl!.isNotEmpty) {
        latestPhoto = m.photoUrl;
        break;
      }
    }

    final _DiaryAiResult aiResult = await _buildDiaryWithAi(
      mergedUserText: userInput,
      latestPhotoPathOrUrl: latestPhoto,
    );

    final String entryId = DateTime.now().millisecondsSinceEpoch.toString();

    await FliraState.addEntry(
      DiaryEntry(
        id: entryId,
        date: DateTime.now(),
        photoUrl: latestPhoto ??
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80',
        userInput: userInput.isEmpty ? 'Today was a beautiful day.' : userInput,
        aiDiary: aiResult.story,
        mood: aiResult.mood,
      ),
    );

    messages.add(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: 'ai',
        content: 'Diary created successfully. 10 coins used.\n\n${aiResult.story}',
        timestamp: DateTime.now(),
      ),
    );

    lastGeneratedEntryId.value = entryId;
    isAiTyping.value = false;
    isDiaryGenerated.value = true;
  }

  String _lightweightCoachReply() {
    final int count = userMessageCount;
    if (count == 1) {
      return 'Love this. Tell me one more moment from today — something small but meaningful.';
    }
    if (count == 2) {
      return 'Great. One last detail and your daily diary will be ready.';
    }
    return 'Perfect, I can now organize your day into a warm diary entry.';
  }

  Future<_DiaryAiResult> _buildDiaryWithAi({
    required String mergedUserText,
    required String? latestPhotoPathOrUrl,
  }) async {
    try {
      final List<Map<String, dynamic>> content = <Map<String, dynamic>>[
        <String, dynamic>{
          'type': 'text',
          'text': _buildDiaryPrompt(mergedUserText),
        },
      ];

      if (latestPhotoPathOrUrl != null && latestPhotoPathOrUrl.isNotEmpty) {
        if (latestPhotoPathOrUrl.startsWith('http')) {
          content.add(
            <String, dynamic>{
              'type': 'image_url',
              'image_url': <String, dynamic>{'url': latestPhotoPathOrUrl},
            },
          );
        } else {
          final File file = File(latestPhotoPathOrUrl);
          if (await file.exists()) {
            final List<int> imageBytes = await file.readAsBytes();
            final String base64Image = base64Encode(imageBytes);
            content.add(
              <String, dynamic>{
                'type': 'image_url',
                'image_url': <String, dynamic>{
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            );
          }
        }
      }

      final dio.Response<dynamic> response = await _dio.post<dynamic>(
        '/v1/chat/completions',
        data: <String, dynamic>{
          'model': 'gpt-4o-2024-05-13',
          'messages': <Map<String, dynamic>>[
            <String, dynamic>{
              'role': 'user',
              'content': content,
            },
          ],
          'max_tokens': 900,
          'temperature': 0.8,
        },
        options: dio.Options(
          headers: <String, String>{
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );

      final Map<String, dynamic> json = Map<String, dynamic>.from(response.data as Map);
      final List<dynamic> choices = (json['choices'] as List<dynamic>? ?? <dynamic>[]);
      if (choices.isEmpty) {
        return _fallbackDiary(mergedUserText);
      }

      final Map<String, dynamic> first = Map<String, dynamic>.from(choices.first as Map);
      final Map<String, dynamic> message = Map<String, dynamic>.from(first['message'] as Map);
      String contentText = (message['content'] as String? ?? '').trim();
      if (contentText.isEmpty) {
        return _fallbackDiary(mergedUserText);
      }

      contentText = _extractJsonString(contentText);
      final Map<String, dynamic> parsed = jsonDecode(contentText) as Map<String, dynamic>;

      final String story = (parsed['story'] as String? ?? '').trim();
      final String moodRaw = (parsed['mood'] as String? ?? '').trim();

      if (story.isEmpty) {
        return _fallbackDiary(mergedUserText);
      }

      return _DiaryAiResult(
        story: story,
        mood: moodRaw.isEmpty ? _randomMood() : moodRaw,
      );
    } catch (_) {
      return _fallbackDiary(mergedUserText);
    }
  }

  String _buildDiaryPrompt(String mergedUserText) {
    return '''
You are Flira, a warm and empathetic AI diary companion for young women.

The user shared parts of her day below. Rewrite it into a polished and emotionally resonant daily diary in English.

User raw notes:
$mergedUserText

Requirements:
1) Return ONLY valid JSON (no markdown, no extra text).
2) JSON fields:
{
  "story": "2-4 short paragraphs, soft and heartfelt tone, specific details, clear emotional arc",
  "mood": "one word mood such as Happy, Peaceful, Grateful, Reflective, Hopeful"
}
3) Keep it authentic, gentle, and memorable.
4) Avoid generic clichés.
''';
  }

  String _extractJsonString(String raw) {
    String text = raw.trim();

    if (text.contains('```json')) {
      final int start = text.indexOf('```json') + 7;
      final int end = text.indexOf('```', start);
      if (end > start) {
        text = text.substring(start, end).trim();
      }
    } else if (text.contains('```')) {
      final int start = text.indexOf('```') + 3;
      final int end = text.indexOf('```', start);
      if (end > start) {
        text = text.substring(start, end).trim();
      }
    }

    final int firstBrace = text.indexOf('{');
    final int lastBrace = text.lastIndexOf('}');
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      return text.substring(firstBrace, lastBrace + 1);
    }

    return text;
  }

  _DiaryAiResult _fallbackDiary(String mergedUserText) {
    final String source = mergedUserText.trim().isEmpty
        ? 'Today had a lot of tiny moments that quietly touched my heart.'
        : mergedUserText.trim();

    final String story =
        'Today felt soft and meaningful. $source\n\nI slowed down, noticed the little details around me, and gave myself space to breathe. Even ordinary moments became something worth remembering.\n\nTonight, I feel thankful for how far I have come, and I want to carry this gentle strength into tomorrow.';

    return _DiaryAiResult(story: story, mood: _randomMood());
  }

  String _randomMood() {
    const List<String> moods = <String>['Happy', 'Grateful', 'Peaceful', 'Reflective', 'Hopeful'];
    return moods[Random().nextInt(moods.length)];
  }
}

class _DiaryAiResult {
  const _DiaryAiResult({required this.story, required this.mood});

  final String story;
  final String mood;
}
