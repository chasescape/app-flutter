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
    if (originalPrice == null || originalPrice! <= price) {
      return 0;
    }
    return ((1 - (price / originalPrice!)) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    if (originalPrice == null) {
      return null;
    }
    return '\$${originalPrice!.toStringAsFixed(2)}';
  }

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '285900',
      goodsId: '285900',
      name: 'Bilra Bag0',
      description: 'Normal Edition: 99 coins',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285901',
      goodsId: '285901',
      name: 'Bilra Bag1',
      description: 'Normal Edition: 400 coins',
      price: 3.99,
      exchangeCoin: 400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285912',
      goodsId: '285912',
      name: 'Bilra Bag12',
      description: 'Normal Edition',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285913',
      goodsId: '285913',
      name: 'Bilra Bag13',
      description: 'Normal Edition',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285902',
      goodsId: '285902',
      name: 'Bilra Bag2',
      description: 'Normal Edition: 999 coins',
      price: 9.99,
      exchangeCoin: 999,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285903',
      goodsId: '285903',
      name: 'Bilra Bag3',
      description: 'Normal Edition: 2400 coins',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285904',
      goodsId: '285904',
      name: 'Bilra Bag4',
      description: 'Normal Edition: 7000 coins',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285905',
      goodsId: '285905',
      name: 'Bilra Bag5',
      description: 'Normal Edition: 15000 coins',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '285906',
      goodsId: '285906',
      name: 'Bilra Bag6',
      description: '299 coins - Hot',
      price: 0.99,
      exchangeCoin: 299,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '285907',
      goodsId: '285907',
      name: 'Bilra Bag7',
      description: '748 coins - Hot',
      price: 2.99,
      exchangeCoin: 748,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: '285908',
      goodsId: '285908',
      name: 'Bilra Bag8',
      description: '1199 coins - Hot',
      price: 4.99,
      exchangeCoin: 1199,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '285909',
      goodsId: '285909',
      name: 'Bilra Bag9',
      description: '2398 coins - Hot',
      price: 11.99,
      exchangeCoin: 2398,
      isPromotion: true,
      originalPrice: 18.99,
    ),
    Contact575CoinProduct(
      code: '285910',
      goodsId: '285910',
      name: 'Bilra Bag10',
      description: '10000 coins - Hot',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: '285911',
      goodsId: '285911',
      name: 'Bilra Bag11',
      description: '14999 coins - Hot',
      price: 79.99,
      exchangeCoin: 14999,
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
