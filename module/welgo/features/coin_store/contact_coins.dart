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
      code: '290500',
      goodsId: '290500',
      name: 'Welgo Gold0',
      description: 'Regular Pack: 99 coins',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290501',
      goodsId: '290501',
      name: 'Welgo Gold1',
      description: 'Regular Pack: 399 coins',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290512',
      goodsId: '290512',
      name: 'Welgo Gold12',
      description: 'Regular Pack',
      price: 4.99,
      exchangeCoin: 500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290513',
      goodsId: '290513',
      name: 'Welgo Gold13',
      description: 'Regular Pack',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290502',
      goodsId: '290502',
      name: 'Welgo Gold2',
      description: 'Regular Pack: 999 coins',
      price: 9.99,
      exchangeCoin: 999,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290503',
      goodsId: '290503',
      name: 'Welgo Gold3',
      description: 'Regular Pack: 2500 coins',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290504',
      goodsId: '290504',
      name: 'Welgo Gold4',
      description: 'Regular Pack: 7000 coins',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290505',
      goodsId: '290505',
      name: 'Welgo Gold5',
      description: 'Regular Pack: 15000 coins',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '290506',
      goodsId: '290506',
      name: 'Welgo Gold6',
      description: 'Promo Price: 299 coins',
      price: 0.99,
      exchangeCoin: 299,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '290507',
      goodsId: '290507',
      name: 'Welgo Gold7',
      description: 'Promo Price: 500 coins',
      price: 1.99,
      exchangeCoin: 500,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '290508',
      goodsId: '290508',
      name: 'Welgo Gold8',
      description: 'Promo Price: 1199 coins',
      price: 4.99,
      exchangeCoin: 1199,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '290509',
      goodsId: '290509',
      name: 'Welgo Gold9',
      description: 'Promo Price: 2398 coins',
      price: 11.99,
      exchangeCoin: 2398,
      isPromotion: true,
      originalPrice: 18.99,
    ),
    Contact575CoinProduct(
      code: '290510',
      goodsId: '290510',
      name: 'Welgo Gold10',
      description: 'Promo Price: 10000 coins',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: '290511',
      goodsId: '290511',
      name: 'Welgo Gold11',
      description: 'Promo Price: 18000 coins',
      price: 99.99,
      exchangeCoin: 18000,
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
