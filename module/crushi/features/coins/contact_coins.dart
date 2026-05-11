class Contact575CoinProduct {
  final String code;
  final String goodsId;
  final String name;
  final String description;
  final double price;
  final int exchangeCoin;
  final bool isPromotion;
  final double? originalPrice;

  const Contact575CoinProduct({
    required this.code,
    required this.goodsId,
    required this.name,
    required this.description,
    required this.price,
    required this.exchangeCoin,
    required this.isPromotion,
    this.originalPrice,
  });

  int get discountPercentage {
    final o = originalPrice;
    if (!isPromotion || o == null || o <= 0) return 0;
    final pct = (1 - (price / o)) * 100;
    return pct.isNaN || pct.isInfinite ? 0 : pct.round().clamp(0, 95);
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    final o = originalPrice;
    if (!isPromotion || o == null) return null;
    return '\$${o.toStringAsFixed(2)}';
  }

  double get coinsPerDollar => price <= 0 ? 0 : exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '281400',
      goodsId: '281400',
      name: 'Crushi Coin Pack0',
      description: '100 coins - Pack',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '281412',
      goodsId: '281412',
      name: 'Crushi Coin Pack12',
      description: 'Coins Pack',
      price: 4.99,
      exchangeCoin: 500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '281401',
      goodsId: '281401',
      name: 'Crushi Coin Pack1',
      description: '599 coins - Pack',
      price: 5.99,
      exchangeCoin: 599,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '281413',
      goodsId: '281413',
      name: 'Crushi Coin Pack13',
      description: 'Coins Pack',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '281402',
      goodsId: '281402',
      name: 'Crushi Coin Pack2',
      description: '1199 coins - Pack',
      price: 9.99,
      exchangeCoin: 1199,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '281403',
      goodsId: '281403',
      name: 'Crushi Coin Pack3',
      description: '2400 coins - Pack',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '281404',
      goodsId: '281404',
      name: 'Crushi Coin Pack4',
      description: '7000 coins - Pack',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '281405',
      goodsId: '281405',
      name: 'Crushi Coin Pack5',
      description: '15000 coins - Pack',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '281406',
      goodsId: '281406',
      name: 'Crushi Coin Pack6',
      description: 'Limited Time: 298 coins',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.95,
    ),
    Contact575CoinProduct(
      code: '281407',
      goodsId: '281407',
      name: 'Crushi Coin Pack7',
      description: 'Limited Time: 749 coins',
      price: 2.99,
      exchangeCoin: 749,
      isPromotion: true,
      originalPrice: 7.47,
    ),
    Contact575CoinProduct(
      code: '281408',
      goodsId: '281408',
      name: 'Crushi Coin Pack8',
      description: 'Limited Time: 1200 coins',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 10.00,
    ),
    Contact575CoinProduct(
      code: '281409',
      goodsId: '281409',
      name: 'Crushi Coin Pack9',
      description: 'Limited Time: 2400 coins',
      price: 11.99,
      exchangeCoin: 2400,
      isPromotion: true,
      originalPrice: 19.99,
    ),
    Contact575CoinProduct(
      code: '281410',
      goodsId: '281410',
      name: 'Crushi Coin Pack10',
      description: 'Limited Time: 7000 coins',
      price: 34.99,
      exchangeCoin: 7000,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: '281411',
      goodsId: '281411',
      name: 'Crushi Coin Pack11',
      description: 'Limited Time: 17888 coins',
      price: 99.99,
      exchangeCoin: 17888,
      isPromotion: true,
      originalPrice: 119.25,
    ),
  ];

  static List<Contact575CoinProduct> get allProducts => [
        ...regularProducts,
        ...promotionProducts,
      ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts,
        ...promotionProducts,
      ];
}

