import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/storage/local_storage.dart';
import 'interface.dart';

class LightHandle {
  static Future<void> readyToInit() async {
    await setupServiceLocator();

    final storage = LocalStorage.instance;
    final i = Interface();
    i.authToken = storage.authToken;
    i.encryptKey = 'getAppConfig and set';
  }

  static Future<void> login() async {
    await Future.delayed(const Duration(seconds: 2));
    final storage = LocalStorage.instance;
    storage.authToken = 'mock_token';
    Interface().authToken = 'mock_token';
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    final i = Interface();
    i.authToken = null;

    final storage = LocalStorage.instance;
    storage.authToken = null;

    i.onAuthTokenRemoved();
  }

  static Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    final storage = LocalStorage.instance;
    await storage.clearDeleteAccountLocalData();
    await onAuthTokenRemoved();
  }

  static Future<void> onAuthTokenRemoved() async {
    final i = Interface();
    i.authToken = null;

    final storage = LocalStorage.instance;
    await storage.clearAll();

    i.onAuthTokenRemoved();
  }

  static Future<void> clearAllData() async {
    final i = Interface();
    i.authToken = null;

    final storage = LocalStorage.instance;
    await storage.clearAll();

    i.onAuthTokenRemoved();
  }

  static Future<void> mockLogin(BuildContext context) async {
    final storage = LocalStorage.instance;
    storage.authToken = 'mock_token';
    Interface().authToken = 'mock_token';
  }
}
