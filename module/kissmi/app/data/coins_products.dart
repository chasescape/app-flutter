class CoinProduct {
  final String code;
  final String name;
  final String description;
  final double price;
  final int coins;
  final bool isPromotion;
  final double? originalPrice;

  const CoinProduct({
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.coins,
    required this.isPromotion,
    this.originalPrice,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String? get formattedOriginalPrice =>
      originalPrice == null ? null : '\$${originalPrice!.toStringAsFixed(2)}';
}

class CoinProductsData {
  static const List<CoinProduct> regularProducts = <CoinProduct>[
    CoinProduct(
      code: '262100',
      name: 'Kissmi Coin 0',
      description: '99 coins - Regular',
      price: 0.99,
      coins: 99,
      isPromotion: false,
    ),
    CoinProduct(
      code: '262112',
      name: 'Kissmi Coin 12',
      description: 'Regular',
      price: 3.99,
      coins: 399,
      isPromotion: false,
    ),
    CoinProduct(
      code: '262101',
      name: 'Kissmi Coin 1',
      description: '500 coins - Regular',
      price: 4.99,
      coins: 500,
      isPromotion: false,
    ),
    CoinProduct(
      code: '262113',
      name: 'Kissmi Coin 13',
      description: 'Regular',
      price: 6.99,
      coins: 700,
      isPromotion: false,
    ),
    CoinProduct(
      code: '262102',
      name: 'Kissmi Coin 2',
      description: '1198 coins - Regular',
      price: 9.99,
      coins: 1198,
      isPromotion: false,
    ),
    CoinProduct(
      code: '262103',
      name: 'Kissmi Coin 3',
      description: '2500 coins - Regular',
      price: 19.99,
      coins: 2500,
      isPromotion: false,
    ),
    CoinProduct(
      code: '262104',
      name: 'Kissmi Coin 4',
      description: '7000 coins - Regular',
      price: 49.99,
      coins: 7000,
      isPromotion: false,
    ),
    CoinProduct(
      code: '262105',
      name: 'Kissmi Coin 5',
      description: '15000 coins - Regular',
      price: 99.99,
      coins: 15000,
      isPromotion: false,
    ),
  ];

  static const List<CoinProduct> promotionProducts = <CoinProduct>[
    CoinProduct(
      code: '262106',
      name: 'Kissmi Coin 6',
      description: '299 coins - Promotion',
      price: 0.99,
      coins: 299,
      isPromotion: true,
      originalPrice: 0.99,
    ),
    CoinProduct(
      code: '262107',
      name: 'Kissmi Coin 7',
      description: '749 coins - Promotion',
      price: 2.99,
      coins: 749,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    CoinProduct(
      code: '262108',
      name: 'Kissmi Coin 8',
      description: '1198 coins - Promotion',
      price: 4.99,
      coins: 1198,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    CoinProduct(
      code: '262109',
      name: 'Kissmi Coin 9',
      description: '2400 coins - Promotion',
      price: 11.99,
      coins: 2400,
      isPromotion: true,
      originalPrice: 11.99,
    ),
    CoinProduct(
      code: '262110',
      name: 'Kissmi Coin 10',
      description: '7000 coins - Promotion',
      price: 34.99,
      coins: 7000,
      isPromotion: true,
      originalPrice: 34.99,
    ),
    CoinProduct(
      code: '262111',
      name: 'Kissmi Coin 11',
      description: '18000 coins - Promotion',
      price: 99.99,
      coins: 18000,
      isPromotion: true,
      originalPrice: 99.99,
    ),
  ];

  static List<CoinProduct> get allProducts => <CoinProduct>[
        ...regularProducts,
        ...promotionProducts,
      ];

  static Set<String> get productIds =>
      allProducts.map((product) => product.code).toSet();
}
