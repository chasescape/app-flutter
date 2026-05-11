import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'contact_coins.dart';
import '../../services/coin_manager.dart';
import '../../services/purchase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  bool _isPurchasing = false;

  List<Contact575CoinProduct> get _products =>
      Privatised236CoinProductData.allProductsGrouped;

  @override
  void initState() {
    super.initState();
    PurchaseService.to.setAddCoinsCallback(CoinManager.to.addCoins);
  }

  String _getDisplayPrice(Contact575CoinProduct product) {
    return product.formattedPrice;
  }

  void _purchasePackage(Contact575CoinProduct product) {
    if (_isPurchasing) return;
    _executePurchase(product);
  }

  void _executePurchase(Contact575CoinProduct product) {
    setState(() => _isPurchasing = true);
    PurchaseService.to.executePurchase(
      productId: product.code,
      coins: product.exchangeCoin,
      onResult: (_, __) {
        if (!mounted) return;
        setState(() => _isPurchasing = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DreamScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text('Coin Boutique'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 110, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CoinsWalletCard(),
                const SizedBox(height: 18),
                const _CoinsSectionHeader(),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return _PackageCard(
                      product: product,
                      price: _getDisplayPrice(product),
                      onTap: () => _purchasePackage(product),
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isPurchasing)
            Container(
              color: Colors.white.withValues(alpha: 0.62),
              child: const Center(
                child: PulseLoading(message: 'Completing your purchase...'),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoinsSectionHeader extends StatelessWidget {
  const _CoinsSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your coins',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Top up your balance and keep creating.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                height: 1.2,
              ),
        ),
      ],
    );
  }
}

class _CoinsWalletCard extends StatelessWidget {
  const _CoinsWalletCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF35CAC),
            Color(0xFFB98AFF),
            Color(0xFF95C9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2EA35BD8),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: 6,
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.textOnDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Coins',
                    style: TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Obx(
                () => Text(
                  '${CoinManager.to.coins.value}',
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Available balance',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Contact575CoinProduct product;
  final String price;
  final VoidCallback onTap;

  const _PackageCard({
    required this.product,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      borderColor:
          product.isPromotion ? AppColors.secondary : AppColors.borderSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.isPromotion)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Text(
                'LIMITED TIME',
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          if (!product.isPromotion) const SizedBox(height: 0),
          const Icon(Icons.diamond_rounded, color: AppColors.secondary, size: 26),
          const SizedBox(height: 6),
          Text(
            '${product.exchangeCoin} coins',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (product.isPromotion && product.formattedOriginalPrice != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                product.formattedOriginalPrice!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
          Text(
            price,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
