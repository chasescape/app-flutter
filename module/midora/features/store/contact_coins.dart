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

    return (((originalPrice! - price) / originalPrice!) * 100).round();
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
      code: '285200',
      goodsId: '285200',
      name: 'Midora 0',
      description: '99 coins - Normal Edition',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285212',
      goodsId: '285212',
      name: 'Midora 12',
      description: 'Normal Edition',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285201',
      goodsId: '285201',
      name: 'Midora 1',
      description: '499 coins - Normal Edition',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285213',
      goodsId: '285213',
      name: 'Midora 13',
      description: 'Normal Edition',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285202',
      goodsId: '285202',
      name: 'Midora 2',
      description: '1198 coins - Normal Edition',
      price: 9.99,
      exchangeCoin: 1198,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285203',
      goodsId: '285203',
      name: 'Midora 3',
      description: '2500 coins - Normal Edition',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285204',
      goodsId: '285204',
      name: 'Midora 4',
      description: '7000 coins - Normal Edition',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285205',
      goodsId: '285205',
      name: 'Midora 5',
      description: '15000 coins - Normal Edition',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '285206',
      goodsId: '285206',
      name: 'Midora 6',
      description: '298 coins - Hot',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '285207',
      goodsId: '285207',
      name: 'Midora 7',
      description: '750 coins - Hot',
      price: 2.99,
      exchangeCoin: 750,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: '285208',
      goodsId: '285208',
      name: 'Midora 8',
      description: '1199 coins - Hot',
      price: 4.99,
      exchangeCoin: 1199,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '285209',
      goodsId: '285209',
      name: 'Midora 9',
      description: '2599 coins - Hot',
      price: 12.99,
      exchangeCoin: 2599,
      isPromotion: true,
      originalPrice: 20.99,
    ),
    Contact575CoinProduct(
      code: '285210',
      goodsId: '285210',
      name: 'Midora 10',
      description: '9999 coins - Hot',
      price: 49.99,
      exchangeCoin: 9999,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: '285211',
      goodsId: '285211',
      name: 'Midora 11',
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
