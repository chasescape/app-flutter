import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../../light_handle.dart';
import '../../../services/coins_manager.dart';

class ProfileProvider extends ChangeNotifier {
  late final CoinsManager coinsManager;

  ProfileProvider(GetIt getIt) {
    coinsManager = CoinsManager();
  }

  int get coins => coinsManager.currentCoins;

  Future<void> clearAllData() async {
    await LightHandle.clearAllData();
    notifyListeners();
  }
}
