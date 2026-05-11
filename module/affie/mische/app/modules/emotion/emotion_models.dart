import 'package:flutter/material.dart';

enum EmotionType {
  happy,
  sad,
  calm,
  anxious,
  angry,
  excited,
}

class EmotionEntry {
  EmotionEntry({
    required this.id,
    required this.emotion,
    required this.intensity,
    required this.note,
    required this.timestamp,
    this.imagePath,
    this.aiStoryTitle,
    this.aiStoryContent,
  });

  final String id;
  final EmotionType emotion;
  final int intensity;
  final String note;
  final DateTime timestamp;
  final String? imagePath; // 用户上传的照片路径
  final String? aiStoryTitle; // AI 生成的故事标题
  final String? aiStoryContent; // AI 生成的故事内容

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emotion': emotion.name,
      'intensity': intensity,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
      'aiStoryTitle': aiStoryTitle,
      'aiStoryContent': aiStoryContent,
    };
  }

  factory EmotionEntry.fromJson(Map<String, dynamic> json) {
    return EmotionEntry(
      id: json['id'] as String? ?? '',
      emotion: EmotionType.values.firstWhere(
        (e) => e.name == (json['emotion'] as String? ?? 'happy'),
        orElse: () => EmotionType.happy,
      ),
      intensity: json['intensity'] as int? ?? 1,
      note: json['note'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      imagePath: json['imagePath'] as String?,
      aiStoryTitle: json['aiStoryTitle'] as String?,
      aiStoryContent: json['aiStoryContent'] as String?,
    );
  }
}

class WeekMoodData {
  WeekMoodData({
    required this.label,
    required this.average,
    required this.trend,
    required this.entries,
  });

  final String label;
  final double average;
  final MoodTrend trend;
  final int entries;
}

enum MoodTrend { up, down, stable }

class EmotionPalette {
  static const Map<EmotionType, List<Color>> gradients = {
    EmotionType.happy: [Color(0xFFFFC857), Color(0xFFFF7A4B)],
    EmotionType.sad: [Color(0xFF9B7EF6), Color(0xFFFF7AD9)],
    EmotionType.calm: [Color(0xFF42E5C0), Color(0xFF2DB6A8)],
    EmotionType.anxious: [Color(0xFFFF9A3D), Color(0xFFFF4D4D)],
    EmotionType.angry: [Color(0xFFFF5B5B), Color(0xFFFF3F6C)],
    EmotionType.excited: [Color(0xFFFF6BC8), Color(0xFFE945E5)],
  };

  static String label(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.happy:
        return 'Happy';
      case EmotionType.sad:
        return 'Sad';
      case EmotionType.calm:
        return 'Calm';
      case EmotionType.anxious:
        return 'Anxious';
      case EmotionType.angry:
        return 'Angry';
      case EmotionType.excited:
        return 'Excited';
    }
  }

  static IconData icon(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.happy:
        return Icons.sentiment_very_satisfied;
      case EmotionType.sad:
        return Icons.sentiment_very_dissatisfied;
      case EmotionType.calm:
        return Icons.favorite;
      case EmotionType.anxious:
        return Icons.trending_up;
      case EmotionType.angry:
        return Icons.sentiment_very_dissatisfied;
      case EmotionType.excited:
        return Icons.emoji_emotions;
    }
  }
}

class EmotionDetailArgs {
  EmotionDetailArgs({required this.entry, required this.totalEntries});

  final EmotionEntry entry;
  final int totalEntries;
}

class Insight {
  Insight({
    required this.title,
    required this.description,
    required this.gradient,
    required this.imageUrl,
    required this.details,
    required this.tips,
    this.userImagePath, // 用户上传的照片路径
  });

  final String title;
  final String description;
  final List<Color> gradient;
  final String imageUrl;
  final String details;
  final List<String> tips;
  final String? userImagePath;
}
