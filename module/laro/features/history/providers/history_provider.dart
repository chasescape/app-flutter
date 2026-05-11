import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/models/lash_history_item.dart';

class HistoryProvider extends ChangeNotifier {
  final GetIt getIt;
  late final SharedPreferences prefs;

  List<LashHistoryItem> _history = [];

  HistoryProvider(this.getIt) {
    prefs = getIt<SharedPreferences>();
    _loadHistory();
  }

  List<LashHistoryItem> get history => _history;

  void _loadHistory() {
    final historyJson = prefs.getStringList('history') ?? [];
    _history = historyJson.map((json) {
      return LashHistoryItem.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(json) as Map,
        ),
      );
    }).toList();
    if (_history.length > 30) {
      _history = _history.sublist(0, 30);
    }
    notifyListeners();
  }

  void deleteHistoryItem(String id) {
    _history.removeWhere((item) => item.id == id);
    _saveHistory();
  }

  void _saveHistory() {
    final historyJson = _history.map((item) => jsonEncode(item.toJson())).toList();
    prefs.setStringList('history', historyJson);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
  }
}
