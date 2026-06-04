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

  String? get formattedOriginalPrice {
    final original = originalPrice;
    if (original == null) return null;
    return '\$${original.toStringAsFixed(2)}';
  }

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '296600',
      goodsId: '296600',
      name: 'Cliss Set0',
      description: '100 coins - Regular',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '296601',
      goodsId: '296601',
      name: 'Cliss Set1',
      description: '399 coins - Regular',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '296612',
      goodsId: '296612',
      name: 'Cliss Set12',
      description: 'Regular',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '296613',
      goodsId: '296613',
      name: 'Cliss Set13',
      description: 'Regular',
      price: 6.99,
      exchangeCoin: 699,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '296602',
      goodsId: '296602',
      name: 'Cliss Set2',
      description: '1200 coins - Regular',
      price: 9.99,
      exchangeCoin: 1200,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '296603',
      goodsId: '296603',
      name: 'Cliss Set3',
      description: '2400 coins - Regular',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '296604',
      goodsId: '296604',
      name: 'Cliss Set4',
      description: '7000 coins - Regular',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '296605',
      goodsId: '296605',
      name: 'Cliss Set5',
      description: '15000 coins - Regular',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '296606',
      goodsId: '296606',
      name: 'Cliss Set6',
      description: '300 coins - Off',
      price: 0.99,
      exchangeCoin: 300,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '296607',
      goodsId: '296607',
      name: 'Cliss Set7',
      description: '498 coins - Off',
      price: 1.99,
      exchangeCoin: 498,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '296608',
      goodsId: '296608',
      name: 'Cliss Set8',
      description: '1199 coins - Off',
      price: 4.99,
      exchangeCoin: 1199,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '296609',
      goodsId: '296609',
      name: 'Cliss Set9',
      description: '1999 coins - Off',
      price: 9.99,
      exchangeCoin: 1999,
      isPromotion: true,
      originalPrice: 16.99,
    ),
    Contact575CoinProduct(
      code: '296610',
      goodsId: '296610',
      name: 'Cliss Set10',
      description: '6999 coins - Off',
      price: 34.99,
      exchangeCoin: 6999,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: '296611',
      goodsId: '296611',
      name: 'Cliss Set11',
      description: '17999 coins - Off',
      price: 99.99,
      exchangeCoin: 17999,
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
