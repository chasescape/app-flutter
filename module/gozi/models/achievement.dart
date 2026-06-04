import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

/// Achievement type enum
enum AchievementType {
  learning,
  fitness,
  work,
  creative,
  life,
  @JsonValue('other')
  other,
}

/// Achievement model
@JsonSerializable()
class Achievement {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String imagePath;
  @JsonKey(defaultValue: 'Daily Wins')
  final String category;
  @JsonKey(defaultValue: '')
  final String note;
  final AchievementType type;
  final DateTime createdAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.imagePath,
    required this.category,
    required this.note,
    required this.type,
    required this.createdAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  /// Create achievement from a selected photo or screenshot.
  factory Achievement.fromImage({
    required String imagePath,
    required String category,
    String note = '',
  }) {
    final cleanedCategory =
        category.trim().isEmpty ? 'Daily Wins' : category.trim();
    final cleanedNote = note.trim();
    final tag = '#${cleanedCategory.toLowerCase().replaceAll(' ', '')}';

    return Achievement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: cleanedCategory,
      description: cleanedNote,
      tags: [tag, '#progress'],
      imagePath: imagePath,
      category: cleanedCategory,
      note: cleanedNote,
      type: _typeForCategory(cleanedCategory),
      createdAt: DateTime.now(),
    );
  }

  static AchievementType _typeForCategory(String category) {
    final value = category.toLowerCase();
    if (value.contains('study') ||
        value.contains('learn') ||
        value.contains('school')) {
      return AchievementType.learning;
    }
    if (value.contains('fit') ||
        value.contains('gym') ||
        value.contains('run')) {
      return AchievementType.fitness;
    }
    if (value.contains('work') || value.contains('career')) {
      return AchievementType.work;
    }
    if (value.contains('creative') || value.contains('art')) {
      return AchievementType.creative;
    }
    if (value.contains('life') || value.contains('personal')) {
      return AchievementType.life;
    }
    return AchievementType.other;
  }

  /// Get type display name
  String get typeDisplayName {
    switch (type) {
      case AchievementType.learning:
        return 'Learning';
      case AchievementType.fitness:
        return 'Fitness';
      case AchievementType.work:
        return 'Work';
      case AchievementType.creative:
        return 'Creative';
      case AchievementType.life:
        return 'Life';
      case AchievementType.other:
        return 'Other';
    }
  }

  /// Copy with method
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    String? imagePath,
    String? category,
    String? note,
    AchievementType? type,
    DateTime? createdAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      note: note ?? this.note,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
