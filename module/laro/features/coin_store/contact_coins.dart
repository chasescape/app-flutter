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
    if (originalPrice == null || originalPrice == 0 || originalPrice! <= price) {
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
      code: '290600',
      goodsId: '290600',
      name: 'Laro Coin Vault0',
      description: '99 coins - Standard',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290612',
      goodsId: '290612',
      name: 'Laro Coin Vault12',
      description: 'Standard',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290601',
      goodsId: '290601',
      name: 'Laro Coin Vault1',
      description: '500 coins - Standard',
      price: 4.99,
      exchangeCoin: 500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290613',
      goodsId: '290613',
      name: 'Laro Coin Vault13',
      description: 'Standard',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290602',
      goodsId: '290602',
      name: 'Laro Coin Vault2',
      description: '1000 coins - Standard',
      price: 9.99,
      exchangeCoin: 1000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290603',
      goodsId: '290603',
      name: 'Laro Coin Vault3',
      description: '2500 coins - Standard',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290604',
      goodsId: '290604',
      name: 'Laro Coin Vault4',
      description: '7000 coins - Standard',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290605',
      goodsId: '290605',
      name: 'Laro Coin Vault5',
      description: '15000 coins - Standard',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '290606',
      goodsId: '290606',
      name: 'Laro Coin Vault6',
      description: '298 coins - Limited Sale',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '290607',
      goodsId: '290607',
      name: 'Laro Coin Vault7',
      description: '750 coins - Limited Sale',
      price: 2.99,
      exchangeCoin: 750,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: '290608',
      goodsId: '290608',
      name: 'Laro Coin Vault8',
      description: '1199 coins - Limited Sale',
      price: 4.99,
      exchangeCoin: 1199,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '290609',
      goodsId: '290609',
      name: 'Laro Coin Vault9',
      description: '1999 coins - Limited Sale',
      price: 9.99,
      exchangeCoin: 1999,
      isPromotion: true,
      originalPrice: 16.99,
    ),
    Contact575CoinProduct(
      code: '290610',
      goodsId: '290610',
      name: 'Laro Coin Vault10',
      description: '9999 coins - Limited Sale',
      price: 49.99,
      exchangeCoin: 9999,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: '290611',
      goodsId: '290611',
      name: 'Laro Coin Vault11',
      description: '15000 coins - Limited Sale',
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
