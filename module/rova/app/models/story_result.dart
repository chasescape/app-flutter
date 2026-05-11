class StoryResult {
  const StoryResult({
    required this.title,
    required this.story,
    required this.characterName,
    required this.characterTraits,
    required this.setting,
    required this.mood,
    required this.category,
    required this.readTime,
  });

  final String title;
  final String story;
  final String characterName;
  final List<String> characterTraits;
  final String setting;
  final String mood;
  final String category;
  final String readTime;

  factory StoryResult.fromJson(Map<String, dynamic> json) {
    return StoryResult(
      title: (json['title'] as String?)?.trim() ?? '',
      story: (json['story'] as String?)?.trim() ?? '',
      characterName: (json['character_name'] as String?)?.trim() ?? '',
      characterTraits: (json['character_traits'] as List?)
              ?.whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const <String>[],
      setting: (json['setting'] as String?)?.trim() ?? '',
      mood: (json['mood'] as String?)?.trim() ?? '',
      category: (json['category'] as String?)?.trim() ?? '',
      readTime: (json['read_time'] as String?)?.trim() ?? '',
    );
  }
}

