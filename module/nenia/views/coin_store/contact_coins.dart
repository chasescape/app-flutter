// Generated from project.json product data.
// The last few source rows contain shifted fields, so their values are
// normalized here to keep the store usable without mutating project.json.

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
    return ((1 - (price / originalPrice!)) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice =>
      originalPrice == null ? null : '\$${originalPrice!.toStringAsFixed(2)}';

  double get coinsPerDollar => price <= 0 ? 0 : exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const Contact575CoinProduct _product286000 = Contact575CoinProduct(
    code: '286000',
    goodsId: '286000',
    name: 'Nenia Coin Set0',
    description: 'Normal Edition: 100 coins',
    price: 0.99,
    exchangeCoin: 100,
    isPromotion: false,
  );

  static const Contact575CoinProduct _product286001 = Contact575CoinProduct(
    code: '286001',
    goodsId: '286001',
    name: 'Nenia Coin Set1',
    description: 'Normal Edition: 400 coins',
    price: 3.99,
    exchangeCoin: 400,
    isPromotion: false,
  );

  static const Contact575CoinProduct _product286002 = Contact575CoinProduct(
    code: '286002',
    goodsId: '286002',
    name: 'Nenia Coin Set2',
    description: 'Normal Edition: 999 coins',
    price: 9.99,
    exchangeCoin: 999,
    isPromotion: false,
  );

  static const Contact575CoinProduct _product286003 = Contact575CoinProduct(
    code: '286003',
    goodsId: '286003',
    name: 'Nenia Coin Set3',
    description: 'Normal Edition: 2500 coins',
    price: 19.99,
    exchangeCoin: 2500,
    isPromotion: false,
  );

  static const Contact575CoinProduct _product286004 = Contact575CoinProduct(
    code: '286004',
    goodsId: '286004',
    name: 'Nenia Coin Set4',
    description: 'Normal Edition: 7000 coins',
    price: 49.99,
    exchangeCoin: 7000,
    isPromotion: false,
  );

  static const Contact575CoinProduct _product286005 = Contact575CoinProduct(
    code: '286005',
    goodsId: '286005',
    name: 'Nenia Coin Set5',
    description: 'Normal Edition: 15000 coins',
    price: 99.99,
    exchangeCoin: 15000,
    isPromotion: false,
  );

  static const Contact575CoinProduct _product286006 = Contact575CoinProduct(
    code: '286006',
    goodsId: '286006',
    name: 'Nenia Coin Set6',
    description: 'Discount: 300 coins',
    price: 0.99,
    exchangeCoin: 300,
    isPromotion: true,
    originalPrice: 2.99,
  );

  static const Contact575CoinProduct _product286007 = Contact575CoinProduct(
    code: '286007',
    goodsId: '286007',
    name: 'Nenia Coin Set7',
    description: 'Discount: 750 coins',
    price: 2.99,
    exchangeCoin: 750,
    isPromotion: true,
    originalPrice: 6.99,
  );

  static const Contact575CoinProduct _product286008 = Contact575CoinProduct(
    code: '286008',
    goodsId: '286008',
    name: 'Nenia Coin Set8',
    description: 'Discount: 1199 coins',
    price: 4.99,
    exchangeCoin: 1199,
    isPromotion: true,
    originalPrice: 9.99,
  );

  static const Contact575CoinProduct _product286009 = Contact575CoinProduct(
    code: '286009',
    goodsId: '286009',
    name: 'Nenia Coin Set9',
    description: 'Discount: 2000 coins',
    price: 9.99,
    exchangeCoin: 2000,
    isPromotion: true,
    originalPrice: 16.99,
  );

  static const Contact575CoinProduct _product286010 = Contact575CoinProduct(
    code: '286010',
    goodsId: '286010',
    name: 'Nenia Coin Set10',
    description: 'Discount: 10000 coins',
    price: 49.99,
    exchangeCoin: 10000,
    isPromotion: true,
    originalPrice: 66.66,
  );

  static const Contact575CoinProduct _product286011 = Contact575CoinProduct(
    code: '286011',
    goodsId: '286011',
    name: 'Nenia Coin Set11',
    description: 'Discount: 14999 coins',
    price: 79.99,
    exchangeCoin: 14999,
    isPromotion: true,
    originalPrice: 99.98,
  );

  static const Contact575CoinProduct _product286012 = Contact575CoinProduct(
    code: '286012',
    goodsId: '286012',
    name: 'Nenia Coin Set12',
    description: 'Normal Edition: 500 coins',
    price: 4.99,
    exchangeCoin: 500,
    isPromotion: false,
  );

  static const Contact575CoinProduct _product286013 = Contact575CoinProduct(
    code: '286013',
    goodsId: '286013',
    name: 'Nenia Coin Set13',
    description: 'Normal Edition: 700 coins',
    price: 6.99,
    exchangeCoin: 700,
    isPromotion: false,
  );

  static const List<Contact575CoinProduct> regularProducts = [
    _product286000,
    _product286001,
    _product286012,
    _product286013,
    _product286002,
    _product286003,
    _product286004,
    _product286005,
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    _product286006,
    _product286007,
    _product286008,
    _product286009,
    _product286010,
    _product286011,
  ];

  static const List<Contact575CoinProduct> allProducts = [
    _product286000,
    _product286001,
    _product286002,
    _product286003,
    _product286004,
    _product286005,
    _product286006,
    _product286007,
    _product286008,
    _product286009,
    _product286010,
    _product286011,
    _product286012,
    _product286013,
  ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts,
        ...promotionProducts,
      ];
}
