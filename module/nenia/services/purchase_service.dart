import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class PurchaseService extends GetxService {
  static PurchaseService get to => Get.find<PurchaseService>();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final Map<String, int> _orderCoinsMap = {};
  Function(int coins, bool success)? _resultHandler;
  String? _activeProductId;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<void> addCoinsCallback(int coins) async {
    if (_resultHandler != null) {
      _resultHandler!(coins, true);
      _resultHandler = null;
    }
  }

  Future<void> notifyPurchaseFailed(String error) async {
    if (_resultHandler != null) {
      _resultHandler!(0, false);
      _resultHandler = null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initPurchaseListener();
  }

  void _initPurchaseListener() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;

    _subscription = purchaseUpdated.listen(
      _handlePurchaseUpdates,
      onDone: _updateStreamOnDone,
      onError: _handlePurchaseError,
    );
  }

  Future<void> executePurchase(
    String productId,
    int coins,
    Function(int coins, bool success) onResult,
  ) async {
    if (_activeProductId == productId) {
      return;
    }

    if (!await isAvailable()) {
      onResult(0, false);
      return;
    }

    await _clearPendingIosTransactions(productId: productId);

    _activeProductId = productId;
    _orderCoinsMap[productId] = coins;
    _resultHandler = onResult;

    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails({productId});
      if (response.notFoundIDs.contains(productId)) {
        onResult(0, false);
        _orderCoinsMap.remove(productId);
        _activeProductId = null;
        return;
      }

      if (response.productDetails.isEmpty) {
        onResult(0, false);
        _orderCoinsMap.remove(productId);
        _activeProductId = null;
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;
      await _startConsumablePurchase(
        productDetails,
        productId: productId,
      );
    } catch (e) {
      debugPrint('Purchase error: $e');
      onResult(0, false);
      _orderCoinsMap.remove(productId);
      _activeProductId = null;
    }
  }

  Future<void> _startConsumablePurchase(
    ProductDetails productDetails, {
    required String productId,
    bool hasRetried = false,
  }) async {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);

    try {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      if (_isDuplicatePendingPurchaseError(e) && !hasRetried) {
        await _clearPendingIosTransactions(productId: productId);
        await _startConsumablePurchase(
          productDetails,
          productId: productId,
          hasRetried: true,
        );
        return;
      }
      rethrow;
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    final int? coins = _orderCoinsMap[purchaseDetails.productID];

    switch (purchaseDetails.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        if (coins != null && _resultHandler != null) {
          await addCoinsCallback(coins);
        }
        _orderCoinsMap.remove(purchaseDetails.productID);
        _activeProductId = null;
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        break;

      case PurchaseStatus.error:
        if (_resultHandler != null) {
          await notifyPurchaseFailed(
            purchaseDetails.error?.message ?? 'Purchase failed',
          );
        }
        _orderCoinsMap.remove(purchaseDetails.productID);
        _activeProductId = null;
        await _clearPendingIosTransactions(productId: purchaseDetails.productID);
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        break;

      case PurchaseStatus.canceled:
        if (_resultHandler != null) {
          await notifyPurchaseFailed('Purchase canceled');
        }
        _orderCoinsMap.remove(purchaseDetails.productID);
        _activeProductId = null;
        await _clearPendingIosTransactions(productId: purchaseDetails.productID);
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        break;

      case PurchaseStatus.pending:
        break;
    }
  }

  Future<void> _clearPendingIosTransactions({String? productId}) async {
    if (!Platform.isIOS) {
      return;
    }

    try {
      _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final transaction in transactions) {
        final matchesProduct = productId == null ||
            transaction.payment.productIdentifier == productId;
        if (!matchesProduct) {
          continue;
        }

        final state = transaction.transactionState;
        final canFinish = state == SKPaymentTransactionStateWrapper.failed ||
            state == SKPaymentTransactionStateWrapper.purchased ||
            state == SKPaymentTransactionStateWrapper.restored;

        if (canFinish) {
          await SKPaymentQueueWrapper().finishTransaction(transaction);
        }
      }
    } catch (e) {
      debugPrint('Failed to clear iOS pending transactions: $e');
    }
  }

  bool _isDuplicatePendingPurchaseError(Object error) {
    return error.toString().contains('storekit_duplicate_product_object');
  }

  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  void _handlePurchaseError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
