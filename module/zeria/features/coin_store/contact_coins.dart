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
    final original = originalPrice;
    if (!isPromotion || original == null || original <= 0) return 0;
    final discount = (1 - (price / original)) * 100;
    if (discount <= 0) return 0;
    return discount.round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    final original = originalPrice;
    if (!isPromotion || original == null) return null;
    return '\$${original.toStringAsFixed(2)}';
  }

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '284900',
      goodsId: '284900',
      name: 'Zeria Gold0',
      description: '99 coins - Regular Price',
      price: 0.99,
      exchangeCoin: 99,
    ),
    Contact575CoinProduct(
      code: '284912',
      goodsId: '284912',
      name: 'Zeria Gold12',
      description: 'Regular Price',
      price: 3.99,
      exchangeCoin: 400,
    ),
    Contact575CoinProduct(
      code: '284901',
      goodsId: '284901',
      name: 'Zeria Gold1',
      description: '600 coins - Regular Price',
      price: 5.99,
      exchangeCoin: 600,
    ),
    Contact575CoinProduct(
      code: '284913',
      goodsId: '284913',
      name: 'Zeria Gold13',
      description: 'Regular Price',
      price: 6.99,
      exchangeCoin: 700,
    ),
    Contact575CoinProduct(
      code: '284902',
      goodsId: '284902',
      name: 'Zeria Gold2',
      description: '1198 coins - Regular Price',
      price: 9.99,
      exchangeCoin: 1198,
    ),
    Contact575CoinProduct(
      code: '284903',
      goodsId: '284903',
      name: 'Zeria Gold3',
      description: '2400 coins - Regular Price',
      price: 19.99,
      exchangeCoin: 2400,
    ),
    Contact575CoinProduct(
      code: '284904',
      goodsId: '284904',
      name: 'Zeria Gold4',
      description: '7000 coins - Regular Price',
      price: 49.99,
      exchangeCoin: 7000,
    ),
    Contact575CoinProduct(
      code: '284905',
      goodsId: '284905',
      name: 'Zeria Gold5',
      description: '15000 coins - Regular Price',
      price: 99.99,
      exchangeCoin: 15000,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '284906',
      goodsId: '284906',
      name: 'Zeria Gold6',
      description: '299 coins - Offer',
      price: 0.99,
      exchangeCoin: 299,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '284907',
      goodsId: '284907',
      name: 'Zeria Gold7',
      description: '499 coins - Offer',
      price: 1.99,
      exchangeCoin: 499,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '284908',
      goodsId: '284908',
      name: 'Zeria Gold8',
      description: '1199 coins - Offer',
      price: 4.99,
      exchangeCoin: 1199,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '284909',
      goodsId: '284909',
      name: 'Zeria Gold9',
      description: '2398 coins - Offer',
      price: 11.99,
      exchangeCoin: 2398,
      isPromotion: true,
      originalPrice: 18.99,
    ),
    Contact575CoinProduct(
      code: '284910',
      goodsId: '284910',
      name: 'Zeria Gold10',
      description: '9999 coins - Offer',
      price: 49.99,
      exchangeCoin: 9999,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: '284911',
      goodsId: '284911',
      name: 'Zeria Gold11',
      description: '14888 coins - Offer',
      price: 79.99,
      exchangeCoin: 14888,
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

