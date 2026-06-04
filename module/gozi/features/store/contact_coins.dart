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
    if (!isPromotion || original == null || original <= price) {
      return 0;
    }
    return ((1 - price / original) * 100).round();
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
  static const Contact575CoinProduct _goziSp00 = Contact575CoinProduct(
    code: 'gozi.sp00',
    goodsId: '100009902',
    name: 'Gozi Bag0',
    description: '100 coins - Base Pack',
    price: 0.99,
    exchangeCoin: 100,
    isPromotion: false,
  );

  static const Contact575CoinProduct _goziSp01 = Contact575CoinProduct(
    code: 'gozi.sp01',
    goodsId: '100049902',
    name: 'Gozi Bag1',
    description: '500 coins - Base Pack',
    price: 4.99,
    exchangeCoin: 500,
    isPromotion: false,
  );

  static const Contact575CoinProduct _goziSp02 = Contact575CoinProduct(
    code: 'gozi.sp02',
    goodsId: '100099904',
    name: 'Gozi Bag2',
    description: '1000 coins - Base Pack',
    price: 9.99,
    exchangeCoin: 1000,
    isPromotion: false,
  );

  static const Contact575CoinProduct _goziSp03 = Contact575CoinProduct(
    code: 'gozi.sp03',
    goodsId: '100199902',
    name: 'Gozi Bag3',
    description: '2500 coins - Base Pack',
    price: 19.99,
    exchangeCoin: 2500,
    isPromotion: false,
  );

  static const Contact575CoinProduct _goziSp04 = Contact575CoinProduct(
    code: 'gozi.sp04',
    goodsId: '100499907',
    name: 'Gozi Bag4',
    description: '7000 coins - Base Pack',
    price: 49.99,
    exchangeCoin: 7000,
    isPromotion: false,
  );

  static const Contact575CoinProduct _goziSp05 = Contact575CoinProduct(
    code: 'gozi.sp05',
    goodsId: '100999910',
    name: 'Gozi Bag5',
    description: '15000 coins - Base Pack',
    price: 99.99,
    exchangeCoin: 15000,
    isPromotion: false,
  );

  static const Contact575CoinProduct _goziSp06 = Contact575CoinProduct(
    code: 'gozi.sp06',
    goodsId: '100009906',
    name: 'Gozi Bag6',
    description: 'Limited Promotion: 298 coins',
    price: 0.99,
    exchangeCoin: 298,
    isPromotion: true,
    originalPrice: 2.99,
  );

  static const Contact575CoinProduct _goziSp07 = Contact575CoinProduct(
    code: 'gozi.sp07',
    goodsId: '100019902',
    name: 'Gozi Bag7',
    description: 'Limited Promotion: 500 coins',
    price: 1.99,
    exchangeCoin: 500,
    isPromotion: true,
    originalPrice: 4.99,
  );

  static const Contact575CoinProduct _goziSp08 = Contact575CoinProduct(
    code: 'gozi.sp08',
    goodsId: '100049903',
    name: 'Gozi Bag8',
    description: 'Limited Promotion: 1198 coins',
    price: 4.99,
    exchangeCoin: 1198,
    isPromotion: true,
    originalPrice: 9.99,
  );

  static const Contact575CoinProduct _goziSp09 = Contact575CoinProduct(
    code: 'gozi.sp09',
    goodsId: '100099906',
    name: 'Gozi Bag9',
    description: 'Limited Promotion: 2000 coins',
    price: 9.99,
    exchangeCoin: 2000,
    isPromotion: true,
    originalPrice: 16.99,
  );

  static const Contact575CoinProduct _goziSp10 = Contact575CoinProduct(
    code: 'gozi.sp10',
    goodsId: '100349904',
    name: 'Gozi Bag10',
    description: 'Limited Promotion: 6999 coins',
    price: 34.99,
    exchangeCoin: 6999,
    isPromotion: true,
    originalPrice: 49.99,
  );

  static const Contact575CoinProduct _goziSp11 = Contact575CoinProduct(
    code: 'gozi.sp11',
    goodsId: '100999905',
    name: 'Gozi Bag11',
    description: 'Limited Promotion: 17998 coins',
    price: 99.99,
    exchangeCoin: 17998,
    isPromotion: true,
    originalPrice: 119.99,
  );

  static const Contact575CoinProduct _goziSp12 = Contact575CoinProduct(
    code: 'gozi.sp12',
    goodsId: '282412',
    name: 'Gozi Bag12',
    description: 'Base Pack',
    price: 3.99,
    exchangeCoin: 399,
    isPromotion: false,
  );

  static const Contact575CoinProduct _goziSp13 = Contact575CoinProduct(
    code: 'gozi.sp13',
    goodsId: '280013',
    name: 'Gozi Bag13',
    description: 'Base Pack',
    price: 6.99,
    exchangeCoin: 699,
    isPromotion: false,
  );

  static const List<Contact575CoinProduct> regularProducts = [
    _goziSp00,
    _goziSp01,
    _goziSp02,
    _goziSp03,
    _goziSp04,
    _goziSp05,
    _goziSp12,
    _goziSp13,
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    _goziSp06,
    _goziSp07,
    _goziSp08,
    _goziSp09,
    _goziSp10,
    _goziSp11,
  ];

  static const List<Contact575CoinProduct> allProducts = [
    _goziSp00,
    _goziSp01,
    _goziSp02,
    _goziSp03,
    _goziSp04,
    _goziSp05,
    _goziSp06,
    _goziSp07,
    _goziSp08,
    _goziSp09,
    _goziSp10,
    _goziSp11,
    _goziSp12,
    _goziSp13,
  ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts,
        ...promotionProducts,
      ];
}
