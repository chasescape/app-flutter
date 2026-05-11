import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yapo/yapo/core/adapters/yapo_service_adapter.dart';
import 'package:yapo/yapo/core/network/coin_service.dart';
import 'package:yapo/yapo/env/app_env.dart';

import '../publish/publish_logic.dart';

/// 金币逻辑（参考 Deposit 购买流程重构）
class CoinsLogic extends GetxController {
  /// 当前本地金币（用 SharedPreferences 持久化）
  final RxInt userCoins = 100.obs;

  /// 商品列表（UI 依赖 `coins_view.dart` 里的 Map 结构）
  final RxList<Map<String, dynamic>> packages = <Map<String, dynamic>>[].obs;

  /// 加载商品/余额
  final RxBool isLoading = false.obs;

  /// 是否正在发起/等待内购结果
  final RxBool isPurchasing = false.obs;

  /// 是否正在加载本地金币
  final RxBool isLoadingCoins = true.obs;

  /// IAP 相关
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final RxBool storeAvailable = false.obs;
  final RxBool hasQueriedProducts = false.obs;
  final RxMap<String, ProductDetails> productsById =
      <String, ProductDetails>{}.obs;
  final Set<String> _processedPurchaseIds = <String>{};

  /// 购买超时保护
  Timer? _purchaseTimeoutTimer;

  /// 服务端金币商品接口
  late final CoinService _coinService;
  late final dio.Dio _dio;

  static const String _keyUserCoins = 'user_coins';

  @override
  void onInit() {
    super.onInit();
    _initService();
    _loadUserCoins();
    _initIap();
    _loadGoodsList();
  }

  @override
  void onClose() {
    _purchaseSub?.cancel();
    _purchaseTimeoutTimer?.cancel();
    _dio.close(force: true);
    super.onClose();
  }

  /// 初始化加密 CoinService
  void _initService() {
    final config = YapoServiceAdapter();
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: AppEnv().hostApi,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _coinService = CoinService(_dio, config);
  }

  /// 加载本地金币余额
  Future<void> _loadUserCoins() async {
    isLoadingCoins.value = true;
    try {
      // 略微延迟，避免首屏抖动
      await Future.delayed(const Duration(milliseconds: 200));

      final prefs = await SharedPreferences.getInstance();
      final savedCoins = prefs.getInt(_keyUserCoins);
      if (savedCoins != null) {
        userCoins.value = savedCoins;

        if (Get.isRegistered<PublishLogic>()) {
          try {
            final publishLogic = Get.find<PublishLogic>();
            publishLogic.userCoins.value = savedCoins;
          } catch (_) {}
        }
      } else {
        await _saveUserCoins();
      }
    } catch (_) {
    } finally {
      isLoadingCoins.value = false;
    }
  }

  Future<void> _saveUserCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUserCoins, userCoins.value);
    } catch (_) {}
  }

  /// 初始化 IAP：监听购买结果
  Future<void> _initIap() async {
    try {
      storeAvailable.value = await _iap.isAvailable();
      if (!storeAvailable.value) {
        debugPrint('CoinsLogic: IAP store not available');
        return;
      }

      _purchaseSub?.cancel();
      _purchaseSub = _iap.purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: () => _purchaseSub?.cancel(),
        onError: (Object e) {
          debugPrint('CoinsLogic: purchase stream error: $e');
          isPurchasing.value = false;
        },
      );

      // ⚠️ 金币页这里不自动 restorePurchases，避免每次进入页面都重复发放旧订单金币
      // 如需“恢复购买”功能可以单独做按钮手动触发
    } catch (e) {
      debugPrint('CoinsLogic: init IAP error: $e');
    }
  }

  /// 从服务器加载商品列表并转换为 UI 结构
  Future<void> _loadGoodsList() async {
    _loadDefaultPackages();

    isLoading.value = true;
    try {
      // 根据平台选择支付通道
      String payChannel = 'IAP';
      if (Platform.isAndroid) {
        payChannel = 'GP';
      }

      final goodsList = await _coinService.getGoodsList(
        payChannel: payChannel,
        isIncludeSubscription: false,
      );

      if (goodsList.isNotEmpty) {
        packages.value = _convertGoodsToPackages(goodsList);
        update(['packages_list']);
      }
    } catch (e) {
      debugPrint('CoinsLogic: load goods error: $e');
      await _loadUserCoins();
    } finally {
      isLoading.value = false;

      if (storeAvailable.value && packages.isNotEmpty) {
        _queryProducts();
      }
    }
  }

  /// 把服务端商品结构映射到 CoinsPage 使用的 Map 结构
  List<Map<String, dynamic>> _convertGoodsToPackages(
    List<Map<String, dynamic>> goodsList,
  ) {
    return goodsList.map((product) {
      // 兼容 Paech/通用 CoinService 的字段
      final int baseCoins = (product['exchangeCoin'] as int?) ?? 0;
      final int extraCoins = (product['extraCoin'] as int?) ?? 0;
      final int coins = baseCoins + extraCoins;

      final double price = (product['price'] as num?)?.toDouble() ?? 0.0;
      final double? originalPrice =
          (product['originalPrice'] as num?)?.toDouble();

      final String goodsCode = product['code']?.toString() ??
          product['goodsCode']?.toString() ??
          '';

      final bool isPromotion = product['isPromotion'] as bool? ?? false;
      final int? discountPercent = product['discount'] as int?;

      final String priceStr = '\$${price.toStringAsFixed(2)}';
      final String originalPriceStr =
          originalPrice != null ? '\$${originalPrice.toStringAsFixed(2)}' : '';
      final String discountStr =
          discountPercent != null ? '${discountPercent}% OFF' : '';

      return {
        'coins': coins,
        'price': priceStr,
        'originalPrice': originalPriceStr,
        'discount': discountStr,
        'popular': isPromotion,
        'goodsCode': goodsCode,
      };
    }).toList();
  }

  /// 本地兜底商品列表（与原实现保持一致）
  void _loadDefaultPackages() {
    packages.value = [
      {
        'coins': 99,
        'price': '\$0.99',
        'originalPrice': '',
        'discount': '',
        'popular': false,
        'goodsCode': '264300',
      },
      {
        'coins': 399,
        'price': '\$3.99',
        'originalPrice': '',
        'discount': '',
        'popular': false,
        'goodsCode': '264301',
      },
      {
        'coins': 500,
        'price': '\$4.99',
        'originalPrice': '',
        'discount': '',
        'popular': false,
        'goodsCode': '264312',
      },
      {
        'coins': 700,
        'price': '\$6.99',
        'originalPrice': '',
        'discount': '',
        'popular': false,
        'goodsCode': '264313',
      },
      {
        'coins': 1200,
        'price': '\$9.99',
        'originalPrice': '',
        'discount': '',
        'popular': false,
        'goodsCode': '264302',
      },
      {
        'coins': 2400,
        'price': '\$19.99',
        'originalPrice': '',
        'discount': '',
        'popular': false,
        'goodsCode': '264303',
      },
      {
        'coins': 7000,
        'price': '\$49.99',
        'originalPrice': '',
        'discount': '',
        'popular': false,
        'goodsCode': '264304',
      },
      {
        'coins': 15000,
        'price': '\$99.99',
        'originalPrice': '',
        'discount': '',
        'popular': false,
        'goodsCode': '264305',
      },
      {
        'coins': 298,
        'price': '\$0.99',
        'originalPrice': '\$1.99',
        'discount': '50% OFF',
        'popular': false,
        'goodsCode': '264306',
      },
      {
        'coins': 750,
        'price': '\$2.99',
        'originalPrice': '\$4.99',
        'discount': '40% OFF',
        'popular': false,
        'goodsCode': '264307',
      },
      {
        'coins': 1199,
        'price': '\$4.99',
        'originalPrice': '\$9.99',
        'discount': '50% OFF',
        'popular': true,
        'goodsCode': '264308',
      },
      {
        'coins': 2599,
        'price': '\$12.99',
        'originalPrice': '\$19.99',
        'discount': '35% OFF',
        'popular': false,
        'goodsCode': '264309',
      },
      {
        'coins': 10000,
        'price': '\$49.99',
        'originalPrice': '\$69.99',
        'discount': '30% OFF',
        'popular': false,
        'goodsCode': '264310',
      },
      {
        'coins': 17888,
        'price': '\$99.99',
        'originalPrice': '\$129.99',
        'discount': '23% OFF',
        'popular': false,
        'goodsCode': '264311',
      },
    ];
    update(['packages_list']);
  }

  /// 查询 IAP 商品信息（goodsCode 即 productId）
  Future<void> _queryProducts() async {
    if (packages.isEmpty) return;

    isLoading.value = true;
    try {
      final ids = packages
          .map((p) => p['goodsCode']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      if (ids.isEmpty) return;

      debugPrint('CoinsLogic: queryProductDetails $ids');
      final resp = await _iap.queryProductDetails(ids);
      hasQueriedProducts.value = true;

      if (resp.error != null) {
        debugPrint('CoinsLogic: IAP query error ${resp.error!.message}');
      }

      productsById.assignAll({
        for (final p in resp.productDetails) p.id: p,
      });
    } catch (e) {
      debugPrint('CoinsLogic: queryProducts error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 点击某个金币档位发起购买
  Future<void> onRecharge(int coins, String goodsCode) async {
    if (isLoadingCoins.value) {
      Get.snackbar(
        'Please Wait',
        'Loading coin balance...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFfbbf24),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (isPurchasing.value) {
      Get.snackbar(
        'Please Wait',
        'A purchase is already in progress.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFfbbf24),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // 确保 IAP 可用
    if (!storeAvailable.value) {
      await _initIap();
      if (!storeAvailable.value) {
        Get.snackbar(
          'Not Available',
          'In-app purchase is not available on this device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFef4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }
    }

    try {
      isPurchasing.value = true;

      // 从本地缓存获取 IAP 商品信息
      ProductDetails? product = productsById[goodsCode];
      if (product == null && !hasQueriedProducts.value) {
        await _queryProducts();
        product = productsById[goodsCode];
      }

      if (product == null) {
        isPurchasing.value = false;
        Get.snackbar(
          'Product Not Found',
          'This product is not available. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFef4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      debugPrint(
          'CoinsLogic: start purchase product=${product.id}, price=${product.price}');

      final param = PurchaseParam(productDetails: product);
      final success =
          await _iap.buyConsumable(purchaseParam: param, autoConsume: true);

      debugPrint('CoinsLogic: buyConsumable success=$success');

      if (!success) {
        isPurchasing.value = false;
        Get.snackbar(
          'Error',
          'Failed to initiate purchase. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFef4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // 等待 _onPurchaseUpdated 里真正发币
      _purchaseTimeoutTimer?.cancel();
      _purchaseTimeoutTimer = Timer(const Duration(seconds: 60), () {
        if (isPurchasing.value) {
          isPurchasing.value = false;
          Get.snackbar(
            'Purchase Timeout',
            'The purchase took too long. Please check your purchase history.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFef4444),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      });
    } on PlatformException catch (e) {
      final msg = e.message ?? e.code;
      debugPrint('CoinsLogic: PlatformException during purchase: $msg');
      isPurchasing.value = false;
      Get.snackbar(
        'Purchase Error',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      try {
        await _iap.restorePurchases();
      } catch (restoreError) {
        debugPrint('CoinsLogic: restorePurchases error: $restoreError');
      }
    } catch (e) {
      debugPrint('CoinsLogic: Exception during purchase: $e');
      isPurchasing.value = false;
      Get.snackbar(
        'Error',
        'Failed to start purchase: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFef4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// IAP 购买结果回调：支付成功后调后端并加币
  Future<void> _onPurchaseUpdated(
      List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint(
          'CoinsLogic: purchase status=${purchase.status}, productId=${purchase.productID}');

      if (purchase.status == PurchaseStatus.pending) {
        if (!isPurchasing.value) {
          isPurchasing.value = true;
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        final msg =
            purchase.error?.message ?? purchase.error?.code ?? 'Purchase error';
        debugPrint('CoinsLogic: purchase error: $msg');
        isPurchasing.value = false;
        _purchaseTimeoutTimer?.cancel();

        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
          } catch (e) {
            debugPrint(
                'CoinsLogic: error completing failed purchase: $e');
          }
        }

        Get.snackbar(
          'Purchase Failed',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFef4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        debugPrint('CoinsLogic: purchase canceled by user');
        isPurchasing.value = false;
        _purchaseTimeoutTimer?.cancel();

        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
          } catch (e) {
            debugPrint(
                'CoinsLogic: error completing canceled purchase: $e');
          }
        }
        continue;
      }

      // restored 在金币页不再自动重新发放金币，只做清理
      if (purchase.status == PurchaseStatus.restored) {
        debugPrint('CoinsLogic: restored purchase, ignore coins grant');
        if (purchase.pendingCompletePurchase) {
          try {
            await _iap.completePurchase(purchase);
          } catch (e) {
            debugPrint(
                'CoinsLogic: error completing restored purchase: $e');
          }
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased) {
        final productId = purchase.productID;
        if (_processedPurchaseIds.contains(productId)) {
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          continue;
        }
        _processedPurchaseIds.add(productId);

        // 根据 productId 找对应档位
        Map<String, dynamic>? pack;
        for (final p in packages) {
          if (p['goodsCode'] == productId) {
            pack = p;
            break;
          }
        }

        if (pack == null) {
          debugPrint('CoinsLogic: pack not found for productId=$productId');
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          isPurchasing.value = false;
          _purchaseTimeoutTimer?.cancel();
          continue;
        }

        final int coins = pack['coins'] as int? ?? 0;

        try {
          String payChannel = 'IAP';
          if (Platform.isAndroid) {
            payChannel = 'GP';
          }

          await _coinService.createRechargeOrder(
            goodsCode: pack['goodsCode'] as String,
            payChannel: payChannel,
            entry: 'coins_page',
          );

          await _addCoinsToUser(coins);

          Get.snackbar(
            'Purchase Successful',
            '+$coins coins added to your account',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10b981),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        } catch (e) {
          debugPrint(
              'CoinsLogic: createRechargeOrder or addCoins error: $e');
          await _addCoinsToUser(coins);
          Get.snackbar(
            'Purchase Successful',
            '+$coins coins added to your account',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10b981),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }

        isPurchasing.value = false;
        _purchaseTimeoutTimer?.cancel();
      }
    }
  }

  /// 发放金币到本地余额 + PublishLogic
  Future<void> _addCoinsToUser(int coins) async {
    if (coins <= 0) return;

    try {
      userCoins.value += coins;
      await _saveUserCoins();

      if (Get.isRegistered<PublishLogic>()) {
        try {
          final publishLogic = Get.find<PublishLogic>();
          publishLogic.userCoins.value = userCoins.value;
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('CoinsLogic: error adding coins to user: $e');
    }
  }
}

