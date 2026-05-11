import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:senxo/gen_a/A.dart';
import '../../core/services/coin_service.dart';
import '../../shared/widgets/common/gradient_background.dart';
import 'coins_logic.dart';

class CoinsPage extends StatelessWidget {
  CoinsPage({super.key});

  final CoinsLogic logic = Get.put(CoinsLogic());
  final CoinService _coinService = Get.find<CoinService>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.chevron_left, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Recharge Coins',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildCoinsPage(),
            ),
            // Fixed Purchase Button at Bottom
            _buildFixedPurchaseButton(),
          ],
        ),
      ),
        ),
        // 购买中的 loading 动画
        Obx(() => logic.isPurchasing.value ? _buildPurchaseLoadingOverlay() : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildPurchaseLoadingOverlay() {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: Lottie.asset(
        A.assets_loading_loading,
        width: 120.w,
        height: 120.w,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildCoinsPage() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Current Balance Card
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: _buildBalanceCard(),
        ),

        // Recharge Packages Title
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'Select Package',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Discount Toggle Buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Obx(() => Row(
                children: [
                  _buildToggleButton('Regular', false),
                  SizedBox(width: 12.w),
                  _buildToggleButton('Discount', true),
                ],
              )),
        ),

        SizedBox(height: 16.h),

        // Scrollable Package List
        Obx(() => _buildPackageList()),

        SizedBox(height: 100.h),
      ],
    );
  }

  // Toggle Button
  Widget _buildToggleButton(String label, bool isDiscount) {
    final isSelected = logic.showDiscount.value == isDiscount;
    return GestureDetector(
      onTap: () => logic.toggleDiscount(isDiscount),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFFDAE0),
                    Color(0xFFFFF4DC),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Package List
  Widget _buildPackageList() {
    final packages = logic.currentPackages;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: List.generate(packages.length, (index) {
          final package = packages[index];
          final isPromotion = logic.showDiscount.value;
          
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildPackageCard(
              coins: package['coins'],
              originalPrice: isPromotion ? '\$${package['originalPrice']?.toStringAsFixed(2)}' : null,
              discountPrice: '\$${package['price'].toStringAsFixed(2)}',
              discount: isPromotion ? package['discount'] : null,
              description: package['description'],
              index: index,
            ),
          );
        }),
      ),
    );
  }

  // Balance Card
  Widget _buildBalanceCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFDAE0),
            Color(0xFFFFF4DC),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFDAE0).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Balance',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.coins,
                size: 32.sp,
                color: Colors.black87,
              ),
              SizedBox(width: 12.w),
              Obx(() => Text(
                '${_coinService.coins}',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Coins',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Package Card
  Widget _buildPackageCard({
    required int coins,
    String? originalPrice,
    required String discountPrice,
    String? discount,
    String? description,
    required int index,
  }) {
    return Obx(() {
      final isSelected = logic.selectedPackage.value == index;
      return GestureDetector(
        onTap: () => logic.selectPackage(index),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFF9FB)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFB6C1)
                      : Colors.grey[200]!,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFFFB6C1).withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSelected ? 15 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Coin Icon
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDAE0).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      LucideIcons.coins,
                      size: 28.sp,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Coin Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$coins',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Coins',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (description != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (originalPrice != null) ...[
                        Text(
                          originalPrice,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                      Text(
                        discountPrice,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Discount Badge - positioned outside the card
            if (discount != null)
              Positioned(
                top: -6.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF5252),
                        Color(0xFFFF8A80),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    discount,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }


  // Fixed Purchase Button at Bottom
  Widget _buildFixedPurchaseButton() {
    return Obx(() {
      final isVisible = logic.selectedPackage.value != -1;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isVisible ? null : 0,
        child: isVisible
            ? Container(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: GestureDetector(
                    onTap: () => logic.purchasePackage(),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFDAE0),
                            Color(0xFFFFF4DC),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFDAE0).withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.shopping_cart,
                              size: 20.sp, color: Colors.black87),
                          SizedBox(width: 8.w),
                          Text(
                            'Purchase Now',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }
}
