import 'package:flutter/foundation.dart';

class AppAuthState extends ValueNotifier<String?> {
  AppAuthState._() : super(null);

  static final AppAuthState instance = AppAuthState._();

  bool get isAuthenticated => value != null && value!.isNotEmpty;

  void setToken(String? token) {
    if (value == token) {
      return;
    }
    value = token;
  }
}
