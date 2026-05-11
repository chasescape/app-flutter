/// User data model
class UserData {
  final String? nickname;
  final String? avatar;
  final int coins;
  final int freeUses;
  final DateTime? createdAt;

  UserData({
    this.nickname,
    this.avatar,
    this.coins = 0,
    this.freeUses = 0,
    this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      coins: json['coins'] as int? ?? 0,
      freeUses: json['freeUses'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatar': avatar,
      'coins': coins,
      'freeUses': freeUses,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserData copyWith({
    String? nickname,
    String? avatar,
    int? coins,
    int? freeUses,
    DateTime? createdAt,
  }) {
    return UserData(
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      coins: coins ?? this.coins,
      freeUses: freeUses ?? this.freeUses,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasFreeUses => freeUses > 0;
  bool get canAffordRecord => coins >= 50 || hasFreeUses;
  bool get canAffordAnalysis => coins >= 100 || hasFreeUses;
  bool get canAffordRecommend => coins >= 30 || hasFreeUses;
}
