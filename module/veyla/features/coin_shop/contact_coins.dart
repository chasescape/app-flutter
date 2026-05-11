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
    if (originalPrice == null || originalPrice == 0) return 0;
    return ((1 - (price / originalPrice!)) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice =>
      originalPrice == null ? null : '\$${originalPrice!.toStringAsFixed(2)}';

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '292900',
      goodsId: '292900',
      name: 'Veyla Value Pack0',
      description: 'Regular Pack: 99 coins',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292912',
      goodsId: '292912',
      name: 'Veyla Value Pack12',
      description: 'Regular Pack',
      price: 4.99,
      exchangeCoin: 500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292901',
      goodsId: '292901',
      name: 'Veyla Value Pack1',
      description: 'Regular Pack: 599 coins',
      price: 5.99,
      exchangeCoin: 599,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292913',
      goodsId: '292913',
      name: 'Veyla Value Pack13',
      description: 'Regular Pack',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292902',
      goodsId: '292902',
      name: 'Veyla Value Pack2',
      description: 'Regular Pack: 1198 coins',
      price: 9.99,
      exchangeCoin: 1198,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292903',
      goodsId: '292903',
      name: 'Veyla Value Pack3',
      description: 'Regular Pack: 2400 coins',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292904',
      goodsId: '292904',
      name: 'Veyla Value Pack4',
      description: 'Regular Pack: 7000 coins',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '292905',
      goodsId: '292905',
      name: 'Veyla Value Pack5',
      description: 'Regular Pack: 15000 coins',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '292906',
      goodsId: '292906',
      name: 'Veyla Value Pack6',
      description: '300 coins - Special Price',
      price: 0.99,
      exchangeCoin: 300,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '292907',
      goodsId: '292907',
      name: 'Veyla Value Pack7',
      description: '500 coins - Special Price',
      price: 1.99,
      exchangeCoin: 500,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '292908',
      goodsId: '292908',
      name: 'Veyla Value Pack8',
      description: '1200 coins - Special Price',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '292909',
      goodsId: '292909',
      name: 'Veyla Value Pack9',
      description: '1999 coins - Special Price',
      price: 9.99,
      exchangeCoin: 1999,
      isPromotion: true,
      originalPrice: 16.99,
    ),
    Contact575CoinProduct(
      code: '292910',
      goodsId: '292910',
      name: 'Veyla Value Pack10',
      description: '7000 coins - Special Price',
      price: 34.99,
      exchangeCoin: 7000,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: '292911',
      goodsId: '292911',
      name: 'Veyla Value Pack11',
      description: '17999 coins - Special Price',
      price: 99.99,
      exchangeCoin: 17999,
      isPromotion: true,
      originalPrice: 119.99,
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
