part of 'user_data.dart';

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      coins: json['coins'] as int? ?? 0,
      freeUses: json['freeUses'] as int? ?? 0,
      nickname: json['nickname'] as String? ?? 'Guest',
      avatar: json['avatar'] as String? ?? '',
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'coins': instance.coins,
      'freeUses': instance.freeUses,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
    };
