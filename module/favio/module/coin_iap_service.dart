import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favio_palette.dart';
import 'game_progress_store.dart';

const List<CoinPackOffer> kCoinPackCatalog = <CoinPackOffer>[
  CoinPackOffer(
    productCode: 'favio.va00',
    name: 'Favio Coin Vault0',
    price: 0.99,
    coins: 100,
    isPromotion: false,
    parentCode: '100009902',
    accentColor: Color(0xFFFFC857),
  ),
  CoinPackOffer(
    productCode: 'favio.va01',
    name: 'Favio Coin Vault1',
    price: 3.99,
    coins: 400,
    isPromotion: false,
    parentCode: '100039902',
    accentColor: Color(0xFF7DD3FC),
  ),
  CoinPackOffer(
    productCode: 'favio.va02',
    name: 'Favio Coin Vault2',
    price: 9.99,
    coins: 1200,
    isPromotion: false,
    parentCode: '100099902',
    accentColor: FavioPalette.brandGlow,
  ),
  CoinPackOffer(
    productCode: 'favio.va03',
    name: 'Favio Coin Vault3',
    price: 19.99,
    coins: 2500,
    isPromotion: false,
    parentCode: '100199902',
    accentColor: Color(0xFFFFC857),
  ),
  CoinPackOffer(
    productCode: 'favio.va04',
    name: 'Favio Coin Vault4',
    price: 49.99,
    coins: 7000,
    isPromotion: false,
    parentCode: '100499907',
    accentColor: Color(0xFF7DD3FC),
  ),
  CoinPackOffer(
    productCode: 'favio.va05',
    name: 'Favio Coin Vault5',
    price: 99.99,
    coins: 15000,
    isPromotion: false,
    parentCode: '100999910',
    accentColor: FavioPalette.brandBright,
  ),
  CoinPackOffer(
    productCode: 'favio.va06',
    name: 'Favio Coin Vault6',
    price: 0.99,
    coins: 299,
    isPromotion: true,
    originalPrice: 2.99,
    parentCode: '100009907',
    accentColor: FavioPalette.brandGlow,
    badge: 'DEAL',
  ),
  CoinPackOffer(
    productCode: 'favio.va07',
    name: 'Favio Coin Vault7',
    price: 1.99,
    coins: 498,
    isPromotion: true,
    originalPrice: 4.99,
    parentCode: '100019900',
    accentColor: Color(0xFF7DD3FC),
    badge: 'HOT',
  ),
  CoinPackOffer(
    productCode: 'favio.va08',
    name: 'Favio Coin Vault8',
    price: 4.99,
    coins: 1199,
    isPromotion: true,
    originalPrice: 9.99,
    parentCode: '100049904',
    accentColor: Color(0xFFFFC857),
    badge: 'HOT',
  ),
  CoinPackOffer(
    productCode: 'favio.va09',
    name: 'Favio Coin Vault9',
    price: 11.99,
    coins: 2399,
    isPromotion: true,
    originalPrice: 18.99,
    parentCode: '100119907',
    accentColor: Color(0xFFFF5D73),
    badge: 'DEAL',
  ),
  CoinPackOffer(
    productCode: 'favio.va10',
    name: 'Favio Coin Vault10',
    price: 34.99,
    coins: 6999,
    isPromotion: true,
    originalPrice: 49.99,
    parentCode: '100349904',
    accentColor: Color(0xFF7DD3FC),
    badge: 'BEST',
  ),
  CoinPackOffer(
    productCode: 'favio.va11',
    name: 'Favio Coin Vault11',
    price: 99.99,
    coins: 17999,
    isPromotion: true,
    originalPrice: 119.99,
    parentCode: '100999906',
    accentColor: FavioPalette.brandBright,
    badge: 'MAX',
  ),
  CoinPackOffer(
    productCode: 'favio.va12',
    name: 'Favio Coin Vault12',
    price: 4.99,
    coins: 499,
    isPromotion: false,
    parentCode: '282312',
    accentColor: Color(0xFFFFC857),
  ),
  CoinPackOffer(
    productCode: 'favio.va13',
    name: 'Favio Coin Vault13',
    price: 6.99,
    coins: 699,
    isPromotion: false,
    parentCode: '280013',
    accentColor: Color(0xFF7DD3FC),
  ),
];

class CoinPackOffer {
  const CoinPackOffer({
    required this.productCode,
    required this.name,
    required this.price,
    required this.coins,
    required this.isPromotion,
    required this.parentCode,
    required this.accentColor,
    this.originalPrice,
    this.badge,
  });

  final String productCode;
  final String name;
  final double price;
  final int coins;
  final bool isPromotion;
  final String parentCode;
  final Color accentColor;
  final double? originalPrice;
  final String? badge;

  String get fallbackPriceLabel => '\$${price.toStringAsFixed(2)}';

  String? get originalPriceLabel =>
      originalPrice == null ? null : '\$${originalPrice!.toStringAsFixed(2)}';

  String get packLabel => isPromotion ? 'LIMITED DEAL' : 'STANDARD PACK';
}

class CoinPurchaseNotice {
  const CoinPurchaseNotice({
    required this.id,
    required this.message,
    required this.isError,
  });

  final int id;
  final String message;
  final bool isError;
}

class CoinIapService extends ChangeNotifier {
  CoinIapService._();

  static final CoinIapService instance = CoinIapService._();
  static const String _deliveredPurchasesKey =
      'coin_iap_delivered_purchases_v1';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  SharedPreferences? _prefs;
  Map<String, ProductDetails> _productsById = <String, ProductDetails>{};
  Set<String> _notFoundProductIds = <String>{};
  Set<String> _deliveredPurchaseKeys = <String>{};

  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isStoreAvailable = false;
  bool _isLoadingProducts = false;
  bool _isPurchasePending = false;
  String? _activeProductId;
  String? _queryError;
  int _noticeSeed = 0;
  CoinPurchaseNotice? _latestNotice;

  bool get isInitialized => _isInitialized;
  bool get isStoreAvailable => _isStoreAvailable;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isPurchasePending => _isPurchasePending;
  String? get activeProductId => _activeProductId;
  String? get queryError => _queryError;
  Set<String> get notFoundProductIds => _notFoundProductIds;
  CoinPurchaseNotice? get latestNotice => _latestNotice;
  static List<CoinPackOffer> get catalog => kCoinPackCatalog;

  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;
    _prefs = await SharedPreferences.getInstance();
    _deliveredPurchaseKeys =
        (_prefs?.getStringList(_deliveredPurchasesKey) ?? const <String>[])
            .toSet();

    _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () {
        _purchaseSubscription?.cancel();
        _purchaseSubscription = null;
      },
      onError: (Object error) {
        _clearPendingPurchase(notify: false);
        _emitNotice(
          'Purchase service encountered an unexpected error.',
          isError: true,
        );
      },
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(_CoinPaymentQueueDelegate());
    }

    _isInitialized = true;
    _isInitializing = false;
    notifyListeners();
    await refreshProducts();
  }

  Future<void> clearLocalData() async {
    _deliveredPurchaseKeys.clear();
    await _prefs?.remove(_deliveredPurchasesKey);
    _clearPendingPurchase(notify: false);
    _latestNotice = null;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    _isLoadingProducts = true;
    _queryError = null;
    notifyListeners();

    try {
      final bool available = await _inAppPurchase.isAvailable();
      _isStoreAvailable = available;

      if (!available) {
        _productsById = <String, ProductDetails>{};
        _notFoundProductIds = <String>{};
        _isLoadingProducts = false;
        notifyListeners();
        return;
      }

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(
        kCoinPackCatalog
            .map((CoinPackOffer offer) => offer.productCode)
            .toSet(),
      );

      _productsById = <String, ProductDetails>{
        for (final ProductDetails product in response.productDetails)
          product.id: product,
      };
      _notFoundProductIds = response.notFoundIDs.toSet();
      _queryError = response.error?.message;
    } catch (_) {
      _queryError = 'Unable to load App Store products right now.';
      _productsById = <String, ProductDetails>{};
      _notFoundProductIds = <String>{};
    }

    _isLoadingProducts = false;
    notifyListeners();
  }

  ProductDetails? productFor(CoinPackOffer pack) =>
      _productsById[pack.productCode];

  bool isPackAvailable(CoinPackOffer pack) => productFor(pack) != null;

  bool isPackBusy(CoinPackOffer pack) =>
      _isPurchasePending && _activeProductId == pack.productCode;

  Future<void> purchasePack(CoinPackOffer pack) async {
    if (_isPurchasePending) {
      _emitNotice(
        'Another purchase is already in progress.',
        isError: true,
      );
      return;
    }

    ProductDetails? product = productFor(pack);
    if (product == null) {
      await refreshProducts();
      product = productFor(pack);
    }

    if (!_isStoreAvailable || product == null) {
      _emitNotice(
        'This coin pack is not available in the App Store yet.',
        isError: true,
      );
      return;
    }

    _activeProductId = pack.productCode;
    _isPurchasePending = true;
    notifyListeners();

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      final bool sent = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      if (!sent) {
        _clearPendingPurchase();
        _emitNotice(
          'Unable to start the App Store purchase. Please try again.',
          isError: true,
        );
      }
    } catch (_) {
      _clearPendingPurchase();
      _emitNotice(
        'Unable to open the App Store purchase flow right now.',
        isError: true,
      );
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      await _handlePurchaseUpdate(purchaseDetails);
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _activeProductId = purchaseDetails.productID;
        _isPurchasePending = true;
        notifyListeners();
        break;
      case PurchaseStatus.error:
        _clearPendingPurchase();
        _emitNotice(
          purchaseDetails.error?.message ?? 'Purchase failed.',
          isError: true,
        );
        break;
      case PurchaseStatus.canceled:
        _clearPendingPurchase();
        _emitNotice(
          'Purchase cancelled.',
          isError: false,
        );
        break;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final bool delivered = await _deliverProduct(purchaseDetails);
        _clearPendingPurchase();
        if (delivered) {
          final CoinPackOffer? pack =
              _packForProductId(purchaseDetails.productID);
          if (pack != null) {
            _emitNotice(
              '+${pack.coins} coins added to your balance.',
              isError: false,
            );
          }
        }
        break;
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  Future<bool> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final CoinPackOffer? pack = _packForProductId(purchaseDetails.productID);
    if (pack == null) {
      _emitNotice(
        'Unknown coin pack received from the App Store.',
        isError: true,
      );
      return false;
    }

    final String purchaseKey = _purchaseKeyFor(purchaseDetails);
    if (_deliveredPurchaseKeys.contains(purchaseKey)) {
      return false;
    }

    // TODO: Replace this local delivery path with server-side receipt validation.
    final GameProgressStore store = GameProgressStore.instance;
    store.setCoins(store.coins + pack.coins);

    _deliveredPurchaseKeys.add(purchaseKey);
    await _prefs?.setStringList(
      _deliveredPurchasesKey,
      _deliveredPurchaseKeys.toList(),
    );
    return true;
  }

  CoinPackOffer? _packForProductId(String productId) {
    for (final CoinPackOffer pack in kCoinPackCatalog) {
      if (pack.productCode == productId) {
        return pack;
      }
    }
    return null;
  }

  String _purchaseKeyFor(PurchaseDetails purchaseDetails) {
    final String verificationBlob =
        purchaseDetails.verificationData.serverVerificationData.isNotEmpty
            ? purchaseDetails.verificationData.serverVerificationData
            : purchaseDetails.verificationData.localVerificationData;
    return <String>[
      purchaseDetails.productID,
      purchaseDetails.purchaseID ?? '',
      purchaseDetails.transactionDate ?? '',
      verificationBlob,
    ].join('::');
  }

  void _clearPendingPurchase({bool notify = true}) {
    _activeProductId = null;
    _isPurchasePending = false;
    if (notify) {
      notifyListeners();
    }
  }

  void _emitNotice(String message, {required bool isError}) {
    _latestNotice = CoinPurchaseNotice(
      id: ++_noticeSeed,
      message: message,
      isError: isError,
    );
    notifyListeners();
  }
}

class _CoinPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
