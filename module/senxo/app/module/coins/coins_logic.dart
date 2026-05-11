import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants/api_constants.dart';
import '../../core/services/coin_service.dart';
import '../../core/services/encrypt_service.dart';
import '../../data/providers/api_provider.dart';

class CoinsLogic extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final EncryptService _encryptService = Get.find<EncryptService>();
  final CoinService _coinService = Get.find<CoinService>();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  RxInt selectedPackage = (-1).obs;
  RxBool showDiscount = false.obs;
  RxBool isPurchasing = false.obs;

  /// Whether app config has been loaded (getAppConfig)
  RxBool configLoaded = false.obs;

  /// Product list (load after getAppConfig then getGoodsList)
  final RxList<Map<String, dynamic>> goodsList = <Map<String, dynamic>>[].obs;

  /// Loading/error text for View display
  RxBool isLoadingGoods = true.obs;
  RxString loadGoodsError = ''.obs;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // Static product data
  final List<Map<String, dynamic>> _regularPackages = [
    {
      'code': '265400',
      'name': 'Senxo Coin Set 0',
      'description': '99 coins - Base Pack',
      'price': 0.99,
      'coins': 99,
      'type': 'Regular',
    },
    {
      'code': '265401',
      'name': 'Senxo Coin Set 1',
      'description': '400 coins - Base Pack',
      'price': 3.99,
      'coins': 400,
      'type': 'Regular',
    },
    {
      'code': '265412',
      'name': 'Senxo Coin Set 12',
      'description': 'Base Pack',
      'price': 4.99,
      'coins': 500,
      'type': 'Regular',
    },
    {
      'code': '265413',
      'name': 'Senxo Coin Set 13',
      'description': 'Base Pack',
      'price': 6.99,
      'coins': 700,
      'type': 'Regular',
    },
    {
      'code': '265402',
      'name': 'Senxo Coin Set 2',
      'description': '1000 coins - Base Pack',
      'price': 9.99,
      'coins': 1000,
      'type': 'Regular',
    },
    {
      'code': '265403',
      'name': 'Senxo Coin Set 3',
      'description': '2400 coins - Base Pack',
      'price': 19.99,
      'coins': 2400,
      'type': 'Regular',
    },
    {
      'code': '265404',
      'name': 'Senxo Coin Set 4',
      'description': '7000 coins - Base Pack',
      'price': 49.99,
      'coins': 7000,
      'type': 'Regular',
    },
    {
      'code': '265405',
      'name': 'Senxo Coin Set 5',
      'description': '15000 coins - Base Pack',
      'price': 99.99,
      'coins': 15000,
      'type': 'Regular',
    },
  ];

  final List<Map<String, dynamic>> _promotionPackages = [
    {
      'code': '265406',
      'name': 'Senxo Coin Set 6',
      'description': '299 coins - Limited Promotion',
      'price': 0.99,
      'coins': 299,
      'type': 'Promotion',
      'originalPrice': 2.99,
      'discount': '67% OFF',
    },
    {
      'code': '265407',
      'name': 'Senxo Coin Set 7',
      'description': '748 coins - Limited Promotion',
      'price': 2.99,
      'coins': 748,
      'type': 'Promotion',
      'originalPrice': 7.48,
      'discount': '60% OFF',
    },
    {
      'code': '265408',
      'name': 'Senxo Coin Set 8',
      'description': '1200 coins - Limited Promotion',
      'price': 4.99,
      'coins': 1200,
      'type': 'Promotion',
      'originalPrice': 11.99,
      'discount': '58% OFF',
    },
    {
      'code': '265409',
      'name': 'Senxo Coin Set 9',
      'description': '2600 coins - Limited Promotion',
      'price': 12.99,
      'coins': 2600,
      'type': 'Promotion',
      'originalPrice': 25.99,
      'discount': '50% OFF',
    },
    {
      'code': '265410',
      'name': 'Senxo Coin Set 10',
      'description': '6999 coins - Limited Promotion',
      'price': 34.99,
      'coins': 6999,
      'type': 'Promotion',
      'originalPrice': 69.99,
      'discount': '50% OFF',
    },
    {
      'code': '265411',
      'name': 'Senxo Coin Set 11',
      'description': '17888 coins - Limited Promotion',
      'price': 99.99,
      'coins': 17888,
      'type': 'Promotion',
      'originalPrice': 178.88,
      'discount': '44% OFF',
    },
  ];

  // Test mode switch - set to false for real Apple payment, true for simulation
  static const bool _isTestMode = false;

  // Get current displayed product list
  List<Map<String, dynamic>> get currentPackages {
    return showDiscount.value ? _promotionPackages : _regularPackages;
  }

  @override
  void onInit() {
    super.onInit();
    // No longer call _loadConfigThenGoods, use static data
    _listenPurchaseStream();
    isLoadingGoods.value = false;
  }

  /// First call getAppConfig (ensure encryptKey exists), then call coin product API getGoodsList
  Future<void> _loadConfigThenGoods() async {
    isLoadingGoods.value = true;
    loadGoodsError.value = '';

    try {
      // First call EncryptService.getAppConfig() to ensure encryptKey exists
      print('CoinsLogic: Starting to get configuration...');
      if (_encryptService.needRefreshConfig()) {
        final configOk = await _encryptService.getAppConfig();
        if (!configOk) {
          loadGoodsError.value = 'Failed to get configuration, please try again later';
          isLoadingGoods.value = false;
          return;
        }
        print('CoinsLogic: getAppConfig successful, encryptKey obtained');
      } else {
        print('CoinsLogic: encryptKey already exists');
      }
      configLoaded.value = true;

      // Then call product list API (will use encryption)
      print('CoinsLogic: Starting to get product list...');
      final goodsRes = await _apiProvider.getGoodsList(page: 1, pageSize: 20);
      if (goodsRes.isError) {
        loadGoodsError.value = goodsRes.message ?? ApiConstants.unknownError;
        print('CoinsLogic: Failed to get product list: ${goodsRes.message}');
      } else if (goodsRes.data != null) {
        goodsList.assignAll(goodsRes.data!);
        print('CoinsLogic: Successfully got product list, total ${goodsRes.data!.length} products');
      }
    } catch (e) {
      loadGoodsError.value = e.toString();
      print('CoinsLogic: Failed to load products: $e');
    } finally {
      isLoadingGoods.value = false;
    }
  }

  void _listenPurchaseStream() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(_onPurchaseUpdate);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails details in purchaseDetailsList) {
      print('CoinsLogic: Received purchase update, status: ${details.status}, product: ${details.productID}');
      
      if (details.status == PurchaseStatus.purchased) {
        print('CoinsLogic: Purchase successful');
        
        // Complete purchase
        if (details.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(details);
          print('CoinsLogic: Purchase confirmation completed');
        }
        
        isPurchasing.value = false;
        
        // Automatically add corresponding coins after successful purchase
        _addCoinsForProduct(details.productID);
        
        selectedPackage.value = -1;
        
        // Get.snackbar(
        //   'Purchase Successful', 
        //   'Coins have been added to your account!',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green.withOpacity(0.8),
        //   colorText: Colors.white,
        // );
        
      } else if (details.status == PurchaseStatus.error) {
        print('CoinsLogic: Purchase failed: ${details.error?.message}');
        isPurchasing.value = false;
        // Get.snackbar(
        //   'Purchase Failed',
        //   details.error?.message ?? 'Unknown error occurred',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.red.withOpacity(0.8),
        //   colorText: Colors.white,
        // );
        
      } else if (details.status == PurchaseStatus.canceled) {
        print('CoinsLogic: Purchase canceled');
        isPurchasing.value = false;
        // Get.snackbar(
        //   'Purchase Canceled',
        //   'Purchase was canceled by user',
        //   snackPosition: SnackPosition.BOTTOM,
        // );
        
      } else if (details.status == PurchaseStatus.pending) {
        print('CoinsLogic: Purchase pending');
        // Keep isPurchasing as true, show loading state
        
      } else {
        print('CoinsLogic: Unknown purchase status: ${details.status}');
      }
    }
  }

  /// Add corresponding coins based on product ID
  void _addCoinsForProduct(String productId) {
    // Search for corresponding coin amount in all packages
    final allPackages = [..._regularPackages, ..._promotionPackages];
    final package = allPackages.firstWhereOrNull((p) => p['code'] == productId);
    
    if (package != null) {
      final coins = package['coins'] as int;
      _coinService.addCoins(coins);
      print('CoinsLogic: Added $coins coins for product $productId');
    } else {
      print('CoinsLogic: Could not find coin amount for product $productId');
      // Default add 100 coins
      _coinService.addCoins(100);
    }
  }

  void selectPackage(int index) {
    selectedPackage.value = index;
  }

  void toggleDiscount(bool value) {
    showDiscount.value = value;
    selectedPackage.value = -1;
  }

  /// Refresh: re-execute getAppConfig + getGoodsList
  Future<void> refreshGoods() async {
    await _loadConfigThenGoods();
  }

  /// Purchase currently selected package: call Apple in-app purchase
  Future<void> purchasePackage() async {
    if (selectedPackage.value == -1) return;
    
    final packages = currentPackages;
    if (selectedPackage.value >= packages.length) {
      Get.snackbar('Notice', 'Please select a valid package', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final package = packages[selectedPackage.value];
    final productId = package['code']; // Use product code as product ID
    final coins = package['coins'] as int;

    isPurchasing.value = true;

    // Test mode: directly simulate successful purchase
    if (_isTestMode) {
      try {
        await Future.delayed(const Duration(seconds: 2));
        _coinService.addCoins(coins);
        isPurchasing.value = false;
        selectedPackage.value = -1;
        // Get.snackbar(
        //   'Purchase Successful (Test Mode)', 
        //   '+$coins coins added to your account!',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green.withOpacity(0.8),
        //   colorText: Colors.white,
        // );
        return;
      } catch (e) {
        isPurchasing.value = false;
        // Get.snackbar('Purchase Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    // Production mode: use real Apple payment
    try {
      // Check if in-app purchase is available
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        isPurchasing.value = false;
        // Get.snackbar(
        //   'Not Available',
        //   'In-app purchases are not available on this device',
        //   snackPosition: SnackPosition.BOTTOM,
        // );
        return;
      }

      // Query product details
      print('CoinsLogic: Querying product details, productId: $productId');
      final productRes = await _inAppPurchase.queryProductDetails({productId});
      
      if (productRes.notFoundIDs.contains(productId)) {
        isPurchasing.value = false;
        // Get.snackbar(
        //   'Product Not Found',
        //   'Product $productId not found in App Store Connect. Please check your product configuration.',
        //   snackPosition: SnackPosition.BOTTOM,
        //   duration: const Duration(seconds: 4),
        // );
        print('CoinsLogic: Product not found: $productId');
        print('CoinsLogic: Please ensure product ID is configured in App Store Connect: $productId');
        return;
      }

      if (productRes.productDetails.isEmpty) {
        isPurchasing.value = false;
        // Get.snackbar(
        //   'No Products',
        //   'No product details available',
        //   snackPosition: SnackPosition.BOTTOM,
        // );
        print('CoinsLogic: Product details empty');
        return;
      }

      final product = productRes.productDetails.first;
      print('CoinsLogic: Found product: ${product.id}, price: ${product.price}');

      // Initiate purchase
      final success = await _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );

      if (!success) {
        isPurchasing.value = false;
        // Get.snackbar(
        //   'Purchase Failed',
        //   'Failed to initiate purchase',
        //   snackPosition: SnackPosition.BOTTOM,
        // );
        print('CoinsLogic: Failed to initiate purchase');
      } else {
        print('CoinsLogic: Purchase request initiated, waiting for payment result...');
        // Don't set isPurchasing = false here, wait for payment result
      }
      
    } catch (e) {
      isPurchasing.value = false;
      // Get.snackbar('Purchase Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      print('CoinsLogic: Purchase exception: $e');
    }
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    selectedPackage.value = -1;
    super.onClose();
  }
}