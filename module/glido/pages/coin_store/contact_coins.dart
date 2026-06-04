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
    if (originalPrice == null || originalPrice == 0) return 0;
    return ((1 - (price / originalPrice!)) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice =>
      originalPrice == null ? null : '\$${originalPrice!.toStringAsFixed(2)}';

  double get coinsPerDollar => exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: 'glido.ea00',
      goodsId: 'glido.ea00',
      name: 'Glido Set0',
      description: 'Base Pack: 100 coins',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'glido.ea01',
      goodsId: 'glido.ea01',
      name: 'Glido Set1',
      description: 'Base Pack: 500 coins',
      price: 4.99,
      exchangeCoin: 500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'glido.ea02',
      goodsId: 'glido.ea02',
      name: 'Glido Set2',
      description: 'Base Pack: 1000 coins',
      price: 9.99,
      exchangeCoin: 1000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'glido.ea03',
      goodsId: 'glido.ea03',
      name: 'Glido Set3',
      description: 'Base Pack: 2400 coins',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'glido.ea04',
      goodsId: 'glido.ea04',
      name: 'Glido Set4',
      description: 'Base Pack: 7000 coins',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'glido.ea05',
      goodsId: 'glido.ea05',
      name: 'Glido Set5',
      description: 'Base Pack: 15000 coins',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'glido.ea12',
      goodsId: 'glido.ea12',
      name: 'Glido Set12',
      description: 'Base Pack',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'glido.ea13',
      goodsId: 'glido.ea13',
      name: 'Glido Set13',
      description: 'Base Pack',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: 'glido.ea06',
      goodsId: 'glido.ea06',
      name: 'Glido Set6',
      description: 'Limited Sale: 298 coins',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: 'glido.ea07',
      goodsId: 'glido.ea07',
      name: 'Glido Set7',
      description: 'Limited Sale: 749 coins',
      price: 2.99,
      exchangeCoin: 749,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: 'glido.ea08',
      goodsId: 'glido.ea08',
      name: 'Glido Set8',
      description: 'Limited Sale: 1199 coins',
      price: 4.99,
      exchangeCoin: 1199,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: 'glido.ea09',
      goodsId: 'glido.ea09',
      name: 'Glido Set9',
      description: 'Limited Sale: 2599 coins',
      price: 12.99,
      exchangeCoin: 2599,
      isPromotion: true,
      originalPrice: 20.99,
    ),
    Contact575CoinProduct(
      code: 'glido.ea10',
      goodsId: 'glido.ea10',
      name: 'Glido Set10',
      description: 'Limited Sale: 7000 coins',
      price: 34.99,
      exchangeCoin: 7000,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: 'glido.ea11',
      goodsId: 'glido.ea11',
      name: 'Glido Set11',
      description: 'Limited Sale: 14998 coins',
      price: 79.99,
      exchangeCoin: 14998,
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
        promotionProducts[0],
        promotionProducts[1],
        promotionProducts[2],
        promotionProducts[3],
        promotionProducts[4],
        promotionProducts[5],
        regularProducts[6],
        regularProducts[7],
      ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts,
        ...promotionProducts,
      ];
}
