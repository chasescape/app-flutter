import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final int coins;
  final String? username;
  final String? avatar;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.coins = 0,
    this.username,
    this.avatar,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    int? coins,
    String? username,
    String? avatar,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      coins: coins ?? this.coins,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  List<Object?> get props => [
        isAuthenticated,
        isLoading,
        errorMessage,
        coins,
        username,
        avatar,
      ];
}
