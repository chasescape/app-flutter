import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/state/app_state.dart';
import '../../core/state/state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/dialog_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/tavia_ui.dart';
import '../../shared/constants/app_constants.dart';
import 'contact_coins.dart';

/// Candy-toned coin store with App Store purchases.
class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  static const String _deliveredPurchaseIdsKey =
      'store_delivered_purchase_ids';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  List<Contact575CoinProduct> _packages = [];
  Map<String, ProductDetails> _storeProducts = {};
  Set<String> _missingProductIds = {};
  bool _isLoading = true;
  bool _isStoreAvailable = false;
  bool _isPurchasePending = false;
  String? _storeErrorMessage;

  @override
  void initState() {
    super.initState();
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _purchaseSubscription.cancel(),
      onError: (_) {
        _updatePurchaseLoading(false);
        if (mounted) {
          AppDialog.showErrorDialog(
            context,
            title: 'Purchase error',
            message: 'Unable to read App Store purchase updates right now.',
          );
        }
      },
    );
    _loadPackages();
  }

  @override
  void dispose() {
    _purchaseSubscription.cancel();
    AppDialog.hideLoadingDialog();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    await Future.delayed(const Duration(milliseconds: 180));

    if (!mounted) {
      return;
    }

    setState(() {
      _packages = Privatised236CoinProductData.allProductsGrouped;
      _isLoading = false;
    });

    await _initStoreProducts();
  }

  Future<void> _initStoreProducts() async {
    final ids = _packages.map((item) => item.goodsId).toSet();
    if (ids.isEmpty) {
      return;
    }

    final isAvailable = await _inAppPurchase.isAvailable();
    if (!mounted) {
      return;
    }

    if (!isAvailable) {
      setState(() {
        _isStoreAvailable = false;
        _storeProducts = {};
        _missingProductIds = ids;
        _storeErrorMessage = null;
      });
      return;
    }

    final response = await _inAppPurchase.queryProductDetails(ids);
    if (!mounted) {
      return;
    }

    setState(() {
      _isStoreAvailable = true;
      _storeProducts = {
        for (final product in response.productDetails) product.id: product,
      };
      _missingProductIds = response.notFoundIDs.toSet();
      _storeErrorMessage = response.error?.message;
    });
  }

  Future<void> _purchasePackage(Contact575CoinProduct package) async {
    if (_isPurchasePending) {
      return;
    }

    if (!_isStoreAvailable) {
      return;
    }

    final storeProduct = _storeProducts[package.goodsId];
    if (storeProduct == null) {
      return;
    }

    final started = await _inAppPurchase.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: storeProduct),
      autoConsume: true,
    );

    if (!started) {
      if (mounted) {
        _updatePurchaseLoading(false);
      }
      return;
    }

    _updatePurchaseLoading(true);
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _updatePurchaseLoading(true);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final isValid = await _verifyPurchase(purchase);
          if (isValid) {
            await _deliverPurchase(purchase);
          }
          _updatePurchaseLoading(false);
          break;
        case PurchaseStatus.error:
          _updatePurchaseLoading(false);
          break;
        case PurchaseStatus.canceled:
          _updatePurchaseLoading(false);
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    return purchase.verificationData.localVerificationData.isNotEmpty ||
        purchase.verificationData.serverVerificationData.isNotEmpty;
  }

  Future<void> _deliverPurchase(PurchaseDetails purchase) async {
    final package = _packageForProductId(purchase.productID);
    if (package == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final deliveredIds =
        prefs.getStringList(_deliveredPurchaseIdsKey) ?? <String>[];
    final transactionId = _transactionIdentifierFor(purchase);

    if (deliveredIds.contains(transactionId)) {
      return;
    }

    await prefs.setStringList(
      _deliveredPurchaseIdsKey,
      [transactionId, ...deliveredIds].take(100).toList(),
    );

    AppState().addCoins(package.exchangeCoin);

    if (!mounted) {
      return;
    }

    AppDialog.showToast(
      context,
      message: '${package.exchangeCoin} coins added',
    );
  }

  Contact575CoinProduct? _packageForProductId(String productId) {
    for (final package in _packages) {
      if (package.goodsId == productId) {
        return package;
      }
    }
    return null;
  }

  String _transactionIdentifierFor(PurchaseDetails purchase) {
    return purchase.purchaseID ??
        '${purchase.productID}_${purchase.transactionDate ?? 'unknown'}';
  }

  void _updatePurchaseLoading(bool isPending) {
    if (!mounted || _isPurchasePending == isPending) {
      return;
    }

    setState(() {
      _isPurchasePending = isPending;
    });

    if (isPending) {
      AppDialog.showLoadingDialog(
        context,
        message: 'Connecting to App Store...',
      );
    } else {
      AppDialog.hideLoadingDialog();
    }
  }

  String get _headerSubtitle {
    if (_storeErrorMessage != null && _storeErrorMessage!.isNotEmpty) {
      return 'App Store sync hit an issue. Local cards stay visible, but purchases need valid product IDs to load correctly.';
    }
    if (!_isStoreAvailable) {
      return Platform.isIOS
          ? 'Tap on a real iPhone to test App Store purchases. Simulators usually cannot finish IAP.'
          : 'Store products are currently unavailable on this device.';
    }
    if (_storeProducts.isEmpty) {
      return 'Preparing App Store products...';
    }
    if (_missingProductIds.isNotEmpty) {
      return 'Some products are missing in App Store Connect. Available cards can still be purchased.';
    }
    return 'Tap any card to purchase coins through the App Store.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingMd,
              AppConstants.spacingLg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppConstants.spacingLg),
                _buildBalanceCard(),
                const SizedBox(height: AppConstants.spacingLg),
                Expanded(
                  child: _isLoading
                      ? const LoadingIndicator()
                      : ListView.separated(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.spacingXxl,
                          ),
                          itemBuilder: (context, index) {
                            final package = _packages[index];
                            return _PackageCard(
                              package: package,
                              isAvailable:
                                  _isStoreAvailable &&
                                  _storeProducts.containsKey(package.goodsId),
                              onPurchase: () => _purchasePackage(package),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppConstants.spacingLg),
                          itemCount: _packages.length,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        TaviaIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: TaviaSectionTitle(
            title: 'Coin Shop',
            subtitle: _headerSubtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return StreamCoinBalanceWidget(
      builder: (context, balance) {
        return TaviaPanel(
          color: AppColors.white.withValues(alpha: 0.18),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.candyGlowGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: AppColors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current balance',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white.withValues(alpha: 0.76),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      '$balance Coins',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Contact575CoinProduct package;
  final bool isAvailable;
  final VoidCallback onPurchase;

  const _PackageCard({
    required this.package,
    required this.isAvailable,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isAvailable ? 1 : 0.72,
      child: TaviaPanel(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPurchase,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Row(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.primaryMain,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${package.exchangeCoin} Coins',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        Row(
                          children: [
                            Text(
                              package.formattedPrice,
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primaryMain,
                              ),
                            ),
                            if (package.originalPrice != null) ...[
                              const SizedBox(width: AppConstants.spacingSm),
                              Text(
                                package.formattedOriginalPrice!,
                                style: AppTextStyles.small.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (package.discountPercentage > 0) ...[
                          const SizedBox(height: AppConstants.spacingXs),
                          Text(
                            '-${package.discountPercentage}% off',
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.primaryMain,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (!isAvailable) ...[
                          const SizedBox(height: AppConstants.spacingXs),
                          Text(
                            'Unavailable right now',
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
