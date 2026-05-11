import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/ai_service.dart';
import '../emotion/emotion_logic.dart';
import '../emotion/emotion_models.dart';

class JournalLogic extends GetxController {
  JournalLogic({
    required this.emotionLogic,
    this.aiService,
  });

  final EmotionLogic emotionLogic;
  final AiService? aiService;

  final insights = <Insight>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadInsights();
  }

  List<WeekMoodData> get weekData => emotionLogic.getWeekData();

  bool get hasData => weekData.isNotEmpty;

  Future<void> _loadInsights() async {
    final entriesWithImages = emotionLogic.entries
        .where((entry) => entry.imagePath != null)
        .toList();

    final displayCount = entriesWithImages.isEmpty ? 0 : entriesWithImages.length.clamp(1, 3);
    if (displayCount == 0) {
      insights.assignAll([]);
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      if (aiService == null) {
        insights.assignAll(_fallbackInsights(displayCount));
        return;
      }
      final prompt = _buildInsightsPrompt(displayCount);
      final response = await aiService!.generateStory(
        prompt: prompt,
        model: 'gpt-4o-mini',
        temperature: 0.6,
        maxTokens: 900,
        systemPrompt: _insightSystemPrompt,
      );

      final parsed = _parseInsights(response, displayCount);
      insights.assignAll(parsed);
    } catch (e) {
      error.value = 'AI insights unavailable. Showing template.';
      insights.assignAll(_fallbackInsights(displayCount));
    } finally {
      isLoading.value = false;
    }
  }

  List<Insight> _fallbackInsights(int displayCount) {
    final entriesWithImages = emotionLogic.entries
        .where((entry) => entry.imagePath != null)
        .toList();

    final allInsights = [
      Insight(
        title: 'Your Peak Days',
        description: 'You feel best on weekends and Thursdays',
        gradient: const [Color(0xFFFFC857), Color(0xFFFF7A4B)],
        imageUrl:
            'https://images.unsplash.com/photo-1563718641734-db1748886571?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        details:
            'Based on your recent entries, you seem to feel best toward the end of the week. Consider planning meaningful activities on those days. Notice what helps (rest, social time, or personal space) and try to sprinkle those elements into other days.',
        tips: [
          'Plan a small reward on peak days',
          'Use Guided Meditation to keep momentum',
          'Try Deep Breathing before busy blocks',
        ],
        userImagePath: entriesWithImages.isNotEmpty ? entriesWithImages[0].imagePath : null,
      ),
      Insight(
        title: 'Emotional Patterns',
        description: 'Short morning resets can lift the day',
        gradient: const [Color(0xFF9B7EF6), Color(0xFFFF7AD9)],
        imageUrl:
            'https://images.unsplash.com/photo-1501597301489-8b75b675ba0a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        details:
            'Your notes suggest that a calm start helps your mood later. A brief reset in the morning can make the rest of the day feel more manageable. Keep it simple and consistent.',
        tips: [
          'Do a 2-minute Deep Breathing set',
          'Add a short Guided Meditation',
          'Write one intention in your journal',
        ],
        userImagePath: entriesWithImages.length > 1 ? entriesWithImages[1].imagePath : null,
      ),
      Insight(
        title: 'Growth Trend',
        description: 'Your check-ins are building steadiness',
        gradient: const [Color(0xFFFF6BC8), Color(0xFFE945E5)],
        imageUrl:
            'https://images.unsplash.com/photo-1766454920560-9aeb58f9389e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        details:
            'Consistency is paying off. Regular check-ins help you notice patterns and respond sooner. Keep using small tools to stay grounded, especially on busy days.',
        tips: [
          'Track one quick entry daily',
          'Use Expression Techniques when tense',
          'Celebrate small improvements',
        ],
        userImagePath: entriesWithImages.length > 2 ? entriesWithImages[2].imagePath : null,
      ),
    ];

    return allInsights.take(displayCount).toList();
  }

  String _buildInsightsPrompt(int count) {
    final summary = _buildSummary();
    return '''
Generate $count short AI insights in JSON only.

Constraints:
- Suggestions only. No medical or diagnostic advice.
- Recommend our in-app tools when possible: Deep Breathing, Guided Meditation, Expression Techniques.
- Match this template per insight:
  title: 2-4 words
  description: 1 short sentence
  details: 3-5 sentences, supportive and practical
  tips: 3 short bullet-like strings

User summary:
$summary

Output JSON schema:
{"insights":[{"title":"","description":"","details":"","tips":["","",""]}]}
''';
  }

  String _buildSummary() {
    final entries = emotionLogic.entries;
    if (entries.isEmpty) {
      return 'No entries yet. Provide general insights about starting a simple routine.';
    }

    final recent = entries.take(10).toList();
    final avgIntensity =
        recent.map((e) => e.intensity).reduce((a, b) => a + b) / recent.length;
    final emotionCounts = <EmotionType, int>{};
    for (final entry in recent) {
      emotionCounts.update(entry.emotion, (v) => v + 1, ifAbsent: () => 1);
    }
    final topEmotion = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return 'Recent entries: ${recent.length}. '
        'Average intensity: ${avgIntensity.toStringAsFixed(1)}/10. '
        'Top emotion: ${EmotionPalette.label(topEmotion.first.key)}. '
        'Notes length avg: ${_averageNoteLength(recent)} characters.';
  }

  int _averageNoteLength(List<EmotionEntry> entries) {
    if (entries.isEmpty) return 0;
    final total = entries
        .map((e) => e.note.trim().length)
        .reduce((a, b) => a + b);
    return (total / entries.length).round();
  }

  List<Insight> _parseInsights(String response, int maxCount) {
    final cleaned = response
        .trim()
        .replaceAll(RegExp(r'^```json', multiLine: true), '')
        .replaceAll(RegExp(r'^```', multiLine: true), '')
        .replaceAll(RegExp(r'```$', multiLine: true), '')
        .trim();
    final data = jsonDecode(cleaned);
    if (data is! Map || data['insights'] is! List) {
      throw Exception('Invalid AI insights response');
    }

    final list = (data['insights'] as List).take(maxCount).toList();
    final gradients = [
      const [Color(0xFFFFC857), Color(0xFFFF7A4B)],
      const [Color(0xFF9B7EF6), Color(0xFFFF7AD9)],
      const [Color(0xFFFF6BC8), Color(0xFFE945E5)],
    ];
    final imageUrls = [
      'https://images.unsplash.com/photo-1563718641734-db1748886571?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      'https://images.unsplash.com/photo-1501597301489-8b75b675ba0a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      'https://images.unsplash.com/photo-1766454920560-9aeb58f9389e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    ];

    return list.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value as Map;
      return Insight(
        title: (item['title'] ?? '').toString(),
        description: (item['description'] ?? '').toString(),
        gradient: gradients[index % gradients.length],
        imageUrl: imageUrls[index % imageUrls.length],
        details: (item['details'] ?? '').toString(),
        tips: (item['tips'] is List)
            ? (item['tips'] as List).map((e) => e.toString()).toList()
            : <String>[],
      );
    }).toList();
  }
}

const _insightSystemPrompt = '''
You are a wellness journaling assistant inside a mobile app.
Only provide supportive, non-medical suggestions.
Do not diagnose, treat, or give medical advice.
Avoid crisis guidance. Keep tone calm and encouraging.
''';
