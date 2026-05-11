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
    if (originalPrice == null || originalPrice! <= price) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    if (originalPrice == null) return null;
    return '\$${originalPrice!.toStringAsFixed(2)}';
  }

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '292800',
      goodsId: '292800',
      name: 'Wekoo Coin 0',
      description: '100 coins - Regular',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292812',
      goodsId: '292812',
      name: 'Wekoo Coin 12',
      description: 'Regular',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292801',
      goodsId: '292801',
      name: 'Wekoo Coin 1',
      description: '499 coins - Regular',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292813',
      goodsId: '292813',
      name: 'Wekoo Coin 13',
      description: 'Regular',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292802',
      goodsId: '292802',
      name: 'Wekoo Coin 2',
      description: '999 coins - Regular',
      price: 9.99,
      exchangeCoin: 999,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292803',
      goodsId: '292803',
      name: 'Wekoo Coin 3',
      description: '2400 coins - Regular',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292804',
      goodsId: '292804',
      name: 'Wekoo Coin 4',
      description: '7000 coins - Regular',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292805',
      goodsId: '292805',
      name: 'Wekoo Coin 5',
      description: '15000 coins - Regular',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '292806',
      goodsId: '292806',
      name: 'Wekoo Coin 6',
      description: '298 coins - Hot Sale',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '292807',
      goodsId: '292807',
      name: 'Wekoo Coin 7',
      description: '749 coins - Hot Sale',
      price: 2.99,
      exchangeCoin: 749,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: '292808',
      goodsId: '292808',
      name: 'Wekoo Coin 8',
      description: '1198 coins - Hot Sale',
      price: 4.99,
      exchangeCoin: 1198,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '292809',
      goodsId: '292809',
      name: 'Wekoo Coin 9',
      description: '2399 coins - Hot Sale',
      price: 11.99,
      exchangeCoin: 2399,
      isPromotion: true,
      originalPrice: 18.99,
    ),
    Contact575CoinProduct(
      code: '292810',
      goodsId: '292810',
      name: 'Wekoo Coin 10',
      description: '10000 coins - Hot Sale',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: '292811',
      goodsId: '292811',
      name: 'Wekoo Coin 11',
      description: '14998 coins - Hot Sale',
      price: 79.99,
      exchangeCoin: 14998,
      isPromotion: true,
      originalPrice: 99.99,
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
