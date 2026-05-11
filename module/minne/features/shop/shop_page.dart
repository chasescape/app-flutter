import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/utils/app_overlay.dart';
import '../../core/models/user_model.dart';
import '../../services/purchase_service.dart';
import '../../services/coins_manager.dart';
import 'contact_coins.dart';

/// Shop Page - Coin Store
/// Allows users to purchase virtual coins with different packages
/// Integrated with real in-app purchase via PurchaseService
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  static const Color _berryPrimary = Color(0xFF8F355B);
  static const Color _berrySecondary = Color(0xFFB06A84);
  static const Color _pageTop = Color(0xFFFFEAF4);
  static const Color _pageMid = Color(0xFFFFD7E7);
  static const Color _pageBottom = Color(0xFFFFF5DF);

  final UserState _userState = UserState();
  final CoinsManager _coinsManager = CoinsManager();
  final PurchaseService _purchaseService = PurchaseService();

  bool _isPurchaseInProgress = false;

  @override
  void initState() {
    super.initState();
    _initializePurchaseService();
  }

  @override
  void dispose() {
    // Don't dispose PurchaseService as it's a singleton
    // Don't dispose CoinsManager as it's a singleton
    super.dispose();
  }

  /// Initialize purchase service and set up add coins callback
  Future<void> _initializePurchaseService() async {
    final bool initialized = await _purchaseService.initialize(
      productIds: Privatised236CoinProductData.allProducts
          .map((product) => product.goodsId)
          .toSet(),
    );

    if (!initialized) {
      debugPrint('ShopPage: Purchase service initialization failed');
      // Could show a warning to user here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: _pageTop,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _berryPrimary),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          'Coin Shop',
          style: TextStyle(
            color: _berryPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _buildBalanceBadge(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_pageTop, _pageMid, _pageBottom],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView.builder(
            padding: AppSpacing.paddingMD,
            itemCount: Privatised236CoinProductData.allProductsGrouped.length,
            itemBuilder: (context, index) {
              return _buildCoinPackage(
                Privatised236CoinProductData.allProductsGrouped[index],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceBadge() {
    return ValueListenableBuilder<int>(
      valueListenable: _coinsManager.coinsNotifier,
      builder: (context, coins, child) {
        return ClipRRect(
          borderRadius: AppBorderRadius.borderRadiusMD,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.34),
              borderRadius: AppBorderRadius.borderRadiusMD,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.52),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD7E7).withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: _berryPrimary,
                  size: 18,
                ),
                AppSpacing.gapSM,
                Text(
                  '$coins',
                  style: AppTextStyles.bodyMediumStyle.copyWith(
                    color: _berryPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoinPackage(Contact575CoinProduct package) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ClipRRect(
        borderRadius: AppBorderRadius.borderRadiusLG,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.white.withValues(alpha: 0.28),
            borderRadius: AppBorderRadius.borderRadiusLG,
            child: InkWell(
              onTap: _isPurchaseInProgress ? null : () => _purchasePackage(package),
              borderRadius: AppBorderRadius.borderRadiusLG,
              child: Opacity(
                opacity: _isPurchaseInProgress ? 0.5 : 1.0,
                child: Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.borderRadiusLG,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.34),
                        Colors.white.withValues(alpha: 0.14),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD1DE).withValues(alpha: 0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                  // Coin icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB6CF), Color(0xFFFFDC88)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC0B2).withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.monetization_on,
                        color: _berryPrimary,
                        size: 32,
                      ),
                    ),
                  ),

                  AppSpacing.gapMD,

                  // Package info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${package.exchangeCoin} Coins',
                          style: AppTextStyles.h3Style.copyWith(
                            color: _berryPrimary,
                          ),
                        ),
                        AppSpacing.gapXS,
                        Text(
                          package.description,
                          style: AppTextStyles.captionStyle.copyWith(
                            color: _berrySecondary,
                          ),
                        ),
                        if (package.originalPrice != null) ...[
                          AppSpacing.gapXS,
                          Text(
                            package.formattedOriginalPrice!,
                            style: AppTextStyles.captionStyle.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ],
                        AppSpacing.gapXS,
                        Text(
                          package.formattedPrice,
                          style: AppTextStyles.bodyStyle.copyWith(
                            color: _berryPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (package.isPromotion) ...[
                          AppSpacing.gapXS,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF0B8),
                              borderRadius: AppBorderRadius.borderRadiusSM,
                            ),
                            child: Text(
                              'Save ${package.discountPercentage}%',
                              style: AppTextStyles.smallStyle.copyWith(
                                color: _berryPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  AppSpacing.gapMD,

                  // Buy button
                  ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isPurchaseInProgress
                              ? [Colors.grey.shade300, Colors.grey.shade400]
                              : [
                                  Colors.white.withValues(alpha: 0.42),
                                  Colors.white.withValues(alpha: 0.2),
                                ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.58),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF98B8).withValues(alpha: 0.2),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isPurchaseInProgress ? null : () => _purchasePackage(package),
                            borderRadius: BorderRadius.circular(25),
                            child: Center(
                              child: _isPurchaseInProgress
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Go',
                                    style: TextStyle(
                                      color: _berryPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _purchasePackage(Contact575CoinProduct package) async {
    if (_isPurchaseInProgress) return;

    // Check if purchase service is available
    if (!_purchaseService.isAvailable) {
      return;
    }

    setState(() {
      _isPurchaseInProgress = true;
    });

    // Get product ID based on coins amount
    final String productId = package.goodsId;
    final int totalCoins = package.exchangeCoin;

    // Execute purchase via PurchaseService
    await _purchaseService.executePurchase(
      productId: productId,
      coins: totalCoins,
      onResult: (success, productId, coins, error) async {
        if (!mounted) {
          return;
        }

        if (success && coins != null) {
          // Add coins to CoinsManager
          await _coinsManager.addCoins(coins);

          if (!mounted) {
            return;
          }

          // Also update UserState for backward compatibility
          _userState.updateCoins(coins);

          await AppOverlay.showFrostedNoticeSheet(
            context,
            message: 'Purchase successful! +$coins coins',
            type: ToastType.success,
          );
        }

        setState(() {
          _isPurchaseInProgress = false;
        });
      },
    );
  }
}
