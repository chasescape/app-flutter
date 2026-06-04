import 'package:flutter/foundation.dart';
import '../models/tone_record.dart';
import '../models/app_constants.dart';
import '../managers/coins_manager.dart';

class AppState extends ChangeNotifier {
  List<ToneRecord> _records = [];
  int _freeCredits = 3;
  bool _isLoading = false;

  List<ToneRecord> get records => _records;
  int get coinBalance => CoinsManager().balance;
  int get freeCredits => _freeCredits;
  bool get isLoading => _isLoading;

  List<ToneRecord> getRecentRecords(int limit) {
    final sorted = List<ToneRecord>.from(_records);
    sorted.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return sorted.take(limit).toList();
  }

  List<ToneRecord> getRecordsByScene(String sceneTag) {
    return _records.where((r) => r.sceneTag == sceneTag).toList();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void addRecord(ToneRecord record) {
    _records.add(record);
    notifyListeners();
  }

  void updateRecord(ToneRecord updated) {
    final index = _records.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _records[index] = updated;
      notifyListeners();
    }
  }

  void deleteRecord(String id) {
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  bool canCreateRecord() {
    return _freeCredits > 0 ||
        CoinsManager().isEnough(AppConstants.costPerRecord);
  }

  Future<bool> consumeForRecord() async {
    if (_freeCredits > 0) {
      _freeCredits--;
      notifyListeners();
      return true;
    } else if (CoinsManager().isEnough(AppConstants.costPerRecord)) {
      final success = await CoinsManager().subCoins(AppConstants.costPerRecord);
      if (success) {
        notifyListeners();
      }
      return success;
    }
    return false;
  }

  Future<void> addCoins(int amount) async {
    await CoinsManager().addCoins(amount);
    notifyListeners();
  }

  void setRecords(List<ToneRecord> records) {
    _records = records;
    notifyListeners();
  }

  void setCoinBalance(int balance) {
    CoinsManager().setBalanceSync(balance);
    notifyListeners();
  }

  void setFreeCredits(int credits) {
    _freeCredits = credits;
    notifyListeners();
  }

  void clearLocalData() {
    _records = [];
    _freeCredits = 3;
    _isLoading = false;
    notifyListeners();
  }
}
