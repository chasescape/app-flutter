class CoinPackageData {
  const CoinPackageData({
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.coins,
    required this.type,
  });

  final int code;
  final String name;
  final String description;
  final double price;
  final int coins;
  final String type;

  bool get isPromo => type == '促销';
}

class CoinsData {
  static const List<CoinPackageData> packages = [
    CoinPackageData(
      code: 270600,
      name: 'Betwe Token Set0',
      description: '99 coins - Normal Edition',
      price: 0.99,
      coins: 99,
      type: '常规',
    ),
    CoinPackageData(
      code: 270601,
      name: 'Betwe Token Set1',
      description: '400 coins - Normal Edition',
      price: 3.99,
      coins: 400,
      type: '常规',
    ),
    CoinPackageData(
      code: 270602,
      name: 'Betwe Token Set2',
      description: '1198 coins - Normal Edition',
      price: 9.99,
      coins: 1198,
      type: '常规',
    ),
    CoinPackageData(
      code: 270603,
      name: 'Betwe Token Set3',
      description: '2400 coins - Normal Edition',
      price: 19.99,
      coins: 2400,
      type: '常规',
    ),
    CoinPackageData(
      code: 270604,
      name: 'Betwe Token Set4',
      description: '7000 coins - Normal Edition',
      price: 49.99,
      coins: 7000,
      type: '常规',
    ),
    CoinPackageData(
      code: 270605,
      name: 'Betwe Token Set5',
      description: '15000 coins - Normal Edition',
      price: 99.99,
      coins: 15000,
      type: '常规',
    ),
    CoinPackageData(
      code: 270606,
      name: 'Betwe Token Set6',
      description: '299 coins - Hot Sale',
      price: 0.99,
      coins: 299,
      type: '促销',
    ),
    CoinPackageData(
      code: 270607,
      name: 'Betwe Token Set7',
      description: '499 coins - Hot Sale',
      price: 1.99,
      coins: 499,
      type: '促销',
    ),
    CoinPackageData(
      code: 270608,
      name: 'Betwe Token Set8',
      description: '1200 coins - Hot Sale',
      price: 4.99,
      coins: 1200,
      type: '促销',
    ),
    CoinPackageData(
      code: 270609,
      name: 'Betwe Token Set9',
      description: '2599 coins - Hot Sale',
      price: 12.99,
      coins: 2599,
      type: '促销',
    ),
    CoinPackageData(
      code: 270610,
      name: 'Betwe Token Set10',
      description: '9999 coins - Hot Sale',
      price: 49.99,
      coins: 9999,
      type: '促销',
    ),
    CoinPackageData(
      code: 270611,
      name: 'Betwe Token Set11',
      description: '17888 coins - Hot Sale',
      price: 99.99,
      coins: 17888,
      type: '促销',
    ),
    CoinPackageData(
      code: 270612,
      name: 'Betwe Token Set12',
      description: 'Normal Edition',
      price: 4.99,
      coins: 500,
      type: '常规',
    ),
    CoinPackageData(
      code: 270613,
      name: 'Betwe Token Set13',
      description: 'Normal Edition',
      price: 6.99,
      coins: 700,
      type: '常规',
    ),
  ];

  static Set<String> get productIds =>
      packages.map((package) => package.code.toString()).toSet();
}
