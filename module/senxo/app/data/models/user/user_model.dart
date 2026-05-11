/// 用户模型
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String? nickname;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.nickname,
    this.createdAt,
    this.updatedAt,
  });

  /// 从JSON创建用户模型
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      nickname: json['nickname']?.toString(),
      createdAt: json['created_at'] != null 
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
      updatedAt: json['updated_at'] != null 
        ? DateTime.tryParse(json['updated_at'].toString())
        : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'nickname': nickname,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 复制并修改部分字段
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    String? nickname,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, username: $username, email: $email, avatar: $avatar, nickname: $nickname}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}