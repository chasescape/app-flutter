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
    if (!isPromotion || originalPrice == null || originalPrice! <= price) {
      return 0;
    }
    final discount = ((originalPrice! - price) / originalPrice!) * 100;
    return discount.round();
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
      code: '290700',
      goodsId: '290700',
      name: 'Havki Credit0',
      description: '99 coins - Base Price',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290712',
      goodsId: '290712',
      name: 'Havki Credit12',
      description: 'Base Price',
      price: 3.99,
      exchangeCoin: 400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290701',
      goodsId: '290701',
      name: 'Havki Credit1',
      description: '499 coins - Base Price',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290713',
      goodsId: '290713',
      name: 'Havki Credit13',
      description: 'Base Price',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290702',
      goodsId: '290702',
      name: 'Havki Credit2',
      description: '1198 coins - Base Price',
      price: 9.99,
      exchangeCoin: 1198,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290703',
      goodsId: '290703',
      name: 'Havki Credit3',
      description: '2500 coins - Base Price',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290704',
      goodsId: '290704',
      name: 'Havki Credit4',
      description: '7000 coins - Base Price',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290705',
      goodsId: '290705',
      name: 'Havki Credit5',
      description: '15000 coins - Base Price',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '290706',
      goodsId: '290706',
      name: 'Havki Credit6',
      description: '299 coins - Event Pack',
      price: 0.99,
      exchangeCoin: 299,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '290707',
      goodsId: '290707',
      name: 'Havki Credit7',
      description: '500 coins - Event Pack',
      price: 1.99,
      exchangeCoin: 500,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '290708',
      goodsId: '290708',
      name: 'Havki Credit8',
      description: '1200 coins - Event Pack',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '290709',
      goodsId: '290709',
      name: 'Havki Credit9',
      description: '2498 coins - Event Pack',
      price: 11.99,
      exchangeCoin: 2498,
      isPromotion: true,
      originalPrice: 19.99,
    ),
    Contact575CoinProduct(
      code: '290710',
      goodsId: '290710',
      name: 'Havki Credit10',
      description: '7000 coins - Event Pack',
      price: 34.99,
      exchangeCoin: 7000,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: '290711',
      goodsId: '290711',
      name: 'Havki Credit11',
      description: '14998 coins - Event Pack',
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
