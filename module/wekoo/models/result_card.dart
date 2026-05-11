class ResultCard {
  final String id;
  final DateTime createdAt;
  final int totalAmount;
  final int dailyGoal;
  final int progress;
  final int streak;
  final String aiEncouragement;
  final String template;

  ResultCard({
    required this.id,
    required this.createdAt,
    required this.totalAmount,
    required this.dailyGoal,
    required this.progress,
    required this.streak,
    required this.aiEncouragement,
    this.template = 'simple',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'totalAmount': totalAmount,
      'dailyGoal': dailyGoal,
      'progress': progress,
      'streak': streak,
      'aiEncouragement': aiEncouragement,
      'template': template,
    };
  }

  factory ResultCard.fromJson(Map<String, dynamic> json) {
    return ResultCard(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalAmount: json['totalAmount'] as int,
      dailyGoal: json['dailyGoal'] as int,
      progress: json['progress'] as int,
      streak: json['streak'] as int,
      aiEncouragement: json['aiEncouragement'] as String,
      template: json['template'] as String? ?? 'simple',
    );
  }

  ResultCard copyWith({
    String? id,
    DateTime? createdAt,
    int? totalAmount,
    int? dailyGoal,
    int? progress,
    int? streak,
    String? aiEncouragement,
    String? template,
  }) {
    return ResultCard(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      totalAmount: totalAmount ?? this.totalAmount,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      progress: progress ?? this.progress,
      streak: streak ?? this.streak,
      aiEncouragement: aiEncouragement ?? this.aiEncouragement,
      template: template ?? this.template,
    );
  }
}
