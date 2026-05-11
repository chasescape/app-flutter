import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoginEvent extends AuthEvent {
  const LoginEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class DeleteAccountEvent extends AuthEvent {
  const DeleteAccountEvent();
}

class UpdateCoinsEvent extends AuthEvent {
  final int coins;

  const UpdateCoinsEvent(this.coins);

  @override
  List<Object?> get props => [coins];
}
