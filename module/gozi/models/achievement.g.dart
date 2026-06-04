// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      imagePath: json['imagePath'] as String,
      category: json['category'] as String? ?? 'Daily Wins',
      note: json['note'] as String? ?? '',
      type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'tags': instance.tags,
      'imagePath': instance.imagePath,
      'category': instance.category,
      'note': instance.note,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AchievementTypeEnumMap = {
  AchievementType.learning: 'learning',
  AchievementType.fitness: 'fitness',
  AchievementType.work: 'work',
  AchievementType.creative: 'creative',
  AchievementType.life: 'life',
  AchievementType.other: 'other',
};
