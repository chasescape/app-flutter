import 'package:flutter/foundation.dart';

mixin SingletonMixin<T> {
  static final Map<Type, dynamic> _instances = {};

  static T getInstance<T>(T Function() creator) {
    return _instances.putIfAbsent(T, creator) as T;
  }

  @visibleForTesting
  static void reset<T>() {
    _instances.remove(T);
  }

  @visibleForTesting
  static void resetAll() {
    _instances.clear();
  }

  static int get instanceCount => _instances.length;
}
