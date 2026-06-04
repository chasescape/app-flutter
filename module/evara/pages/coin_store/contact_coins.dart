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
    return ((1 - (price / originalPrice!)) * 100).round();
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
      code: 'evara.st00',
      goodsId: '100009900',
      name: 'Evara Vault0',
      description: '99 coins - Regular',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'evara.st01',
      goodsId: '100039902',
      name: 'Evara Vault1',
      description: '400 coins - Regular',
      price: 3.99,
      exchangeCoin: 400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'evara.st02',
      goodsId: '100099902',
      name: 'Evara Vault2',
      description: '1200 coins - Regular',
      price: 9.99,
      exchangeCoin: 1200,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'evara.st03',
      goodsId: '100199902',
      name: 'Evara Vault3',
      description: '2500 coins - Regular',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'evara.st04',
      goodsId: '100499907',
      name: 'Evara Vault4',
      description: '7000 coins - Regular',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'evara.st05',
      goodsId: '100999910',
      name: 'Evara Vault5',
      description: '15000 coins - Regular',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'evara.st12',
      goodsId: '282312',
      name: 'Evara Vault12',
      description: 'Regular',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'evara.st13',
      goodsId: '280013',
      name: 'Evara Vault13',
      description: 'Regular',
      price: 6.99,
      exchangeCoin: 699,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: 'evara.st06',
      goodsId: '100009906',
      name: 'Evara Vault6',
      description: 'Limited Time: 298 coins',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: 'evara.st07',
      goodsId: '100029901',
      name: 'Evara Vault7',
      description: 'Limited Time: 749 coins',
      price: 2.99,
      exchangeCoin: 749,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: 'evara.st08',
      goodsId: '100049904',
      name: 'Evara Vault8',
      description: 'Limited Time: 1199 coins',
      price: 4.99,
      exchangeCoin: 1199,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: 'evara.st09',
      goodsId: '100119908',
      name: 'Evara Vault9',
      description: 'Limited Time: 2400 coins',
      price: 11.99,
      exchangeCoin: 2400,
      isPromotion: true,
      originalPrice: 18.99,
    ),
    Contact575CoinProduct(
      code: 'evara.st10',
      goodsId: '100499904',
      name: 'Evara Vault10',
      description: 'Limited Time: 10000 coins',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: 'evara.st11',
      goodsId: '100799906',
      name: 'Evara Vault11',
      description: 'Limited Time: 14888 coins',
      price: 79.99,
      exchangeCoin: 14888,
      isPromotion: true,
      originalPrice: 99.99,
    ),
  ];

  static List<Contact575CoinProduct> get allProducts => [
        ...regularProducts.take(6),
        ...promotionProducts,
        ...regularProducts.skip(6),
      ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts,
        ...promotionProducts,
      ];
}
