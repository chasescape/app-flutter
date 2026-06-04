class Contact575CoinProduct {
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

  final String code;
  final String goodsId;
  final String name;
  final String description;
  final double price;
  final int exchangeCoin;
  final bool isPromotion;
  final double? originalPrice;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedOriginalPrice =>
      '\$${(originalPrice ?? price).toStringAsFixed(2)}';
}

class Privatised236CoinProductData {
  const Privatised236CoinProductData._();

  static const List<Contact575CoinProduct> regularProducts =
      <Contact575CoinProduct>[
    Contact575CoinProduct(
      code: 'hotou.up00',
      goodsId: '100009902',
      name: 'HotoU Coin Pack0',
      description: '100 coins - Pack',
      price: 0.99,
      exchangeCoin: 100,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'hotou.up01',
      goodsId: '100059902',
      name: 'HotoU Coin Pack1',
      description: '600 coins - Pack',
      price: 5.99,
      exchangeCoin: 600,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'hotou.up02',
      goodsId: '100099903',
      name: 'HotoU Coin Pack2',
      description: '999 coins - Pack',
      price: 9.99,
      exchangeCoin: 999,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'hotou.up03',
      goodsId: '100199905',
      name: 'HotoU Coin Pack3',
      description: '2400 coins - Pack',
      price: 19.99,
      exchangeCoin: 2400,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'hotou.up04',
      goodsId: '100499907',
      name: 'HotoU Coin Pack4',
      description: '7000 coins - Pack',
      price: 49.99,
      exchangeCoin: 7000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'hotou.up05',
      goodsId: '100999910',
      name: 'HotoU Coin Pack5',
      description: '15000 coins - Pack',
      price: 99.99,
      exchangeCoin: 15000,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'hotou.up12',
      goodsId: '282412',
      name: 'HotoU Coin Pack12',
      description: 'Pack',
      price: 3.99,
      exchangeCoin: 399,
      isPromotion: false,
    ),
    Contact575CoinProduct(
      code: 'hotou.up13',
      goodsId: '280013',
      name: 'HotoU Coin Pack13',
      description: 'Pack',
      price: 6.99,
      exchangeCoin: 699,
      isPromotion: false,
    ),
  ];

  static const List<Contact575CoinProduct> promotionProducts =
      <Contact575CoinProduct>[
    Contact575CoinProduct(
      code: 'hotou.up06',
      goodsId: '100009908',
      name: 'HotoU Coin Pack6',
      description: 'Discount: 300 coins',
      price: 0.99,
      exchangeCoin: 300,
      isPromotion: true,
      originalPrice: 2.99,
    ),
    Contact575CoinProduct(
      code: 'hotou.up07',
      goodsId: '100019900',
      name: 'HotoU Coin Pack7',
      description: 'Discount: 498 coins',
      price: 1.99,
      exchangeCoin: 498,
      isPromotion: true,
      originalPrice: 4.99,
    ),
    Contact575CoinProduct(
      code: 'hotou.up08',
      goodsId: '100049905',
      name: 'HotoU Coin Pack8',
      description: 'Discount: 1200 coins',
      price: 4.99,
      exchangeCoin: 1200,
      isPromotion: true,
      originalPrice: 9.99,
    ),
    Contact575CoinProduct(
      code: 'hotou.up09',
      goodsId: '100129905',
      name: 'HotoU Coin Pack9',
      description: 'Discount: 2598 coins',
      price: 12.99,
      exchangeCoin: 2598,
      isPromotion: true,
      originalPrice: 20.99,
    ),
    Contact575CoinProduct(
      code: 'hotou.up10',
      goodsId: '100499904',
      name: 'HotoU Coin Pack10',
      description: 'Discount: 10000 coins',
      price: 49.99,
      exchangeCoin: 10000,
      isPromotion: true,
      originalPrice: 69.99,
    ),
    Contact575CoinProduct(
      code: 'hotou.up11',
      goodsId: '100799903',
      name: 'HotoU Coin Pack11',
      description: 'Discount: 14998 coins',
      price: 79.99,
      exchangeCoin: 14998,
      isPromotion: true,
      originalPrice: 99.99,
    ),
  ];

  static List<Contact575CoinProduct> get allProducts => <Contact575CoinProduct>[
        ...regularProducts,
        ...promotionProducts,
      ];

  static Set<String> get productIds =>
      allProducts.map((product) => product.code).toSet();

  static List<Contact575CoinProduct> get allProductsGrouped =>
      <Contact575CoinProduct>[
        ...regularProducts,
        ...promotionProducts,
      ];
}
