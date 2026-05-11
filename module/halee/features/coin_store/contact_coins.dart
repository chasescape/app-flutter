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
    final original = originalPrice;
    if (!isPromotion || original == null || original <= 0 || price <= 0) return 0;
    final discount = (1 - (price / original)) * 100;
    return discount.isNaN || discount.isInfinite ? 0 : discount.round().clamp(0, 99);
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    final original = originalPrice;
    if (!isPromotion || original == null) return null;
    return '\$${original.toStringAsFixed(2)}';
  }

  double get coinsPerDollar => price <= 0 ? 0 : exchangeCoin / price;
}

class Privatised236CoinProductData {
  // Order strictly follows `project.json` (regular first, promotion second).
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '285000',
      goodsId: '285000',
      name: 'Halee Vault0',
      description: 'Standard Price: 99 coins',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285012',
      goodsId: '285012',
      name: 'Halee Vault12',
      description: 'Standard Price',
      price: 3.99,
      exchangeCoin: 400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285001',
      goodsId: '285001',
      name: 'Halee Vault1',
      description: 'Standard Price: 500 coins',
      price: 4.99,
      exchangeCoin: 500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285013',
      goodsId: '285013',
      name: 'Halee Vault13',
      description: 'Standard Price',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285002',
      goodsId: '285002',
      name: 'Halee Vault2',
      description: 'Standard Price: 1200 coins',
      price: 9.99,
      exchangeCoin: 1200,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285003',
      goodsId: '285003',
      name: 'Halee Vault3',
      description: 'Standard Price: 2500 coins',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285004',
      goodsId: '285004',
      name: 'Halee Vault4',
      description: 'Standard Price: 7000 coins',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285005',
      goodsId: '285005',
      name: 'Halee Vault5',
      description: 'Standard Price: 15000 coins',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '285006',
      goodsId: '285006',
      name: 'Halee Vault6',
      description: '298 coins - Limited Deal',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '285007',
      goodsId: '285007',
      name: 'Halee Vault7',
      description: '500 coins - Limited Deal',
      price: 1.99,
      exchangeCoin: 500,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '285008',
      goodsId: '285008',
      name: 'Halee Vault8',
      description: '1200 coins - Limited Deal',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    // These three entries are derived from the raw `project.json` rows where fields are
    // shifted; we infer the intended `coins` and `price` from the text values.
    Contact575CoinProduct(
      code: '285009',
      goodsId: '285009',
      name: 'Halee Vault9',
      description: '2599 coins - Limited',
      price: 12.99,
      exchangeCoin: 2599,
      isPromotion: true,
      originalPrice: 19.99,
    ),
    Contact575CoinProduct(
      code: '285010',
      goodsId: '285010',
      name: 'Halee Vault10',
      description: '6999 coins - Limited',
      price: 34.99,
      exchangeCoin: 6999,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: '285011',
      goodsId: '285011',
      name: 'Halee Vault11',
      description: '18000 coins -',
      price: 99.99,
      exchangeCoin: 18000,
      isPromotion: true,
      originalPrice: 199.99,
    ),
  ];

  static List<Contact575CoinProduct> get allProducts => [
        ...regularProducts,
        ...promotionProducts,
      ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts, // 常规商品在前
        ...promotionProducts, // 促销商品在后
      ];
}

