class UserSettings {
  final int dailyGoal;
  final String unit;
  final int reminderInterval;
  final bool reminderEnabled;
  final String sleepStartTime;
  final String sleepEndTime;

  UserSettings({
    this.dailyGoal = 2000,
    this.unit = 'ml',
    this.reminderInterval = 2,
    this.reminderEnabled = true,
    this.sleepStartTime = '22:00',
    this.sleepEndTime = '08:00',
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyGoal': dailyGoal,
      'unit': unit,
      'reminderInterval': reminderInterval,
      'reminderEnabled': reminderEnabled,
      'sleepStartTime': sleepStartTime,
      'sleepEndTime': sleepEndTime,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      dailyGoal: json['dailyGoal'] as int? ?? 2000,
      unit: json['unit'] as String? ?? 'ml',
      reminderInterval: json['reminderInterval'] as int? ?? 2,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      sleepStartTime: json['sleepStartTime'] as String? ?? '22:00',
      sleepEndTime: json['sleepEndTime'] as String? ?? '08:00',
    );
  }

  UserSettings copyWith({
    int? dailyGoal,
    String? unit,
    int? reminderInterval,
    bool? reminderEnabled,
    String? sleepStartTime,
    String? sleepEndTime,
  }) {
    return UserSettings(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      unit: unit ?? this.unit,
      reminderInterval: reminderInterval ?? this.reminderInterval,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      sleepEndTime: sleepEndTime ?? this.sleepEndTime,
    );
  }
}
