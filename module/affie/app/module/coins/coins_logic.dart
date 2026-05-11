import 'dart:async';

import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../env/app_env.dart';
import '../../../interface.dart';
import '../../core/app_config_service.dart';
import '../../core/coin_service.dart';
import '../../core/service_config.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../data/coins_data.dart';
import '../../widgets/loading_overlay.dart';

class CoinsLogic extends GetxController {
  final coinBalance = 100.obs;
  final selectedPackageCoins = RxnInt();
  static const _storageKey = 'coin_balance_v1';

  late final Dio _dio;
  late final AppConfigService _appConfigService;
  late final CoinService _coinService;
  late final ServiceConfig _serviceConfig;

  Future<void>? _ensureConfigFuture;
  final Map<String, Map<String, dynamic>> _orderByGoodsCode = {};

  // IAP 状态
  final isStoreAvailable = false.obs;
  final isProcessing = false.obs;
  final errorMessage = RxnString();

  final InAppPurchase _iap = InAppPurchase.instance;
  final Map<String, ProductDetails> _products = {};
  Future<void>? _initStoreFuture;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Worker? _coinWorker;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: AppEnv().hostApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _serviceConfig = _CoinsServiceConfigImpl();
    _appConfigService = AppConfigService(_dio, _serviceConfig);
    _coinService = CoinService(_dio, _serviceConfig);

    _loadBalance();
    _coinWorker = ever<int>(coinBalance, (v) => _saveBalance(v));
    _initStoreFuture = _initStoreInfo();
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object error) {
        isProcessing.value = false;
        _showError('Purchase failed: $error');
      },
      onDone: () {
        isProcessing.value = false;
        LoadingOverlay.hide();
      },
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _coinWorker?.dispose();
    _dio.close();
    super.onClose();
  }

  Future<void> _loadBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_storageKey);
      if (saved != null) {
        coinBalance.value = saved;
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _saveBalance(int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, value);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _initStoreInfo() async {
    try {
      final available = await _iap.isAvailable();
      isStoreAvailable.value = available;
      if (!available) {
        errorMessage.value = 'Store not available on this device.';
        return;
      }

      final ids = CoinsData.packages.map((e) => e.code).toSet();
      final response = await _iap.queryProductDetails(ids);
      if (response.error != null) {
        errorMessage.value = response.error!.message;
      }
      for (final p in response.productDetails) {
        _products[p.id] = p;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load store products: $e';
    }
  }

  Future<void> purchasePackage(CoinPackage package) async {
    if (_initStoreFuture != null) {
      await _initStoreFuture;
    }

    if (!isStoreAvailable.value) {
      _showError('Store not available. Please try again later.');
      return;
    }

    // 购买前必须保证 encryptKey 已拿到（getConfig）
    try {
      LoadingOverlay.show(message: 'Preparing purchase...');
      await _ensureAppConfig();
    } catch (e) {
      _showError('Failed to get config: $e');
      return;
    } finally {
      LoadingOverlay.hide();
    }

    // 购买前先创建充值订单（服务端记录/映射）
    try {
      LoadingOverlay.show(message: 'Creating order...');
      final order = await _coinService.createRechargeOrder(
        goodsCode: package.code,
        payChannel: Platform.isAndroid ? 'GP' : 'IAP',
        entry: 'coins_page',
      );
      _orderByGoodsCode[package.code] =
          order.map((k, v) => MapEntry(k.toString(), v));
    } catch (e) {
      _showError('Failed to create order: $e');
      return;
    } finally {
      LoadingOverlay.hide();
    }

    final details = await _resolveProductDetails(package.code);
    if (details == null) {
      _showError(
        'Product not found in store: ${package.code}. Please check App Store product IDs.',
      );
      return;
    }

    isProcessing.value = true;
    errorMessage.value = null;
    LoadingOverlay.show(message: 'Connecting to App Store...');

    final param = PurchaseParam(productDetails: details);
    try {
      await _iap.buyConsumable(purchaseParam: param);
    } catch (e) {
      isProcessing.value = false;
      _showError('Failed to start purchase: $e');
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
          isProcessing.value = false;
          _showError('Purchase error: ${purchase.error}');
          break;
        case PurchaseStatus.pending:
          isProcessing.value = true;
          break;
        case PurchaseStatus.canceled:
          isProcessing.value = false;
          LoadingOverlay.hide();
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }

      if (purchase.status != PurchaseStatus.pending) {
        LoadingOverlay.hide();
      }
    }
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchase) {
    isProcessing.value = false;
    LoadingOverlay.hide();
    final package = _resolvePackageByProductId(purchase.productID);
    if (package == null) {
      _showError('Unknown product: ${purchase.productID}');
      return;
    }

    // 这里已确保下单接口被调用（purchase 前 createRechargeOrder）。
    // 如果后端后续需要 receipt/transactionId 校验，可以在 CoinService 增加确认接口后，
    // 在此处补充回传 purchase.verificationData / transactionId。

    final amount = package.coins;
    coinBalance.value += amount;

    final context = Get.context;
    final isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;

    Get.snackbar(
      'Top up successful',
      'You received $amount coins',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          (isDark ? AppColors.secondaryDark : AppColors.primary)
              .withValues(alpha: 0.95),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(String message) {
    errorMessage.value = message;
    final context = Get.context;
    final isDark =
        context != null && Theme.of(context).brightness == Brightness.dark;

    Get.snackbar(
      'Purchase failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          (isDark ? AppColors.secondaryDark : AppColors.primary)
              .withValues(alpha: 0.95),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    LoadingOverlay.hide();
  }

  /// 扣减金币，成功返回 true，余额不足返回 false 并提示
  bool spendCoins(int amount) {
    if (coinBalance.value < amount) {
      final context = Get.context;
      final isDark =
          context != null && Theme.of(context).brightness == Brightness.dark;

      Get.snackbar(
        'Not enough coins',
        'You need at least $amount coins to use this feature.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            (isDark ? AppColors.secondaryDark : AppColors.primary)
                .withValues(alpha: 0.95),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      // 余额不足，跳转到金币充值页
      Get.toNamed(AppRoutes.coins);
      return false;
    }

    coinBalance.value -= amount;
    return true;
  }

  Future<ProductDetails?> _resolveProductDetails(String code) async {
    final direct = _products[code];
    if (direct != null) return direct;

    for (final entry in _products.entries) {
      if (entry.key.endsWith('.$code')) {
        return entry.value;
      }
    }

    final response = await _iap.queryProductDetails({code});
    for (final p in response.productDetails) {
      _products[p.id] = p;
    }

    final refreshedDirect = _products[code];
    if (refreshedDirect != null) return refreshedDirect;

    for (final entry in _products.entries) {
      if (entry.key.endsWith('.$code')) {
        return entry.value;
      }
    }
    return null;
  }

  CoinPackage? _resolvePackageByProductId(String productId) {
    final direct = CoinsData.findByCode(productId);
    if (direct != null) return direct;

    for (final p in CoinsData.packages) {
      if (productId.endsWith('.${p.code}')) {
        return p;
      }
    }
    return null;
  }

  Future<void> _ensureAppConfig() async {
    if ((Interface().encryptKey ?? '').isNotEmpty) return;
    _ensureConfigFuture ??= _appConfigService.getAppConfig().then((_) {});
    await _ensureConfigFuture;
  }
}

class _CoinsServiceConfigImpl extends ServiceConfig {
  @override
  String? get encryptKey => Interface().encryptKey;

  @override
  set encryptKey(String? value) => Interface().encryptKey = value;

  @override
  String? get authToken => Interface().authToken;

  @override
  set authToken(String? value) => Interface().authToken = value;

  @override
  String? get deviceId => Interface().deviceId;

  @override
  String get hostApi => AppEnv().hostApi;
}
