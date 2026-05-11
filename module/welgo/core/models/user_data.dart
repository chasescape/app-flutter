import 'package:json_annotation/json_annotation.dart';

part 'user_data.g.dart';

@JsonSerializable()
class UserData {
  final int coins;
  final int freeUses;
  final String nickname;
  final String avatar;

  const UserData({
    this.coins = 0,
    this.freeUses = 0,
    this.nickname = 'Welgo',
    this.avatar = '',
  });

  UserData copyWith({
    int? coins,
    int? freeUses,
    String? nickname,
    String? avatar,
  }) {
    return UserData(
      coins: coins ?? this.coins,
      freeUses: freeUses ?? this.freeUses,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
