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
    this.isPromotion = false,
    this.originalPrice,
  });

  int get discountPercentage {
    final value = originalPrice;
    if (!isPromotion || value == null || value <= 0 || value <= price) {
      return 0;
    }

    return (((value - price) / value) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    final value = originalPrice;
    if (!isPromotion || value == null || value <= 0) {
      return null;
    }

    return '\$${value.toStringAsFixed(2)}';
  }

  String get formattedCoins => '$exchangeCoin Coins';

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '292700',
      goodsId: '292700',
      name: 'Pekko Prime0',
      description: '99 coins - Normal Edition',
      price: 0.99,
      exchangeCoin: 99,
    ),
    Contact575CoinProduct(
      code: '292712',
      goodsId: '292712',
      name: 'Pekko Prime12',
      description: 'Normal Edition',
      price: 3.99,
      exchangeCoin: 399,
    ),
    Contact575CoinProduct(
      code: '292701',
      goodsId: '292701',
      name: 'Pekko Prime1',
      description: '599 coins - Normal Edition',
      price: 5.99,
      exchangeCoin: 599,
    ),
    Contact575CoinProduct(
      code: '292713',
      goodsId: '292713',
      name: 'Pekko Prime13',
      description: 'Normal Edition',
      price: 6.99,
      exchangeCoin: 699,
    ),
    Contact575CoinProduct(
      code: '292702',
      goodsId: '292702',
      name: 'Pekko Prime2',
      description: '999 coins - Normal Edition',
      price: 9.99,
      exchangeCoin: 999,
    ),
    Contact575CoinProduct(
      code: '292703',
      goodsId: '292703',
      name: 'Pekko Prime3',
      description: '2500 coins - Normal Edition',
      price: 19.99,
      exchangeCoin: 2500,
    ),
    Contact575CoinProduct(
      code: '292704',
      goodsId: '292704',
      name: 'Pekko Prime4',
      description: '7000 coins - Normal Edition',
      price: 49.99,
      exchangeCoin: 7000,
    ),
    Contact575CoinProduct(
      code: '292705',
      goodsId: '292705',
      name: 'Pekko Prime5',
      description: '15000 coins - Normal Edition',
      price: 99.99,
      exchangeCoin: 15000,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '292706',
      goodsId: '292706',
      name: 'Pekko Prime6',
      description: '298 coins - Limited Time',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '292707',
      goodsId: '292707',
      name: 'Pekko Prime7',
      description: '498 coins - Limited Time',
      price: 1.99,
      exchangeCoin: 498,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '292708',
      goodsId: '292708',
      name: 'Pekko Prime8',
      description: '1200 coins - Limited Time',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '292709',
      goodsId: '292709',
      name: 'Pekko Prime9',
      description: '2498 coins - Limited Time',
      price: 11.99,
      exchangeCoin: 2498,
      isPromotion: true,
      originalPrice: 19.99,
    ),
    Contact575CoinProduct(
      code: '292710',
      goodsId: '292710',
      name: 'Pekko Prime10',
      description: '6999 coins - Limited Time',
      price: 34.99,
      exchangeCoin: 6999,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: '292711',
      goodsId: '292711',
      name: 'Pekko Prime11',
      description: '15000 coins - Limited Time',
      price: 79.99,
      exchangeCoin: 15000,
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
