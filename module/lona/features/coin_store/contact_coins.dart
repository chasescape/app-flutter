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
    if (!isPromotion || original == null || original <= 0 || price <= 0) {
      return 0;
    }
    final discount = (1 - (price / original)) * 100;
    return discount.isNaN || discount.isInfinite
        ? 0
        : discount.round().clamp(0, 99);
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedOriginalPrice {
    final original = originalPrice;
    if (!isPromotion || original == null) return null;
    return '\$${original.toStringAsFixed(2)}';
  }

  double get coinsPerDollar => price <= 0 ? 0 : exchangeCoin / price;
}

class Privatised236CoinProductData {
  static const List<Contact575CoinProduct> regularProducts = [
    Contact575CoinProduct(
      code: '286200',
      goodsId: '286200',
      name: 'Lona Token Set0',
      description: '100 coins - Normal Edition',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286201',
      goodsId: '286201',
      name: 'Lona Token Set1',
      description: '500 coins - Normal Edition',
      price: 4.99,
      exchangeCoin: 500,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286202',
      goodsId: '286202',
      name: 'Lona Token Set2',
      description: '1199 coins - Normal Edition',
      price: 9.99,
      exchangeCoin: 1199,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286203',
      goodsId: '286203',
      name: 'Lona Token Set3',
      description: '2400 coins - Normal Edition',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286204',
      goodsId: '286204',
      name: 'Lona Token Set4',
      description: '7000 coins - Normal Edition',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286205',
      goodsId: '286205',
      name: 'Lona Token Set5',
      description: '15000 coins - Normal Edition',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
    // These rows are malformed in `project.json`; keep their original order
    // while normalizing the intended package values for the store UI.
    Contact575CoinProduct(
      code: '286212',
      goodsId: '286212',
      name: 'Lona Token Set12',
      description: '400 coins - Normal Edition',
      price: 3.99,
      exchangeCoin: 400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: '286213',
      goodsId: '286213',
      name: 'Lona Token Set13',
      description: '700 coins - Normal Edition',
      price: 6.99,
      exchangeCoin: 700,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts = [
    Contact575CoinProduct(
      code: '286206',
      goodsId: '286206',
      name: 'Lona Token Set6',
      description: '298 coins - Event Pack',
      price: 0.99,
      exchangeCoin: 298,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: '286207',
      goodsId: '286207',
      name: 'Lona Token Set7',
      description: '750 coins - Event Pack',
      price: 2.99,
      exchangeCoin: 750,
      isPromotion: true,
      originalPrice: 6.99,
    ),
    Contact575CoinProduct(
      code: '286208',
      goodsId: '286208',
      name: 'Lona Token Set8',
      description: '1198 coins - Event Pack',
      price: 4.99,
      exchangeCoin: 1198,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    // These rows are malformed in `project.json`; normalize them from the
    // shifted values so the generated store data stays purchasable.
    Contact575CoinProduct(
      code: '286210',
      goodsId: '286210',
      name: 'Lona Token Set10',
      description: '10000 coins - Event Pack',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: '286211',
      goodsId: '286211',
      name: 'Lona Token Set11',
      description: '17888 coins - Event Pack',
      price: 99.99,
      exchangeCoin: 17888,
      isPromotion: true,
      originalPrice: 119.99,
    ),
    Contact575CoinProduct(
      code: '286209',
      goodsId: '286209',
      name: 'Lona Token Set9',
      description: '2499 coins - Event',
      price: 11.99,
      exchangeCoin: 2499,
      isPromotion: true,
      originalPrice: 19.99,
    ),
  ];

  static List<Contact575CoinProduct> get allProducts => const [
        Contact575CoinProduct(
          code: '286200',
          goodsId: '286200',
          name: 'Lona Token Set0',
          description: '100 coins - Normal Edition',
          price: 0.99,
          exchangeCoin: 100,
          isPromotion: false,
        ),
        Contact575CoinProduct(
          code: '286201',
          goodsId: '286201',
          name: 'Lona Token Set1',
          description: '500 coins - Normal Edition',
          price: 4.99,
          exchangeCoin: 500,
          isPromotion: false,
        ),
        Contact575CoinProduct(
          code: '286202',
          goodsId: '286202',
          name: 'Lona Token Set2',
          description: '1199 coins - Normal Edition',
          price: 9.99,
          exchangeCoin: 1199,
          isPromotion: false,
        ),
        Contact575CoinProduct(
          code: '286203',
          goodsId: '286203',
          name: 'Lona Token Set3',
          description: '2400 coins - Normal Edition',
          price: 19.99,
          exchangeCoin: 2400,
          isPromotion: false,
        ),
        Contact575CoinProduct(
          code: '286204',
          goodsId: '286204',
          name: 'Lona Token Set4',
          description: '7000 coins - Normal Edition',
          price: 49.99,
          exchangeCoin: 7000,
          isPromotion: false,
        ),
        Contact575CoinProduct(
          code: '286205',
          goodsId: '286205',
          name: 'Lona Token Set5',
          description: '15000 coins - Normal Edition',
          price: 99.99,
          exchangeCoin: 15000,
          isPromotion: false,
        ),
        Contact575CoinProduct(
          code: '286206',
          goodsId: '286206',
          name: 'Lona Token Set6',
          description: '298 coins - Event Pack',
          price: 0.99,
          exchangeCoin: 298,
          isPromotion: true,
          originalPrice: 2.99,
        ),
        Contact575CoinProduct(
          code: '286207',
          goodsId: '286207',
          name: 'Lona Token Set7',
          description: '750 coins - Event Pack',
          price: 2.99,
          exchangeCoin: 750,
          isPromotion: true,
          originalPrice: 6.99,
        ),
        Contact575CoinProduct(
          code: '286208',
          goodsId: '286208',
          name: 'Lona Token Set8',
          description: '1198 coins - Event Pack',
          price: 4.99,
          exchangeCoin: 1198,
          isPromotion: true,
          originalPrice: 9.99,
        ),
        Contact575CoinProduct(
          code: '286210',
          goodsId: '286210',
          name: 'Lona Token Set10',
          description: '10000 coins - Event Pack',
          price: 49.99,
          exchangeCoin: 10000,
          isPromotion: true,
          originalPrice: 69.99,
        ),
        Contact575CoinProduct(
          code: '286211',
          goodsId: '286211',
          name: 'Lona Token Set11',
          description: '17888 coins - Event Pack',
          price: 99.99,
          exchangeCoin: 17888,
          isPromotion: true,
          originalPrice: 119.99,
        ),
        Contact575CoinProduct(
          code: '286212',
          goodsId: '286212',
          name: 'Lona Token Set12',
          description: '400 coins - Normal Edition',
          price: 3.99,
          exchangeCoin: 400,
          isPromotion: false,
        ),
        Contact575CoinProduct(
          code: '286213',
          goodsId: '286213',
          name: 'Lona Token Set13',
          description: '700 coins - Normal Edition',
          price: 6.99,
          exchangeCoin: 700,
          isPromotion: false,
        ),
        Contact575CoinProduct(
          code: '286209',
          goodsId: '286209',
          name: 'Lona Token Set9',
          description: '2499 coins - Event',
          price: 11.99,
          exchangeCoin: 2499,
          isPromotion: true,
          originalPrice: 19.99,
        ),
      ];

  static List<Contact575CoinProduct> get allProductsGrouped => [
        ...regularProducts, // 常规商品在前
        ...promotionProducts, // 促销商品在后
      ];
}
