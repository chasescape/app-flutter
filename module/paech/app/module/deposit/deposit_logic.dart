import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../env/app_env.dart';
import '../../service/coin_service.dart';
import '../generate/generate_logic.dart';

enum DepositPackType {
  regular,
  promo,
}

class DepositPack {
  const DepositPack({
    required this.goodsCode,
    required this.goodsId,
    required this.exchangeCoin,
    required this.price,
    required this.type,
    this.badge,
    this.originalPrice,
    this.discount,
    this.extraCoin,
    this.extraCoinPercent,
    this.icon,
    this.isPromotion = false,
    this.tags,
  });

  final String goodsCode; // 商品编号
  final String goodsId; // 商品ID
  final int exchangeCoin; // 兑换金币数
  final double price; // 当前价格
  final String type; // 商品类型
  final String? badge; // 商品标签（用于UI显示）
  final double? originalPrice; // 原价
  final int? discount; // 折扣
  final int? extraCoin; // 额外的金币数量
  final int? extraCoinPercent; // 额外的金币比例
  final String? icon; // 商品图标
  final bool isPromotion; // 是否促销
  final String? tags; // 商品标签

  factory DepositPack.fromJson(Map<String, dynamic> json) {
    final exchangeCoin = json['exchangeCoin'] as int? ?? 0;
    final extraCoin = json['extraCoin'] as int? ?? 0;
    final totalCoins = exchangeCoin + extraCoin;

    // 判断是否促销
    final isPromotion = json['isPromotion'] as bool? ?? false;
    
    // 根据是否促销设置 badge
    String? badge;
    if (isPromotion) {
      badge = 'SALE';
    } else {
      badge = json['tags']?.toString() ?? 'NORMAL';
    }

    return DepositPack(
      goodsCode: json['code']?.toString() ?? '',
      goodsId: json['goodsId']?.toString() ?? '',
      exchangeCoin: totalCoins, // 使用总金币数
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? 'coin',
      badge: badge,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discount: json['discount'] as int?,
      extraCoin: extraCoin,
      extraCoinPercent: json['extraCoinPercent'] as int?,
      icon: json['icon']?.toString(),
      isPromotion: isPromotion,
      tags: json['tags']?.toString(),
    );
  }

  /// 格式化价格显示
  String get formattedPrice => '\$$price';

  /// 格式化原价显示
  String? get formattedOriginalPrice =>
      originalPrice != null ? '\$$originalPrice' : null;

  /// 是否推荐（促销商品或有额外金币）
  bool get isRecommended => isPromotion || (extraCoin != null && extraCoin! > 0);
}

class DepositLogic extends GetxController {
  // 默认商品列表（作为后备）
  final _defaultPacks = const <DepositPack>[
    // 常规商品
    DepositPack(
      goodsCode: '261200',
      goodsId: '261200',
      badge: 'NORMAL',
      exchangeCoin: 100,
      price: 0.99,
      type: 'coin',
    ),
    DepositPack(
      goodsCode: '261212',
      goodsId: '261212',
      badge: 'NORMAL',
      exchangeCoin: 400,
      price: 3.99,
      type: 'coin',
    ),
    DepositPack(
      goodsCode: '261201',
      goodsId: '261201',
      badge: 'NORMAL',
      exchangeCoin: 600,
      price: 5.99,
      type: 'coin',
    ),
    DepositPack(
      goodsCode: '261202',
      goodsId: '261202',
      badge: 'NORMAL',
      exchangeCoin: 999,
      price: 9.99,
      type: 'coin',
    ),
    DepositPack(
      goodsCode: '261213',
      goodsId: '261213',
      badge: 'NORMAL',
      exchangeCoin: 1300,
      price: 12.99,
      type: 'coin',
    ),
    DepositPack(
      goodsCode: '261203',
      goodsId: '261203',
      badge: 'NORMAL',
      exchangeCoin: 2500,
      price: 19.99,
      type: 'coin',
    ),
    DepositPack(
      goodsCode: '261204',
      goodsId: '261204',
      badge: 'NORMAL',
      exchangeCoin: 7000,
      price: 49.99,
      type: 'coin',
    ),
    DepositPack(
      goodsCode: '261205',
      goodsId: '261205',
      badge: 'NORMAL',
      exchangeCoin: 15000,
      price: 99.99,
      type: 'coin',
    ),

    // 促销商品 (Flash Deal)
    DepositPack(
      goodsCode: '261206',
      goodsId: '261206',
      badge: 'SALE',
      exchangeCoin: 300,
      price: 0.99,
      originalPrice: 2.99,
      type: 'coin',
      isPromotion: true,
    ),
    DepositPack(
      goodsCode: '261207',
      goodsId: '261207',
      badge: 'SALE',
      exchangeCoin: 499,
      price: 1.99,
      originalPrice: 3.99,
      type: 'coin',
      isPromotion: true,
    ),
    DepositPack(
      goodsCode: '261208',
      goodsId: '261208',
      badge: 'SALE',
      exchangeCoin: 1198,
      price: 4.99,
      originalPrice: 9.99,
      type: 'coin',
      isPromotion: true,
    ),
    DepositPack(
      goodsCode: '261209',
      goodsId: '261209',
      badge: 'SALE',
      exchangeCoin: 2598,
      price: 12.99,
      originalPrice: 19.99,
      type: 'coin',
      isPromotion: true,
    ),
    DepositPack(
      goodsCode: '261210',
      goodsId: '261210',
      badge: 'SALE',
      exchangeCoin: 6999,
      price: 34.99,
      originalPrice: 49.99,
      type: 'coin',
      isPromotion: true,
    ),
    DepositPack(
      goodsCode: '261211',
      goodsId: '261211',
      badge: 'SALE',
      exchangeCoin: 14998,
      price: 79.99,
      originalPrice: 99.99,
      type: 'coin',
      isPromotion: true,
    ),
  ];

  // 商品列表（默认先展示 _defaultPacks，接口成功后再替换）
  late final RxList<DepositPack> packs = RxList<DepositPack>.from(_defaultPacks);

  late final CoinService _coinService;

  final RxBool isLoadingProducts = false.obs;
  final RxBool isPurchasing = false.obs;
  final RxString lastError = ''.obs;

  // 购买超时定时器
  Timer? _purchaseTimeoutTimer;

  // IAP：用于弹出 Apple/Google 支付
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final RxBool storeAvailable = false.obs;
  final RxMap<String, ProductDetails> productsById = <String, ProductDetails>{}.obs;
  final RxBool hasQueriedProducts = false.obs;
  final Set<String> _processedPurchaseIds = <String>{};

  // 用于存储待发放的金币（当 GenerateLogic 未注册时）
  final RxInt pendingCredits = 0.obs;
  
  // SharedPreferences key
  static const String _keyPendingCredits = 'deposit_pending_credits';

  @override
  void onInit() {
    super.onInit();
    _initCoinService();
    _loadPendingCredits();
    loadGoodsList();
    _initIap();
  }

  @override
  void onClose() {
    _purchaseSub?.cancel();
    _purchaseTimeoutTimer?.cancel();
    super.onClose();
  }

  /// 初始化 IAP：监听购买结果，后续 buyPack 会弹出系统支付
  Future<void> _initIap() async {
    storeAvailable.value = await _iap.isAvailable();
    if (!storeAvailable.value) {
      debugPrint('IAP store is not available');
      return;
    }
    _purchaseSub?.cancel();
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _purchaseSub?.cancel(),
      onError: (Object e) {
        debugPrint('Purchase stream error: $e');
        lastError.value = e.toString();
        isPurchasing.value = false;
      },
    );
    await _iap.restorePurchases();
  }

  void _initCoinService() {
    // 从 Aquaria255AppEnv 获取 API 基础 URL
    final baseUrl = Aquaria255AppEnv().hostApi;
    final dioInstance = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _coinService = CoinService(dioInstance);
  }
  
  /// 从服务器加载商品列表
  Future<void> loadGoodsList() async {
    isLoadingProducts.value = true;
    lastError.value = '';
    
    try {
      // 根据平台确定支付通道
      String payChannel = 'IAP'; // 默认苹果内购
      if (Platform.isAndroid) {
        payChannel = 'GP'; // 谷歌支付
      }
      
      final goodsList = await _coinService.getGoodsList(
        isIncludeSubscription: false,
        payChannel: payChannel,
      );
      
      if (goodsList.isNotEmpty) {
        final parsed = goodsList.map((json) => DepositPack.fromJson(json)).toList();
        final valid = parsed.where((p) => p.goodsCode.isNotEmpty).toList();
        if (valid.isNotEmpty) {
          packs.assignAll(valid);
          debugPrint('Loaded ${valid.length} products from server');
        } else {
          debugPrint('Server list had no valid goodsCode, keeping default products');
        }
      } else {
        packs.assignAll(_defaultPacks);
        debugPrint('Server returned empty list, using default products');
      }
    } catch (e) {
      debugPrint('Failed to load goods list: $e');
      lastError.value = 'Failed to load products: $e';
      
      // 加载失败时使用默认商品列表
      packs.assignAll(_defaultPacks);
      debugPrint('Using default products due to error');
    } finally {
      isLoadingProducts.value = false;
      if (storeAvailable.value && packs.isNotEmpty) {
        _queryProducts();
      }
    }
  }
  /// 从本地存储加载待发放的金币
  Future<void> _loadPendingCredits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_keyPendingCredits);
      if (saved != null && saved > 0) {
        pendingCredits.value = saved;
        debugPrint('Loaded pending credits: $saved');
        // 尝试立即发放
        await _deliverPendingCredits();
      }
    } catch (e) {
      debugPrint('Error loading pending credits: $e');
    }
  }
  
  /// 保存待发放的金币到本地存储
  Future<void> _savePendingCredits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyPendingCredits, pendingCredits.value);
      debugPrint('Saved pending credits: ${pendingCredits.value}');
    } catch (e) {
      debugPrint('Error saving pending credits: $e');
    }
  }
  
  /// 发放待发放的金币到 GenerateLogic
  Future<void> _deliverPendingCredits() async {
    if (pendingCredits.value <= 0) return;
    
    if (Get.isRegistered<GenerateLogic>()) {
      try {
        final generateLogic = Get.find<GenerateLogic>();
        // 直接增加金币，不管是否有免费次数
        generateLogic.addCredits(pendingCredits.value);
        debugPrint('Delivered pending credits: ${pendingCredits.value}');

        // 清空待发放金币
        pendingCredits.value = 0;
        await _savePendingCredits();
      } catch (e) {
        debugPrint('Error delivering pending credits: $e');
      }
    }
  }

  /// 从应用商店查询商品（goodsCode 即 IAP productId）
  Future<void> _queryProducts() async {
    if (packs.isEmpty) return;
    isLoadingProducts.value = true;
    lastError.value = '';
    try {
      final ids = packs.map((p) => p.goodsCode).toSet();
      debugPrint('IAP queryProductDetails: $ids');
      final resp = await _iap.queryProductDetails(ids);
      hasQueriedProducts.value = true;
      if (resp.error != null) {
        lastError.value = resp.error!.message;
        debugPrint('IAP query error: ${resp.error!.message}');
      }
      productsById.assignAll({for (final p in resp.productDetails) p.id: p});
      debugPrint('IAP found ${resp.productDetails.length} products');
    } catch (e) {
      debugPrint('IAP _queryProducts error: $e');
      lastError.value = e.toString();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// 添加金币（立即发放或保存为待发放）
  Future<void> _addCreditsToUser(int credits) async {
    if (Get.isRegistered<GenerateLogic>()) {
      try {
        final generateLogic = Get.find<GenerateLogic>();
        // 直接增加金币，不管是否有免费次数
        generateLogic.addCredits(credits);
        debugPrint('Credits added immediately: $credits, Total: ${generateLogic.credits.value}');
      } catch (e) {
        debugPrint('Error updating credits in GenerateLogic: $e');
        // 如果发放失败，保存为待发放
        pendingCredits.value += credits;
        await _savePendingCredits();
      }
    } else {
      debugPrint('GenerateLogic not registered yet, saving as pending credits');
      // 保存为待发放金币
      pendingCredits.value += credits;
      await _savePendingCredits();
    }
  }

  /// 购买商品：先弹出 Apple/Google 支付，支付成功后再调后端并加币
  Future<void> buyPack(int index) async {
    debugPrint('buyPack called with index: $index');
    if (index < 0 || index >= packs.length) {
      debugPrint('Invalid index: $index');
      return;
    }
    if (isPurchasing.value) {
      debugPrint('Purchase already in progress');
      Get.snackbar(
        'Please Wait',
        'A purchase is already in progress.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    lastError.value = '';
    isPurchasing.value = true;

    try {
      final pack = packs[index];
      debugPrint('Attempting to buy pack: ${pack.goodsCode}, coins: ${pack.exchangeCoin}');

      if (!storeAvailable.value) {
        debugPrint('Store not available, initializing IAP...');
        await _initIap();
        if (!storeAvailable.value) {
          lastError.value = 'Store not available';
          isPurchasing.value = false;
          Get.snackbar(
            'Store Unavailable',
            'In-app purchase is not available. Please try again later.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFF2D2A26),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      // 获取 IAP 商品信息（goodsCode 即 App Store/Play 的 productId）
      ProductDetails? product = productsById[pack.goodsCode];
      if (product == null && !hasQueriedProducts.value) {
        debugPrint('Product not found, querying products...');
        await _queryProducts();
        product = productsById[pack.goodsCode];
      }
      if (product == null) {
        lastError.value = 'Product not found: ${pack.goodsCode}';
        isPurchasing.value = false;
        debugPrint('Product ${pack.goodsCode} not found in store');
        Get.snackbar(
          'Product Not Found',
          'This product is not available. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF2D2A26),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // 弹出系统支付（Apple Pay / Google Pay）
      debugPrint('Starting IAP purchase for product: ${product.id}, price: ${product.price}');
      final param = PurchaseParam(productDetails: product);
      final success = await _iap.buyConsumable(purchaseParam: param, autoConsume: true);
      debugPrint('IAP buyConsumable returned: $success');
      
      if (!success) {
        isPurchasing.value = false;
        debugPrint('IAP buyConsumable returned false');
        Get.snackbar(
          'Purchase Failed',
          'Could not start purchase. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF2D2A26),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      
      // 支付结果在 _onPurchaseUpdated 中处理
      debugPrint('Waiting for purchase result in stream...');
      
      // 设置超时保护（60秒后自动重置状态）
      _purchaseTimeoutTimer?.cancel();
      _purchaseTimeoutTimer = Timer(const Duration(seconds: 60), () {
        if (isPurchasing.value) {
          debugPrint('Purchase timeout - resetting isPurchasing state');
          isPurchasing.value = false;
          Get.snackbar(
            'Purchase Timeout',
            'The purchase took too long. Please check your purchase history.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFF2D2A26),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      });
      
    } on PlatformException catch (e) {
      final errorMsg = e.message ?? e.code;
      debugPrint('PlatformException during purchase: $errorMsg, code: ${e.code}');
      lastError.value = errorMsg;
      isPurchasing.value = false;
      
      Get.snackbar(
        'Purchase Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      // 尝试恢复购买以清理状态
      try {
        await _iap.restorePurchases();
      } catch (restoreError) {
        debugPrint('Error restoring purchases: $restoreError');
      }
      
    } catch (e) {
      final errorMsg = e.toString();
      debugPrint('Exception during purchase: $errorMsg');
      lastError.value = errorMsg;
      isPurchasing.value = false;
      
      Get.snackbar(
        'Purchase Failed',
        'Unable to complete purchase. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2D2A26),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// IAP 购买结果回调：支付成功后再调后端 createRechargeOrder 并加币
  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('Purchase status: ${purchase.status}, productId: ${purchase.productID}');
      
      if (purchase.status == PurchaseStatus.pending) {
        if (!isPurchasing.value) isPurchasing.value = true;
        continue;
      }
      
      if (purchase.status == PurchaseStatus.error) {
        final msg = purchase.error?.message ?? purchase.error?.code ?? 'Purchase error';
        debugPrint('Purchase error: $msg, code: ${purchase.error?.code}');
        lastError.value = msg;
        isPurchasing.value = false;
        _purchaseTimeoutTimer?.cancel(); // 取消超时定时器
        
        // 完成购买以清理状态
        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
            debugPrint('Completed failed purchase to clear state');
          } catch (e) {
            debugPrint('Error completing failed purchase: $e');
          }
        }
        
        Get.snackbar(
          'Purchase Failed',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF2D2A26),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        continue;
      }
      
      if (purchase.status == PurchaseStatus.canceled) {
        debugPrint('Purchase canceled by user');
        isPurchasing.value = false;
        _purchaseTimeoutTimer?.cancel(); // 取消超时定时器
        
        // 完成购买以清理状态
        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
            debugPrint('Completed canceled purchase to clear state');
          } catch (e) {
            debugPrint('Error completing canceled purchase: $e');
          }
        }
        continue;
      }
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final productId = purchase.productID;
        if (_processedPurchaseIds.contains(productId)) {
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          continue;
        }
        _processedPurchaseIds.add(productId);

        DepositPack? pack;
        for (final p in packs) {
          if (p.goodsCode == productId) {
            pack = p;
            break;
          }
        }
        if (pack == null) {
          debugPrint('Pack not found for productId: $productId');
          if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
          isPurchasing.value = false;
          continue;
        }

        try {
          String payChannel = 'IAP';
          if (Platform.isAndroid) payChannel = 'GP';
          await _coinService.createRechargeOrder(
            goodsCode: pack.goodsCode,
            payChannel: payChannel,
            entry: 'deposit_page',
          );
          await _addCreditsToUser(pack.exchangeCoin);
          Get.snackbar(
            'Success!',
            'Your purchase was successful! ${pack.exchangeCoin} credits added.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFFC8A57E),
            colorText: Colors.white,
          );
        } catch (e) {
          debugPrint('createRechargeOrder or addCredits error: $e');
          await _addCreditsToUser(pack.exchangeCoin);
          Get.snackbar(
            'Success!',
            'Your purchase was successful! ${pack.exchangeCoin} credits added.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFFC8A57E),
            colorText: Colors.white,
          );
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        isPurchasing.value = false;
        _purchaseTimeoutTimer?.cancel(); // 取消超时定时器
      }
    }
  }
  
  /// 处理支付成功回调（当支付完成后调用）
  /// 参数：orderNo - 订单号，coins - 金币数量
  Future<void> handlePaymentSuccess({
    required String orderNo,
    required int coins,
  }) async {
    debugPrint('Payment success callback: orderNo=$orderNo, coins=$coins');
    
    try {
      // 发放金币
      await _addCreditsToUser(coins);
      
      Get.snackbar(
        'Payment Successful!',
        'Your purchase was successful! $coins credits added.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFFC8A57E),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Error handling payment success: $e');
    }
  }
}
