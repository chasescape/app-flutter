import 'user_model.dart';

/// 登录响应模型
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  /// 从JSON创建登录响应模型
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // 实际 API 响应结构：
    // {
    //   "code": 0,
    //   "data": {
    //     "token": "...",
    //     "userInfo": {...}
    //   }
    // }
    // 但传入的 json 已经是 data 部分
    
    return LoginResponse(
      accessToken: json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: int.tryParse(json['expiresIn']?.toString() ?? '0') ?? 0,
      user: UserModel.fromJson(json['userInfo'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }

  /// 复制并修改部分字段
  LoginResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    UserModel? user,
  }) {
    return LoginResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'LoginResponse{accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn, user: $user}';
  }
}