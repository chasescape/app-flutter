import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'interface.dart';
import 'data/models/snap_analysis.dart';
import 'services/coins_manager.dart';

class LightHandle {
  static SharedPreferences? _prefs;

  /// 对外暴露 prefs 供 CoinsManager 等服务使用
  static SharedPreferences? get prefs => _prefs;

  static final ValueNotifier<int> historyVersion = ValueNotifier(0);

  static Future<void> readyToInit() async {
    _prefs = await SharedPreferences.getInstance();
    _initDataFromStorage();
    CoinsManager.instance.loadFromStorage();
  }

  static Future<void> _initDataFromStorage() async {
    final i = Interface();
    final token = _prefs?.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      i.authToken = token;
    }
    final userId = _prefs?.getString('user_id');
    if (userId != null) {
      i.userId = userId;
    }
  }

  static Future<void> login() async {
    final i = Interface();
    await _prefs?.setString('auth_token', 'mock_token');
    i.authToken = 'mock_token';
  }

  static Future<void> logout() async {
    await _prefs?.remove('auth_token');
    await _prefs?.remove('user_id');
    onAuthTokenRemoved();
  }

  static Future<void> deleteAccount() async {
    clearAllData();
    await CoinsManager.instance.clear();
    await _prefs?.clear();
  }

  static Future<void> onAuthTokenRemoved() async {
    final i = Interface();
    i.authToken = null;
    i.userId = null;
    i.onAuthTokenRemoved();
  }

  static void clearAllData() {
    final i = Interface();
    i.authToken = null;
    i.userId = null;
    CoinsManager.instance.coinsNotifier.value = 0;
    i.onAuthTokenRemoved();
  }

  // --- Analysis History ---

  static Future<void> saveAnalysis(SnapAnalysis analysis) async {
    final history = getAnalysisHistory();
    history.insert(0, analysis);
    final jsonStr = jsonEncode(history.map((e) => e.toJson()).toList());
    await _prefs?.setString('analysis_history', jsonStr);
    historyVersion.value++;
  }

  static List<SnapAnalysis> getAnalysisHistory() {
    final jsonStr = _prefs?.getString('analysis_history');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
      return jsonList
          .map((e) => SnapAnalysis.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> deleteAnalysis(int index) async {
    final history = getAnalysisHistory();
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      final jsonStr = jsonEncode(history.map((e) => e.toJson()).toList());
      await _prefs?.setString('analysis_history', jsonStr);
      historyVersion.value++;
    }
  }

  _doShuffleActions() {}
}
