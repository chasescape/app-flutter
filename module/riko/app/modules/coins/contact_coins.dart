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
    if (!isPromotion || originalPrice == null || originalPrice == 0) return 0;
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
      code: '273300',
      goodsId: '273300',
      name: 'Riko Coin Vault0',
      description: '99 coins - Package',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '273301',
      goodsId: '273301',
      name: 'Riko Coin Vault1',
      description: '599 coins - Package',
      price: 5.99,
      exchangeCoin: 599,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '273302',
      goodsId: '273302',
      name: 'Riko Coin Vault2',
      description: '1000 coins - Package',
      price: 9.99,
      exchangeCoin: 1000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '273303',
      goodsId: '273303',
      name: 'Riko Coin Vault3',
      description: '2400 coins - Package',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '273304',
      goodsId: '273304',
      name: 'Riko Coin Vault4',
      description: '7000 coins - Package',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '273305',
      goodsId: '273305',
      name: 'Riko Coin Vault5',
      description: '15000 coins - Package',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '273312',
      goodsId: '273312',
      name: 'Riko Coin Vault12',
      description: 'Coins - Package',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '273313',
      goodsId: '273313',
      name: 'Riko Coin Vault13',
      description: 'Coins - Package',
      price: 6.99,
      exchangeCoin: 699,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '273306',
      goodsId: '273306',
      name: 'Riko Coin Vault6',
      description: '300 coins - Flash Deal',
      price: 0.99,
      exchangeCoin: 300,
      isPromotion: true,
    ),
    Contact575CoinProduct(
      code: '273307',
      goodsId: '273307',
      name: 'Riko Coin Vault7',
      description: '498 coins - Flash Deal',
      price: 1.99,
      exchangeCoin: 498,
      isPromotion: true,
    ),
    Contact575CoinProduct(
      code: '273308',
      goodsId: '273308',
      name: 'Riko Coin Vault8',
      description: '1198 coins - Flash Deal',
      price: 4.99,
      exchangeCoin: 1198,
      isPromotion: true,
    ),
    Contact575CoinProduct(
      code: '273309',
      goodsId: '273309',
      name: 'Riko Coin Vault9',
      description: '2400 coins - Flash Deal',
      price: 11.99,
      exchangeCoin: 2400,
      isPromotion: true,
    ),
    Contact575CoinProduct(
      code: '273310',
      goodsId: '273310',
      name: 'Riko Coin Vault10',
      description: '10000 coins - Flash Deal',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
    ),
    Contact575CoinProduct(
      code: '273311',
      goodsId: '273311',
      name: 'Riko Coin Vault11',
      description: '17998 coins - Flash Deal',
      price: 99.99,
      exchangeCoin: 17998,
      isPromotion: true,
    ),
  ];

  static List<Contact575CoinProduct> get allProducts => [
        ...regularProducts,
        ...promotionProducts,
      ];

  static List<Contact575CoinProduct> get allProductsGrouped =>
      allProducts.toList();
}
