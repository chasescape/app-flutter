/// User Model
class UserModel {
  final String id;
  final String username;
  final String? avatar;
  final int? coinBalance;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    this.avatar,
    this.coinBalance,
    this.createdAt,
  });

  factory UserModel.mock() {
    return UserModel(
      id: 'mock_user_id',
      username: 'Tavia',
      avatar: null,
      coinBalance: 100,
      createdAt: DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? avatar,
    int? coinBalance,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      coinBalance: coinBalance ?? this.coinBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
