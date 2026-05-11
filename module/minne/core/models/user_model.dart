import 'package:flutter/foundation.dart';

/// User Model - Daily Happiness App
class UserModel {
  final String id;
  final String nickname;
  final String? avatar;
  final int coins;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.nickname,
    this.avatar,
    this.coins = 0,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? nickname,
    String? avatar,
    int? coins,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      coins: coins ?? this.coins,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'coins': coins,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      coins: json['coins'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// User State - Manages user data and authentication
class UserState extends ChangeNotifier {
  UserModel? _user;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  int get coins => _user?.coins ?? 0;

  void setUser(UserModel user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void updateCoins(int amount) {
    if (_user != null) {
      _user = _user!.copyWith(coins: _user!.coins + amount);
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  static final UserState _instance = UserState._internal();
  UserState._internal();
  factory UserState() => _instance;
}
