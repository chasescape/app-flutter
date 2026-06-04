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
    final original = originalPrice;
    if (original == null || original <= price) return 0;
    return (((original - price) / original) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice =>
      originalPrice == null ? null : '\$${originalPrice!.toStringAsFixed(2)}';

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: 'pliro.en00',
      goodsId: '100009902',
      name: 'Pliro Coin 0',
      description: '100 coins - Standard Pack',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'pliro.en01',
      goodsId: '100049902',
      name: 'Pliro Coin 1',
      description: '500 coins - Standard Pack',
      price: 4.99,
      exchangeCoin: 500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'pliro.en02',
      goodsId: '100099904',
      name: 'Pliro Coin 2',
      description: '1000 coins - Standard Pack',
      price: 9.99,
      exchangeCoin: 1000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'pliro.en03',
      goodsId: '100199902',
      name: 'Pliro Coin 3',
      description: '2500 coins - Standard Pack',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'pliro.en04',
      goodsId: '100499907',
      name: 'Pliro Coin 4',
      description: '7000 coins - Standard Pack',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'pliro.en05',
      goodsId: '100999910',
      name: 'Pliro Coin 5',
      description: '15000 coins - Standard Pack',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'pliro.en12',
      goodsId: '282412',
      name: 'Pliro Coin 12',
      description: 'Standard Pack',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'pliro.en13',
      goodsId: '270013',
      name: 'Pliro Coin 13',
      description: 'Standard Pack',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: 'pliro.en06',
      goodsId: '100009907',
      name: 'Pliro Coin 6',
      description: '299 coins - Offer',
      price: 0.99,
      exchangeCoin: 299,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: 'pliro.en07',
      goodsId: '100019900',
      name: 'Pliro Coin 7',
      description: '498 coins - Offer',
      price: 1.99,
      exchangeCoin: 498,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: 'pliro.en08',
      goodsId: '100049903',
      name: 'Pliro Coin 8',
      description: '1198 coins - Offer',
      price: 4.99,
      exchangeCoin: 1198,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: 'pliro.en09',
      goodsId: '100129907',
      name: 'Pliro Coin 9',
      description: '2600 coins - Offer',
      price: 12.99,
      exchangeCoin: 2600,
      isPromotion: true,
      originalPrice: 20.99,
    ),
    Contact575CoinProduct(
      code: 'pliro.en10',
      goodsId: '100499904',
      name: 'Pliro Coin 10',
      description: '10000 coins - Offer',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: 'pliro.en11',
      goodsId: '100999904',
      name: 'Pliro Coin 11',
      description: '17888 coins - Offer',
      price: 99.99,
      exchangeCoin: 17888,
      isPromotion: true,
      originalPrice: 119.99,
    ),
  ];

  static List<Contact575CoinProduct> get allProducts => [
        regularProducts[0],
        regularProducts[1],
        regularProducts[2],
        regularProducts[3],
        regularProducts[4],
        regularProducts[5],
        ...promotionProducts,
        regularProducts[6],
        regularProducts[7],
      ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts,
        ...promotionProducts,
      ];
}
