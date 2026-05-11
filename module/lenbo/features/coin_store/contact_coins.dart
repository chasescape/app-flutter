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

  String? get formattedOriginalPrice =>
      originalPrice == null ? null : '\$${originalPrice!.toStringAsFixed(2)}';

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '283200',
      goodsId: '283200',
      name: 'Lenbo Token Set0',
      description: 'Normal Edition: 99 coins',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283201',
      goodsId: '283201',
      name: 'Lenbo Token Set1',
      description: 'Normal Edition: 399 coins',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283212',
      goodsId: '283212',
      name: 'Lenbo Token Set12',
      description: 'Normal Edition',
      price: 4.99,
      exchangeCoin: 500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283213',
      goodsId: '283213',
      name: 'Lenbo Token Set13',
      description: 'Normal Edition',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283202',
      goodsId: '283202',
      name: 'Lenbo Token Set2',
      description: 'Normal Edition: 999 coins',
      price: 9.99,
      exchangeCoin: 999,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283203',
      goodsId: '283203',
      name: 'Lenbo Token Set3',
      description: 'Normal Edition: 2400 coins',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283204',
      goodsId: '283204',
      name: 'Lenbo Token Set4',
      description: 'Normal Edition: 7000 coins',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283205',
      goodsId: '283205',
      name: 'Lenbo Token Set5',
      description: 'Normal Edition: 15000 coins',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '283206',
      goodsId: '283206',
      name: 'Lenbo Token Set6',
      description: 'Flash Deal: 300 coins',
      price: 0.99,
      exchangeCoin: 300,
      isPromotion: true,
      originalPrice: 2.00,
    ),
    Contact575CoinProduct(
      code: '283207',
      goodsId: '283207',
      name: 'Lenbo Token Set7',
      description: 'Flash Deal: 748 coins',
      price: 2.99,
      exchangeCoin: 748,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '283208',
      goodsId: '283208',
      name: 'Lenbo Token Set8',
      description: 'Flash Deal: 1198 coins',
      price: 4.99,
      exchangeCoin: 1198,
      isPromotion: true,
      originalPrice: 7.99,
    ),
    Contact575CoinProduct(
      code: '283209',
      goodsId: '283209',
      name: 'Lenbo Token Set9',
      description: 'Flash Deal: 2498 coins',
      price: 11.99,
      exchangeCoin: 2498,
      isPromotion: true,
      originalPrice: 16.65,
    ),
    Contact575CoinProduct(
      code: '283210',
      goodsId: '283210',
      name: 'Lenbo Token Set10',
      description: 'Flash Deal: 6999 coins',
      price: 34.99,
      exchangeCoin: 6999,
      isPromotion: true,
      originalPrice: 46.66,
    ),
    Contact575CoinProduct(
      code: '283211',
      goodsId: '283211',
      name: 'Lenbo Token Set11',
      description: 'Flash Deal: 15000 coins',
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
