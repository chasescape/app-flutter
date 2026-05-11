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

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice =>
      originalPrice == null ? null : '\$${originalPrice!.toStringAsFixed(2)}';
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '290800',
      goodsId: '290800',
      name: 'Temra More0',
      description: '100 coins - Standard Price',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290801',
      goodsId: '290801',
      name: 'Temra More1',
      description: '400 coins - Standard Price',
      price: 3.99,
      exchangeCoin: 400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290812',
      goodsId: '290812',
      name: 'Temra More12',
      description: 'Standard Price',
      price: 4.99,
      exchangeCoin: 499,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290813',
      goodsId: '290813',
      name: 'Temra More13',
      description: 'Standard Price',
      price: 6.99,
      exchangeCoin: 699,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290802',
      goodsId: '290802',
      name: 'Temra More2',
      description: '1198 coins - Standard Price',
      price: 9.99,
      exchangeCoin: 1198,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290803',
      goodsId: '290803',
      name: 'Temra More3',
      description: '2400 coins - Standard Price',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290804',
      goodsId: '290804',
      name: 'Temra More4',
      description: '7000 coins - Standard Price',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '290805',
      goodsId: '290805',
      name: 'Temra More5',
      description: '15000 coins - Standard Price',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '290806',
      goodsId: '290806',
      name: 'Temra More6',
      description: '298 coins - Limited Time',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '290807',
      goodsId: '290807',
      name: 'Temra More7',
      description: '750 coins - Limited Time',
      price: 2.99,
      exchangeCoin: 750,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: '290808',
      goodsId: '290808',
      name: 'Temra More8',
      description: '1198 coins - Limited Time',
      price: 4.99,
      exchangeCoin: 1198,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: '290809',
      goodsId: '290809',
      name: 'Temra More9',
      description: '1999 coins - Limited Time',
      price: 9.99,
      exchangeCoin: 1999,
      isPromotion: true,
      originalPrice: 16.99,
    ),
    Contact575CoinProduct(
      code: '290810',
      goodsId: '290810',
      name: 'Temra More10',
      description: '7000 coins - Limited Time',
      price: 34.99,
      exchangeCoin: 7000,
      isPromotion: true,
      originalPrice: 49.99,
    ),
    Contact575CoinProduct(
      code: '290811',
      goodsId: '290811',
      name: 'Temra More11',
      description: '15000 coins - Limited Time',
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
