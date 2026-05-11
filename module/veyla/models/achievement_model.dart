class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class AchievementDefinitions {
  static final List<Achievement> all = [
    Achievement(
      id: 'first_step',
      title: 'First Step',
      description: 'Complete your first wake-up check-in',
      emoji: '👣',
    ),
    Achievement(
      id: 'streak_3',
      title: '3-Day Streak',
      description: 'Check in for 3 consecutive days',
      emoji: '🔥',
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Check in for 7 consecutive days',
      emoji: '⚔️',
    ),
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Check in before 6:00 AM five times',
      emoji: '🐦',
    ),
    Achievement(
      id: 'morning_master',
      title: 'Morning Master',
      description: 'Complete 30 check-ins total',
      emoji: '👑',
    ),
  ];
}
