import 'hairstyle_result.dart';

class UserData {
  final String userId;
  final int coinBalance;
  final int freeAttempts;
  final List<HairstyleResult> history;
  final DateTime? lastFreeAttemptDate;

  UserData({
    required this.userId,
    this.coinBalance = 0,
    this.freeAttempts = 0,
    this.history = const [],
    this.lastFreeAttemptDate,
  });

  bool get hasFreeAttempts => freeAttempts > 0;

  bool get canGenerate => coinBalance >= 99;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'coinBalance': coinBalance,
      'freeAttempts': freeAttempts,
      'history': history.map((h) => h.toJson()).toList(),
      'lastFreeAttemptDate': lastFreeAttemptDate?.toIso8601String(),
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'] as String,
      coinBalance: json['coinBalance'] as int? ?? 0,
      freeAttempts: json['freeAttempts'] as int? ?? 0,
      history: (json['history'] as List<dynamic>?)
              ?.map((h) => HairstyleResult.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      lastFreeAttemptDate: json['lastFreeAttemptDate'] != null
          ? DateTime.parse(json['lastFreeAttemptDate'] as String)
          : null,
    );
  }

  UserData copyWith({
    String? userId,
    int? coinBalance,
    int? freeAttempts,
    List<HairstyleResult>? history,
    DateTime? lastFreeAttemptDate,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      coinBalance: coinBalance ?? this.coinBalance,
      freeAttempts: freeAttempts ?? this.freeAttempts,
      history: history ?? this.history,
      lastFreeAttemptDate: lastFreeAttemptDate ?? this.lastFreeAttemptDate,
    );
  }
}
