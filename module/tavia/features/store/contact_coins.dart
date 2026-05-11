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
    if (originalPrice == null || originalPrice! <= price || originalPrice == 0) {
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

  double get coinsPerDollar => price == 0 ? 0 : exchangeCoin / price;
}

class Privatised236CoinProductData {
  const Privatised236CoinProductData._();

  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '285100',
      goodsId: '285100',
      name: 'Tavia Bundle 0',
      description: '99 coins - Normal Edition',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285112',
      goodsId: '285112',
      name: 'Tavia Bundle 12',
      description: 'Normal Edition',
      price: 3.99,
      exchangeCoin: 400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285101',
      goodsId: '285101',
      name: 'Tavia Bundle 1',
      description: '499 coins - Normal Edition',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285113',
      goodsId: '285113',
      name: 'Tavia Bundle 13',
      description: 'Normal Edition',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285102',
      goodsId: '285102',
      name: 'Tavia Bundle 2',
      description: '1199 coins - Normal Edition',
      price: 9.99,
      exchangeCoin: 1199,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285103',
      goodsId: '285103',
      name: 'Tavia Bundle 3',
      description: '2400 coins - Normal Edition',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285104',
      goodsId: '285104',
      name: 'Tavia Bundle 4',
      description: '7000 coins - Normal Edition',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285105',
      goodsId: '285105',
      name: 'Tavia Bundle 5',
      description: '15000 coins - Normal Edition',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '285106',
      goodsId: '285106',
      name: 'Tavia Bundle 6',
      description: 'Limited Time: 299 coins',
      price: 0.99,
      exchangeCoin: 299,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '285107',
      goodsId: '285107',
      name: 'Tavia Bundle 7',
      description: 'Limited Time: 748 coins',
      price: 2.99,
      exchangeCoin: 748,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: '285108',
      goodsId: '285108',
      name: 'Tavia Bundle 8',
      description: 'Limited Time: 1200 coins',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '285109',
      goodsId: '285109',
      name: 'Tavia Bundle 9',
      description: 'Limited Time: 2500 coins',
      price: 11.99,
      exchangeCoin: 2500,
      isPromotion: true,
      originalPrice: 19.99,
    ),
    Contact575CoinProduct(
      code: '285110',
      goodsId: '285110',
      name: 'Tavia Bundle 10',
      description: 'Limited Time: 9999 coins',
      price: 49.99,
      exchangeCoin: 9999,
      isPromotion: true,
      originalPrice: 99.99,
    ),
    Contact575CoinProduct(
      code: '285111',
      goodsId: '285111',
      name: 'Tavia Bundle 11',
      description: 'Limited Time: 14888 coins',
      price: 79.99,
      exchangeCoin: 14888,
      isPromotion: true,
      originalPrice: 99.99,
    ),
  ];

  static List<Contact575CoinProduct> get allProducts => [
        regularProducts[0],
        regularProducts[1],
        regularProducts[2],
        regularProducts[3],
        regularProducts[4],
        regularProducts[5],
        regularProducts[6],
        regularProducts[7],
        promotionProducts[0],
        promotionProducts[1],
        promotionProducts[2],
        promotionProducts[3],
        promotionProducts[4],
        promotionProducts[5],
      ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts,
        ...promotionProducts,
      ];
}
