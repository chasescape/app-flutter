import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'coins_manager.dart';

enum IAPResult { success, error, canceled }

class PurchaseResult {
  final IAPResult result;
  final String? message;
  final int? coins;

  const PurchaseResult({
    required this.result,
    this.message,
    this.coins,
  });
}

class PurchaseService {
  PurchaseService._();

  static final PurchaseService _instance = PurchaseService._();
  static PurchaseService get instance => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// 订单号 -> 商品ID
  final Map<String, String> _orderProductMap = {};
  /// 商品ID -> 对应金币数
  final Map<String, int> _orderCoinsMap = {};
  /// 当前购买结果回调
  void Function(PurchaseResult)? _resultHandler;

  bool _available = false;
  bool get isAvailable => _available;

  /// 初始化内购服务，应在进入商店页时调用
  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('[PurchaseService] In-app purchase not available on this device');
      return;
    }

    // 监听购买流
    final purchaseStream = _iap.purchaseStream;
    _subscription = purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('[PurchaseService] Purchase stream error: $error');
      },
    );

    // 恢复未完成的购买
    await _iap.restorePurchases();
  }

  /// 执行购买
  /// [productId] 商品ID（App Store Connect / Google Play 配置的商品ID）
  /// [coins] 该商品对应的金币数量
  /// [onResult] 购买结果回调
  Future<void> executePurchase({
    required String productId,
    required int coins,
    required void Function(PurchaseResult) onResult,
  }) async {
    if (!_available) {
      onResult(const PurchaseResult(
        result: IAPResult.error,
        message: 'In-app purchase is not available',
      ));
      return;
    }

    _resultHandler = onResult;
    _orderCoinsMap[productId] = coins;

    try {
      // 查询商品详情
      final response = await _iap.queryProductDetails({productId});
      if (response.notFoundIDs.isNotEmpty) {
        _orderCoinsMap.remove(productId);
        _resultHandler = null;
        onResult(const PurchaseResult(
          result: IAPResult.error,
          message: 'Product not found',
        ));
        return;
      }
      if (response.productDetails.isEmpty) {
        _orderCoinsMap.remove(productId);
        _resultHandler = null;
        onResult(const PurchaseResult(
          result: IAPResult.error,
          message: 'No product details available',
        ));
        return;
      }

      final productDetails = response.productDetails.first;

      // 生成订单号
      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      _orderProductMap[orderId] = productId;

      // 调用非消耗品购买
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: productDetails,
        ),
      );
    } catch (e) {
      debugPrint('[PurchaseService] Purchase error: $e');
      _orderCoinsMap.remove(productId);
      _resultHandler = null;
      onResult(PurchaseResult(
        result: IAPResult.error,
        message: 'Purchase failed: $e',
      ));
    }
  }

  /// 处理购买状态更新
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      _handlePurchaseDetail(purchaseDetails);
    }
  }

  Future<void> _handlePurchaseDetail(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final productId = purchaseDetails.productID;
        final coins = _orderCoinsMap[productId];
        if (coins != null) {
          await CoinsManager.instance.addCoins(coins);
          _orderCoinsMap.remove(productId);
        }
        // 完成交易（必须调用）
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        _resultHandler?.call(PurchaseResult(
          result: IAPResult.success,
          message: 'Successfully added $coins coins',
          coins: coins,
        ));
        _cleanup();
        break;

      case PurchaseStatus.error:
        final productId = purchaseDetails.productID;
        _orderCoinsMap.remove(productId);
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        _resultHandler?.call(PurchaseResult(
          result: IAPResult.error,
          message: purchaseDetails.error?.message ?? 'Purchase failed',
        ));
        _cleanup();
        break;

      case PurchaseStatus.canceled:
        final productId = purchaseDetails.productID;
        _orderCoinsMap.remove(productId);
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        _resultHandler?.call(const PurchaseResult(
          result: IAPResult.canceled,
          message: 'Purchase canceled',
        ));
        _cleanup();
        break;

      case PurchaseStatus.pending:
        // 购买等待中（如家长审批），不做处理
        break;
    }
  }

  void _cleanup() {
    _resultHandler = null;
  }

  /// 释放资源
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _orderProductMap.clear();
    _orderCoinsMap.clear();
    _resultHandler = null;
  }
}
