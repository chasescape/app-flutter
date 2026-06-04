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
    if (!isPromotion || originalPrice == null || originalPrice! <= price) {
      return 0;
    }
    return ((1 - price / originalPrice!) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice =>
      originalPrice == null ? null : '\$${originalPrice!.toStringAsFixed(2)}';

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '296500',
      goodsId: '296500',
      name: 'Glace Token Bundle0',
      description: 'Standard Price: 100 coins',
      price: 0.99,
      exchangeCoin: 100,
    ),
    Contact575CoinProduct(
      code: '296512',
      goodsId: '296512',
      name: 'Glace Token Bundle12',
      description: 'Standard Price',
      price: 3.99,
      exchangeCoin: 400,
    ),
    Contact575CoinProduct(
      code: '296501',
      goodsId: '296501',
      name: 'Glace Token Bundle1',
      description: 'Standard Price: 500 coins',
      price: 4.99,
      exchangeCoin: 500,
    ),
    Contact575CoinProduct(
      code: '296513',
      goodsId: '296513',
      name: 'Glace Token Bundle13',
      description: 'Standard Price',
      price: 6.99,
      exchangeCoin: 699,
    ),
    Contact575CoinProduct(
      code: '296502',
      goodsId: '296502',
      name: 'Glace Token Bundle2',
      description: 'Standard Price: 1200 coins',
      price: 9.99,
      exchangeCoin: 1200,
    ),
    Contact575CoinProduct(
      code: '296503',
      goodsId: '296503',
      name: 'Glace Token Bundle3',
      description: 'Standard Price: 2400 coins',
      price: 19.99,
      exchangeCoin: 2400,
    ),
    Contact575CoinProduct(
      code: '296504',
      goodsId: '296504',
      name: 'Glace Token Bundle4',
      description: 'Standard Price: 7000 coins',
      price: 49.99,
      exchangeCoin: 7000,
    ),
    Contact575CoinProduct(
      code: '296505',
      goodsId: '296505',
      name: 'Glace Token Bundle5',
      description: 'Standard Price: 15000 coins',
      price: 99.99,
      exchangeCoin: 15000,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '296506',
      goodsId: '296506',
      name: 'Glace Token Bundle6',
      description: '298 coins - Limited Sale',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '296507',
      goodsId: '296507',
      name: 'Glace Token Bundle7',
      description: '498 coins - Limited Sale',
      price: 1.99,
      exchangeCoin: 498,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '296508',
      goodsId: '296508',
      name: 'Glace Token Bundle8',
      description: '1199 coins - Limited Sale',
      price: 4.99,
      exchangeCoin: 1199,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '296509',
      goodsId: '296509',
      name: 'Glace Token Bundle9',
      description: '2399 coins - Limited Sale',
      price: 11.99,
      exchangeCoin: 2399,
      isPromotion: true,
      originalPrice: 18.99,
    ),
    Contact575CoinProduct(
      code: '296510',
      goodsId: '296510',
      name: 'Glace Token Bundle10',
      description: '7000 coins - Limited Sale',
      price: 34.99,
      exchangeCoin: 7000,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: '296511',
      goodsId: '296511',
      name: 'Glace Token Bundle11',
      description: '14888 coins - Limited Sale',
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
