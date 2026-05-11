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
    final double discount = ((originalPrice! - price) / originalPrice!) * 100;
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
      code: '286100',
      goodsId: '286100',
      name: 'Voreo Coin Vault0',
      description: '99 coins - Base Price',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286101',
      goodsId: '286101',
      name: 'Voreo Coin Vault1',
      description: '599 coins - Base Price',
      price: 5.99,
      exchangeCoin: 599,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286102',
      goodsId: '286102',
      name: 'Voreo Coin Vault2',
      description: '1198 coins - Base Price',
      price: 9.99,
      exchangeCoin: 1198,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286103',
      goodsId: '286103',
      name: 'Voreo Coin Vault3',
      description: '2400 coins - Base Price',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286104',
      goodsId: '286104',
      name: 'Voreo Coin Vault4',
      description: '7000 coins - Base Price',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286105',
      goodsId: '286105',
      name: 'Voreo Coin Vault5',
      description: '15000 coins - Base Price',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286112',
      goodsId: '286112',
      name: 'Voreo Coin Vault12',
      description: '499 coins - Base Price',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286113',
      goodsId: '286113',
      name: 'Voreo Coin Vault13',
      description: '700 coins - Base Price',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '286106',
      goodsId: '286106',
      name: 'Voreo Coin Vault6',
      description: '299 coins - Time Sale',
      price: 0.99,
      exchangeCoin: 299,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '286107',
      goodsId: '286107',
      name: 'Voreo Coin Vault7',
      description: '498 coins - Time Sale',
      price: 1.99,
      exchangeCoin: 498,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '286108',
      goodsId: '286108',
      name: 'Voreo Coin Vault8',
      description: '1200 coins - Time Sale',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '286109',
      goodsId: '286109',
      name: 'Voreo Coin Vault9',
      description: '1999 coins - Time Sale',
      price: 9.99,
      exchangeCoin: 1999,
      isPromotion: true,
      originalPrice: 19.99,
    ),
    Contact575CoinProduct(
      code: '286110',
      goodsId: '286110',
      name: 'Voreo Coin Vault10',
      description: '10000 coins - Time Sale',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
      originalPrice: 100.00,
    ),
    Contact575CoinProduct(
      code: '286111',
      goodsId: '286111',
      name: 'Voreo Coin Vault11',
      description: '17999 coins - Time Sale',
      price: 99.99,
      exchangeCoin: 17999,
      isPromotion: true,
      originalPrice: 179.99,
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
