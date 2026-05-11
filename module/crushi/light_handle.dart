import 'package:crushi/crushi/interface.dart';
import 'package:crushi/crushi/data/generated_history_store.dart';
import 'package:crushi/crushi/data/coins_wallet_store.dart';

class LightHandle {
  static Future<void> readyToInit() async {
    _initDataFromStorage();
    await GeneratedHistoryStore.I.ensureLoaded();
  }

  static Future<void> _initDataFromStorage() async {
    final i = Interface();
    // Mock: read token from storage
    // i.authToken = await SharedPreferences.getInstance()...;
    // i.encryptKey = ...;
  }

  static Future<void> logout() async {
    onAuthTokenRemoved();
  }

  static Future<void> login() async {}

  static Future<void> deleteAccount() async {
    await GeneratedHistoryStore.I.clearPersisted();
    await CoinsWalletStore().clear();
    clearAllData();
  }

  static Future<void> onAuthTokenRemoved() async {
    final i = Interface();
    i.authToken = null;
    // Clear SharedPreferences, local DB, cache, etc.
    i.onAuthTokenRemoved();
  }

  static void clearAllData() {
    final i = Interface();
    i.authToken = null;
    // Clear all persistent data
    i.onAuthTokenRemoved();
  }

  _doShuffleActions() {}
}
