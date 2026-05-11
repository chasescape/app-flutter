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
    if (original == null || original <= 0 || original <= price) {
      return 0;
    }

    return ((1 - (price / original)) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    final original = originalPrice;
    if (original == null || original <= 0) {
      return null;
    }

    return '\$${original.toStringAsFixed(2)}';
  }

  double get coinsPerDollar => price <= 0 ? 0 : exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '286300',
      goodsId: '286300',
      name: 'Velise Bloom0',
      description: 'Standard Price: 100 coins',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286312',
      goodsId: '286312',
      name: 'Velise Bloom12',
      description: 'Standard Price',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286301',
      goodsId: '286301',
      name: 'Velise Bloom1',
      description: 'Standard Price: 600 coins',
      price: 5.99,
      exchangeCoin: 600,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286313',
      goodsId: '286313',
      name: 'Velise Bloom13',
      description: 'Standard Price',
      price: 6.99,
      exchangeCoin: 699,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286302',
      goodsId: '286302',
      name: 'Velise Bloom2',
      description: 'Standard Price: 1200 coins',
      price: 9.99,
      exchangeCoin: 1200,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286303',
      goodsId: '286303',
      name: 'Velise Bloom3',
      description: 'Standard Price: 2500 coins',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286304',
      goodsId: '286304',
      name: 'Velise Bloom4',
      description: 'Standard Price: 7000 coins',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286305',
      goodsId: '286305',
      name: 'Velise Bloom5',
      description: 'Standard Price: 15000 coins',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '286306',
      goodsId: '286306',
      name: 'Velise Bloom6',
      description: '300 coins - Time-Limited Pack',
      price: 0.99,
      exchangeCoin: 300,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '286307',
      goodsId: '286307',
      name: 'Velise Bloom7',
      description: '749 coins - Time-Limited Pack',
      price: 2.99,
      exchangeCoin: 749,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: '286308',
      goodsId: '286308',
      name: 'Velise Bloom8',
      description: '1200 coins - Time-Limited Pack',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '286309',
      goodsId: '286309',
      name: 'Velise Bloom9',
      description: '2400 coins - Time-Limited Pack',
      price: 11.99,
      exchangeCoin: 2400,
      isPromotion: true,
      originalPrice: 18.99,
    ),
    Contact575CoinProduct(
      code: '286310',
      goodsId: '286310',
      name: 'Velise Bloom10',
      description: '7000 coins - Time-Limited Pack',
      price: 34.99,
      exchangeCoin: 7000,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: '286311',
      goodsId: '286311',
      name: 'Velise Bloom11',
      description: '17888 coins - Time-Limited Pack',
      price: 99.99,
      exchangeCoin: 17888,
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
