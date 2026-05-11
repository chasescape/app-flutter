import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contact_coins.dart';
import '../../../services/purchase_service.dart';
import '../../../services/coins_manager.dart';

class CoinProvider with ChangeNotifier {
  final GetIt getIt;
  late final SharedPreferences prefs;
  late final CoinsManager coinsManager;
  late final PurchaseService purchaseService;

  List<Contact575CoinProduct> _products = [];

  CoinProvider(this.getIt) {
    prefs = getIt<SharedPreferences>();
    coinsManager = CoinsManager();
    purchaseService = PurchaseService();
    _initProducts();
  }

  int get coins => coinsManager.currentCoins;
  ValueNotifier<int> get coinsNotifier => coinsManager.coinsNotifier;
  List<Contact575CoinProduct> get products => _products;

  void _initProducts() {
    _products = Privatised236CoinProductData.allProductsGrouped;
  }

  Future<void> initializePurchaseService() async {
    await purchaseService.initialize(
      onCoinsAdded: (coins) async {
        await coinsManager.addCoins(coins);
        notifyListeners();
      },
    );
  }

  Future<bool> purchaseCoins(String productId) async {
    final product = _products.firstWhere(
      (p) => p.code == productId,
      orElse: () => _products.first,
    );

    final completer = Completer<bool>();

    await purchaseService.executePurchase(
      product.code,
      product.exchangeCoin,
      (success, message) {
        if (!completer.isCompleted) {
          completer.complete(success);
        }
      },
    );

    return completer.future;
  }

  @override
  void dispose() {
    purchaseService.dispose();
    super.dispose();
  }
}
