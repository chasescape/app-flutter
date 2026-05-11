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
    if (originalPrice == null || originalPrice! <= price) {
      return 0;
    }
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    final value = originalPrice;
    if (value == null) {
      return null;
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  double get coinsPerDollar => price <= 0 ? 0 : exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '285300',
      goodsId: '285300',
      name: 'Tanie Coin Bundle0',
      description: '99 coins - Regular Pack',
      price: 0.99,
      exchangeCoin: 99,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285312',
      goodsId: '285312',
      name: 'Tanie Coin',
      description: 'Bundle12',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285301',
      goodsId: '285301',
      name: 'Tanie Coin Bundle1',
      description: '499 coins - Regular Pack',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285313',
      goodsId: '285313',
      name: 'Tanie Coin',
      description: 'Bundle13',
      price: 6.99,
      exchangeCoin: 699,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285302',
      goodsId: '285302',
      name: 'Tanie Coin Bundle2',
      description: '1198 coins - Regular Pack',
      price: 9.99,
      exchangeCoin: 1198,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285303',
      goodsId: '285303',
      name: 'Tanie Coin Bundle3',
      description: '2500 coins - Regular Pack',
      price: 19.99,
      exchangeCoin: 2500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285304',
      goodsId: '285304',
      name: 'Tanie Coin Bundle4',
      description: '7000 coins - Regular Pack',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '285305',
      goodsId: '285305',
      name: 'Tanie Coin Bundle5',
      description: '15000 coins - Regular Pack',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '285306',
      goodsId: '285306',
      name: 'Tanie Coin Bundle6',
      description: '298 coins - Discount',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '285307',
      goodsId: '285307',
      name: 'Tanie Coin Bundle7',
      description: '499 coins - Discount',
      price: 1.99,
      exchangeCoin: 499,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: '285308',
      goodsId: '285308',
      name: 'Tanie Coin Bundle8',
      description: '1198 coins - Discount',
      price: 4.99,
      exchangeCoin: 1198,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '285309',
      goodsId: '285309',
      name: 'Tanie Coin',
      description: 'Bundle9',
      price: 12.99,
      exchangeCoin: 2600,
      isPromotion: true,
      originalPrice: 26.00,
    ),
    Contact575CoinProduct(
      code: '285310',
      goodsId: '285310',
      name: 'Tanie Coin',
      description: 'Bundle10',
      price: 49.99,
      exchangeCoin: 9999,
      isPromotion: true,
      originalPrice: 99.99,
    ),
    Contact575CoinProduct(
      code: '285311',
      goodsId: '285311',
      name: 'Tanie Coin',
      description: 'Bundle11',
      price: 99.99,
      exchangeCoin: 18000,
      isPromotion: true,
      originalPrice: 180.00,
    ),
  ];

  static List<Contact575CoinProduct> get allProducts => [
        regularProducts[0],
        regularProducts[1],
        regularProducts[2],
        regularProducts[3],
        regularProducts[4],
        regularProducts[5],
        promotionProducts[0],
        promotionProducts[1],
        promotionProducts[2],
        promotionProducts[3],
        regularProducts[6],
        regularProducts[7],
        promotionProducts[4],
        promotionProducts[5],
      ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts,
        ...promotionProducts,
      ];
}
