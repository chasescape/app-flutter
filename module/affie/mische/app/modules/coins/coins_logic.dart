import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

import '../../data/coins_data.dart';
import '../../data/local/local_storage.dart';

class CoinsLogic extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  final available = false.obs;
  final products = <ProductDetails>[].obs;
  final currentBalance = 199.obs;
  final isLoading = false.obs;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  String? _pendingProductId;
  bool _purchaseInProgress = false;
  bool _balanceLoaded = false;
  DateTime? _lastInsufficientNotice;

  @override
  void onInit() {
    super.onInit();
    _loadBalance();
    _initIAP();
  }

  Future<void> _loadBalance() async {
    final stored = await LocalStorage.loadCoins(defaultValue: currentBalance.value);
    currentBalance.value = stored;
    _balanceLoaded = true;
  }

  Future<void> _initIAP() async {
    isLoading.value = true;

    available.value = await _iap.isAvailable();

    if (available.value) {
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          print('Purchase stream error: $error');
          _pendingProductId = null;
          _purchaseInProgress = false;
          isLoading.value = false;
        },
      );

      await _loadProducts();
    }

    isLoading.value = false;
  }

  Future<void> _loadProducts() async {
    // ⚠️ iOS StoreKit 查询使用的是「Product ID」
    // 这个项目历史上过审的写法是：直接用 CoinsData 的 id（例如 264900）作为 Product ID。
    final productIds = CoinsData.products.map((p) => p.id).toSet();
    final response = await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }

    products.value = response.productDetails;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      final isTargetPurchase = _pendingProductId != null && purchase.productID == _pendingProductId;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          if (isTargetPurchase) {
            isLoading.value = true;
          }
          break;

        case PurchaseStatus.purchased:
          if (isTargetPurchase) {
            _deliverProduct(purchase);
            _pendingProductId = null;
            _purchaseInProgress = false;
            isLoading.value = false;
          }
          break;

        case PurchaseStatus.error:
          if (isTargetPurchase) {
            _pendingProductId = null;
            _purchaseInProgress = false;
            isLoading.value = false;
          }
          break;

        case PurchaseStatus.canceled:
          if (isTargetPurchase) {
            _pendingProductId = null;
            _purchaseInProgress = false;
            isLoading.value = false;
          }
          break;

        case PurchaseStatus.restored:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  CoinProduct? _findProductByStoreId(String productId) {
    return CoinsData.products.firstWhereOrNull((p) => p.id == productId);
  }

  void _deliverProduct(PurchaseDetails purchase) {
    final product = _findProductByStoreId(purchase.productID);

    if (product != null) {
      currentBalance.value += product.coins;
      LocalStorage.saveCoins(currentBalance.value);

      Get.snackbar(
        'Success!',
        'You received ${product.coins} coins!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF42E5C0),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // TODO: 这里应该将购买记录同步到服务器
      print('Delivered ${product.coins} coins for purchase ${purchase.purchaseID}');
    }
  }

  Future<void> buyProduct(CoinProduct product) async {
    if (!available.value || isLoading.value || _purchaseInProgress) {
      return;
    }

    // 过审版本使用 CoinsData.id 作为 Product ID
    final productDetails = products.firstWhereOrNull(
      (p) => p.id == product.id,
    );

    if (productDetails == null) {
      Get.snackbar(
        'Unavailable',
        'This item is not available right now. Please try again later.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF7A4B),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isLoading.value = true;
    _purchaseInProgress = true;
    _pendingProductId = product.id;

    final purchaseParam = PurchaseParam(productDetails: productDetails);

    try {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Purchase error: $e');
      _pendingProductId = null;
      _purchaseInProgress = false;
      isLoading.value = false;
    }
  }

  // 使用 AI 分析扣费
  bool useAI() {
    if (!_balanceLoaded) {
      return false;
    }

    const aiCost = 100;

    if (currentBalance.value < aiCost) {
      final now = DateTime.now();
      final lastNotice = _lastInsufficientNotice;
      final shouldNotify = lastNotice == null || now.difference(lastNotice) > const Duration(seconds: 2);
      if (shouldNotify) {
        _lastInsufficientNotice = now;
        Get.snackbar(
          'Insufficient Balance',
          'You need $aiCost coins to use AI analysis. Please top up.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFF7A4B),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      return false;
    }

    currentBalance.value -= aiCost;
    LocalStorage.saveCoins(currentBalance.value);

    Get.snackbar(
      'AI Analysis',
      '$aiCost coins deducted. Balance: ${currentBalance.value}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF8F3CF0),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    return true;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

