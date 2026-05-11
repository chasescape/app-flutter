class CoinPackageData {
  const CoinPackageData({
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.coins,
    required this.type,
    this.gpTemplatePrice,
  });

  final int code;
  final String name;
  final String description;
  final double price;
  final int coins;
  final String type;
  final double? gpTemplatePrice;

  bool get isPromo => type == '促销';
}

class CoinsData {
  static const List<CoinPackageData> packages = <CoinPackageData>[
    CoinPackageData(
      code: 279800,
      name: 'Flira pkg0',
      description: 'Regular Pack: 100 coins',
      price: 0.99,
      coins: 100,
      type: '常规',
    ),
            CoinPackageData(
      code: 279812,
      name: 'Flira pkg12',
      description: 'Regular Pack',
      price: 4.99,
      coins: 500,
      type: '常规',
    ),
    CoinPackageData(
      code: 279801,
      name: 'Flira pkg1',
      description: 'Regular Pack: 599 coins',
      price: 5.99,
      coins: 599,
      type: '常规',
    ),

    CoinPackageData(
      code: 279813,
      name: 'Flira pkg13',
      description: 'Regular Pack',
      price: 6.99,
      coins: 700,
      type: '常规',
    ),
    CoinPackageData(
      code: 279802,
      name: 'Flira pkg2',
      description: 'Regular Pack: 1199 coins',
      price: 9.99,
      coins: 1199,
      type: '常规',
    ),
    CoinPackageData(
      code: 279803,
      name: 'Flira pkg3',
      description: 'Regular Pack: 2500 coins',
      price: 19.99,
      coins: 2500,
      type: '常规',
    ),
    CoinPackageData(
      code: 279804,
      name: 'Flira pkg4',
      description: 'Regular Pack: 7000 coins',
      price: 49.99,
      coins: 7000,
      type: '常规',
    ),
    CoinPackageData(
      code: 279805,
      name: 'Flira pkg5',
      description: 'Regular Pack: 15000 coins',
      price: 99.99,
      coins: 15000,
      type: '常规',
    ),
    CoinPackageData(
      code: 279806,
      name: 'Flira pkg6',
      description: '299 coins - Off',
      price: 0.99,
      coins: 299,
      type: '促销',
      gpTemplatePrice: 2.99,
    ),
    CoinPackageData(
      code: 279807,
      name: 'Flira pkg7',
      description: '498 coins - Off',
      price: 1.99,
      coins: 498,
      type: '促销',
      gpTemplatePrice: 4.99,
    ),
    CoinPackageData(
      code: 279808,
      name: 'Flira pkg8',
      description: '1198 coins - Off',
      price: 4.99,
      coins: 1198,
      type: '促销',
      gpTemplatePrice: 9.99,
    ),
    CoinPackageData(
      code: 279809,
      name: 'Flira pkg9',
      description: '2400 coins - Off',
      price: 11.99,
      coins: 2400,
      type: '促销',
      gpTemplatePrice: 19.99,
    ),
    CoinPackageData(
      code: 279810,
      name: 'Flira pkg10',
      description: '7000 coins - Off',
      price: 34.99,
      coins: 7000,
      type: '促销',
      gpTemplatePrice: 49.99,
    ),
    CoinPackageData(
      code: 279811,
      name: 'Flira pkg11',
      description: '14888 coins - Off',
      price: 79.99,
      coins: 14888,
      type: '促销',
      gpTemplatePrice: 99.99,
    ),
  ];

  static Set<String> get productIds =>
      packages.map((package) => package.code.toString()).toSet();
}
