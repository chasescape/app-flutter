import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:enkou/enkou/app/core/app_config_service.dart';
import 'package:enkou/enkou/app/core/coin_service.dart';
import 'package:enkou/enkou/app/core/service_config.dart';
import 'package:enkou/enkou/app/data/coin_products_data.dart';
import 'package:enkou/enkou/app/widget/loading_overlay.dart';
import 'package:enkou/enkou/env/app_env.dart';
import 'package:enkou/enkou/interface.dart';

class CoinPackageVM {
  const CoinPackageVM({
    required this.goodsCode,
    required this.priceLabel,
    required this.coins,
    this.originalPrice,
    this.discountLabel,
    this.isPromo = false,
    this.raw,
  });

  final String goodsCode;
  final String priceLabel;
  final int coins;
  final String? originalPrice;
  final String? discountLabel;
  final bool isPromo;
  final Map<String, dynamic>? raw;

  bool get hasDiscount => discountLabel != null && originalPrice != null;

  bool get showSaleBadge => isPromo && !hasDiscount;
}

class CoinsLogic extends GetxController {
  final RxInt balance = 0.obs;
  final RxBool loading = true.obs;
  final RxString errorText = ''.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isProcessing = false.obs;

  final RxList<CoinPackageVM> packages = <CoinPackageVM>[].obs;

  final InAppPurchase _iap = InAppPurchase.instance;
  final RxBool iapAvailable = false.obs;
  final Map<String, ProductDetails> _productById = {};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final Map<String, CoinPackageVM> _packageByProductId = {};

  late final _EnkouServiceAdapter _config;
  late final Dio _dio;
  late final AppConfigService _appConfigService;
  late final CoinService _coinService;

  @override
  void onInit() {
    super.onInit();
    _config = _EnkouServiceAdapter();
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnv().hostApi,
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 25),
      ),
    );
    _appConfigService = AppConfigService(_dio, _config);
    _coinService = CoinService(_dio, _config);

    _seedLocalPackages();
    _initIap();
    _bootstrap();
  }

  static const String _keyCoinBalance = 'enkou_coin_balance';

  void _seedLocalPackages() {
    packages.assignAll(
      coinProducts.map((p) {
        return CoinPackageVM(
          goodsCode: p.code.toString(),
          priceLabel: p.priceLabel,
          coins: p.coins,
          isPromo: p.type == CoinProductType.promo,
          originalPrice: p.originalPrice,
          discountLabel: p.discountLabel,
        );
      }).toList(),
    );
    _syncPackageByProductId();
  }

  void _syncPackageByProductId() {
    _packageByProductId
      ..clear()
      ..addEntries(
        packages.map((p) => MapEntry(p.goodsCode, p)),
      );
  }

  Future<void> _bootstrap() async {
    loading.value = true;
    errorText.value = '';
    try {
      await _loadCoinBalance();
      await _ensureDeviceId();
    } catch (e) {
      errorText.value = e.toString();
    } finally {
      loading.value = false;
    }
    // 加密 key、商品列表后台拉取，不阻塞首屏
    try {
      await _ensureEncryptKey();
      await refreshGoodsList();
    } catch (e) {
      errorText.value = e.toString();
    }
  }

  Future<void> _loadCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_keyCoinBalance);
    if (saved != null) {
      balance.value = saved;
    } else {
      balance.value = 0;
      unawaited(_saveCoinBalance());
    }
  }

  Future<void> _saveCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoinBalance, balance.value);
  }

  /// 扣减金币，成功返回 true；余额不足返回 false
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return true;

    // 确保在读取余额前已从本地加载一次，避免异步初始化尚未完成时误判为 0
    try {
      await _loadCoinBalance();
    } catch (_) {
      // 读本地失败时退化为用当前内存值
    }

    if (balance.value < amount) {
      return false;
    }

    balance.value -= amount;
    unawaited(_saveCoinBalance());
    return true;
  }

  Future<void> _initIap() async {
    final available = await _iap.isAvailable();
    iapAvailable.value = available;
    if (!available) return;

    _purchaseSub?.cancel();
    _purchaseSub = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) {
        errorText.value = e.toString();
      },
    );

    await _queryProducts();
  }

  Future<void> _queryProducts() async {
    final ids = packages.map((p) => p.goodsCode).toSet();
    if (ids.isEmpty) return;

    final response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      errorText.value = response.error!.message;
      return;
    }

    _productById
      ..clear()
      ..addEntries(response.productDetails.map((p) => MapEntry(p.id, p)));

    // 仅用商店校验商品存在，展示价格固定用本地美刀（不跟商店本地化）
    final updated = packages.map((p) {
      final product = _productById[p.goodsCode];
      if (product == null) return p;
      return CoinPackageVM(
        goodsCode: p.goodsCode,
        priceLabel: p.priceLabel,
        coins: p.coins,
        isPromo: p.isPromo,
        originalPrice: p.originalPrice,
        discountLabel: p.discountLabel,
        raw: p.raw,
      );
    }).toList();
    packages.assignAll(updated);
    _syncPackageByProductId();
  }

  Future<void> refreshGoodsList({bool force = false}) async {
    try {
      final list = await _coinService.getGoodsList(
        payChannel: Platform.isIOS ? 'IAP' : 'GP',
        isIncludeSubscription: false,
        forceRefresh: force,
      );
      final mapped = _mapServerGoodsToPackages(list);
      if (mapped.isNotEmpty) {
        packages.assignAll(mapped);
        _syncPackageByProductId();
      }
    } catch (e) {
      // 保留本地 fallback，不把页面置空
      errorText.value = e.toString();
    }
  }

  List<CoinPackageVM> _mapServerGoodsToPackages(
    List<Map<String, dynamic>> list,
  ) {
    int? asInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? asStr(dynamic v) {
      if (v == null) return null;
      return v.toString();
    }

    bool asBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v == '1' || v.toLowerCase() == 'true';
      return false;
    }

    final mapped = <CoinPackageVM>[];
    for (final m in list) {
      final goodsCode = asStr(m['goodsCode'] ?? m['code'] ?? m['id']);
      if (goodsCode == null || goodsCode.trim().isEmpty) continue;

      final coins = asInt(m['coins'] ?? m['coin'] ?? m['amount'] ?? m['num']);
      if (coins == null) continue;

      final priceLabel = asStr(m['priceLabel'] ?? m['price'] ?? m['payPrice']);
      if (priceLabel == null || priceLabel.trim().isEmpty) continue;

      final originalPrice =
          asStr(m['originalPrice'] ?? m['originPrice'] ?? m['oldPrice']);
      final discountLabel =
          asStr(m['discountLabel'] ?? m['discount'] ?? m['tag']);
      final isPromo =
          asBool(m['isPromo'] ?? m['promo'] ?? m['isSale'] ?? m['sale']);

      mapped.add(
        CoinPackageVM(
          goodsCode: goodsCode,
          priceLabel: priceLabel,
          coins: coins,
          isPromo: isPromo,
          originalPrice: originalPrice,
          discountLabel: discountLabel,
          raw: m,
        ),
      );
    }

    mapped.sort((a, b) => a.coins.compareTo(b.coins));
    // 展示价格固定用本地美刀，避免服务端返回本地货币（如 CNY）
    for (var i = 0; i < mapped.length; i++) {
      final p = mapped[i];
      final code = int.tryParse(p.goodsCode);
      if (code == null) continue;
      CoinProduct? local;
      for (final c in coinProducts) {
        if (c.code == code) {
          local = c;
          break;
        }
      }
      if (local != null) {
        mapped[i] = CoinPackageVM(
          goodsCode: p.goodsCode,
          priceLabel: local.priceLabel,
          coins: p.coins,
          isPromo: p.isPromo,
          originalPrice: local.originalPrice,
          discountLabel: p.discountLabel,
          raw: p.raw,
        );
      }
    }
    return mapped;
  }

  Future<Map<String, dynamic>> createRechargeOrder({
    required CoinPackageVM package,
  }) async {
    await _ensureDeviceId();
    await _ensureEncryptKey();

    final order = await _coinService.createRechargeOrder(
      goodsCode: package.goodsCode,
      payChannel: Platform.isIOS ? 'IAP' : 'GP',
      entry: 'coins_page',
    );
    return order;
  }

  Future<void> startPurchase(CoinPackageVM package) async {
    // 防止重复点击
    if (isProcessing.value) {
      return;
    }
    
    if (!iapAvailable.value) {
      const msg = 'In-app purchase is not available on this device';
      errorText.value = msg;
      errorMessage.value = msg;
      _showError(msg);
      return;
    }
    
    final product = _productById[package.goodsCode];
    if (product == null) {
      await _queryProducts();
    }
    final resolved = _productById[package.goodsCode];
    if (resolved == null) {
      const msg = 'Product not found. Please try again later.';
      errorText.value = msg;
      errorMessage.value = msg;
      _showError(msg);
      return;
    }

    try {
      // 先创建服务端订单（如果失败，终止购买）
      isProcessing.value = true;
      errorMessage.value = null;
      LoadingOverlay.show();
      
      final order = await createRechargeOrder(package: package);
      final orderId =
          (order['orderId'] ?? order['order_id'] ?? order['id'])?.toString();

      final purchaseParam = PurchaseParam(
        productDetails: resolved,
        applicationUserName: orderId,
      );
      
      await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      
      // Note: isProcessing will be set to false in _handlePurchaseUpdates
    } catch (e) {
      isProcessing.value = false;
      LoadingOverlay.hide();
      
      final msg = e.toString().contains('timeout') || e.toString().contains('network')
          ? 'Network error. Please check your connection and try again.'
          : 'Failed to start purchase. Please try again later.';
      
      errorText.value = msg;
      errorMessage.value = msg;
      _showError(msg);
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> detailsList) {
    for (final purchase in detailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
          isProcessing.value = false;
          LoadingOverlay.hide();
          
          final errorMsg = purchase.error?.message ?? '';
          final msg = errorMsg.toLowerCase().contains('user')
              ? 'Purchase was not completed. Please try again.'
              : errorMsg.isNotEmpty
                  ? errorMsg
                  : 'Purchase failed. Please try again later.';
          
          errorText.value = msg;
          errorMessage.value = msg;
          _showError(msg);
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
        // 不要让 completePurchase 的异常阻断后续 UI 清理
        _iap.completePurchase(purchase).catchError((_) {});
      }
      if (purchase.status != PurchaseStatus.pending) {
        LoadingOverlay.hide();
      }
    }
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchase) {
    isProcessing.value = false;
    LoadingOverlay.hide();
    _deliverPurchaseSync(purchase);

    final context = Get.context;
    if (context == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = (isDark
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).primaryColor)
        .withOpacity(0.95);

    final pkg = _packageByProductId[purchase.productID];
    final amount = pkg?.coins ?? 0;

    Get.snackbar(
      'Top up successful',
      amount > 0 ? 'You received $amount coins' : 'Purchase successful',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bgColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _deliverPurchaseSync(PurchaseDetails purchase) {
    final productId = purchase.productID;
    final pkg = _packageByProductId[productId];
    if (pkg != null) {
      balance.value += pkg.coins;
      unawaited(_saveCoinBalance());
    }
  }

  void _showError(String message) {
    // 只做状态清理，不再弹出失败提示弹窗
    LoadingOverlay.hide();
  }

  Future<void> _ensureDeviceId() async {
    final i = Interface();
    if (i.deviceId != null && i.deviceId!.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final existed = prefs.getString('device_uuid_v1');
    if (existed != null && existed.isNotEmpty) {
      i.deviceId = existed;
      return;
    }

    final rand = math.Random();
    final generated =
        'dev_${DateTime.now().microsecondsSinceEpoch}_${rand.nextInt(1 << 32)}';
    await prefs.setString('device_uuid_v1', generated);
    i.deviceId = generated;
  }

  Future<void> _ensureEncryptKey() async {
    // 优先读内存，再读本地缓存，不够再走 AppConfigService
    final i = Interface();
    if (i.encryptKey != null && i.encryptKey!.isNotEmpty) {
      _config.encryptKey = i.encryptKey;
      return;
    }

    final cached = await _config.getString('encrypt_key');
    if (cached != null && cached.isNotEmpty) {
      _config.encryptKey = cached;
      return;
    }

    await _appConfigService.getAppConfig();
  }

  @override
  void onClose() {
    _purchaseSub?.cancel();
    super.onClose();
  }
}

class _EnkouServiceAdapter implements ServiceConfig {
  final Interface _i = Interface();

  @override
  String? get encryptKey => _i.encryptKey;

  @override
  set encryptKey(String? value) {
    _i.encryptKey = value;
    if (value != null && value.isNotEmpty) {
      saveString('encrypt_key', value);
    }
  }

  @override
  String? get authToken => _i.authToken;

  @override
  set authToken(String? value) {
    _i.authToken = value;
    if (value != null && value.isNotEmpty) {
      saveString('auth_token', value);
    }
  }

  @override
  String? get deviceId => _i.deviceId;

  @override
  String get hostApi => AppEnv().hostApi;

  @override
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
