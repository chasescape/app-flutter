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
    if (originalPrice == null || originalPrice == 0) {
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
      code: '283300',
      goodsId: '283300',
      name: 'Minne Coin Pack0',
      description: '100 coins - Regular Pack',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283312',
      goodsId: '283312',
      name: 'Minne Coin Pack12',
      description: 'Regular Coins',
      price: 3.99,
      exchangeCoin: 400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283301',
      goodsId: '283301',
      name: 'Minne Coin Pack1',
      description: '600 coins - Regular Pack',
      price: 5.99,
      exchangeCoin: 600,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283313',
      goodsId: '283313',
      name: 'Minne Coin Pack13',
      description: 'Regular Coins',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283302',
      goodsId: '283302',
      name: 'Minne Coin Pack2',
      description: '1198 coins - Regular Pack',
      price: 9.99,
      exchangeCoin: 1198,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283303',
      goodsId: '283303',
      name: 'Minne Coin Pack3',
      description: '2500 coins - Regular Pack',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283304',
      goodsId: '283304',
      name: 'Minne Coin Pack4',
      description: '7000 coins - Regular Pack',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '283305',
      goodsId: '283305',
      name: 'Minne Coin Pack5',
      description: '15000 coins - Regular Pack',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '283306',
      goodsId: '283306',
      name: 'Minne Coin Pack6',
      description: '299 coins - Special Bundle',
      price: 0.99,
      exchangeCoin: 299,
      isPromotion: true,
      originalPrice: 2.97,
    ),
    Contact575CoinProduct(
      code: '283307',
      goodsId: '283307',
      name: 'Minne Coin Pack7',
      description: '499 coins - Special Bundle',
      price: 1.99,
      exchangeCoin: 499,
      isPromotion: true,
      originalPrice: 4.95,
    ),
    Contact575CoinProduct(
      code: '283308',
      goodsId: '283308',
      name: 'Minne Coin Pack8',
      description: '1200 coins - Special Bundle',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 10.98,
    ),
    Contact575CoinProduct(
      code: '283309',
      goodsId: '283309',
      name: 'Minne Coin Pack9',
      description: '2398 coins - Special Bundle',
      price: 11.99,
      exchangeCoin: 2398,
      isPromotion: true,
      originalPrice: 19.99,
    ),
    Contact575CoinProduct(
      code: '283310',
      goodsId: '283310',
      name: 'Minne Coin Pack10',
      description: '10000 coins - Special Bundle',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
      originalPrice: 74.93,
    ),
    Contact575CoinProduct(
      code: '283311',
      goodsId: '283311',
      name: 'Minne Coin Pack11',
      description: '14998 coins - Special Bundle',
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
