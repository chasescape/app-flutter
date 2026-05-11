class CoinPackage {
  const CoinPackage({
    required this.code,
    required this.name,
    required this.price,
    required this.coins,
    required this.type,
  });

  final String code;
  final String name;
  final String price;
  final int coins;
  final CoinPackageType type;

  // 计算折扣百分比（如果是促销商品）
  int get discountPercent {
    if (type != CoinPackageType.promotion) return 0;
    
    // 根据价格和金币数量计算折扣
    final priceValue = double.tryParse(price.replaceAll('\$', '')) ?? 0;
    if (priceValue == 0) return 0;
    
    // 基准：1美元 = 100金币
    final normalCoins = (priceValue * 100).toInt();
    if (normalCoins == 0) return 0;
    
    final extraCoins = coins - normalCoins;
    return ((extraCoins / normalCoins) * 100).round();
  }
}

enum CoinPackageType {
  normal,    // 常规
  promotion, // 促销
}

class CoinsData {
  static const List<CoinPackage> packages = [
    // 常规商品
    CoinPackage(
      code: '268300',
      name: 'Affie Coin Pack0',
      price: '\$0.99',
      coins: 99,
      type: CoinPackageType.normal,
    ),
    CoinPackage(
      code: '268301',
      name: 'Affie Coin Pack1',
      price: '\$3.99',
      coins: 400,
      type: CoinPackageType.normal,
    ),
    CoinPackage(
      code: '268312',
      name: 'Affie Coin Pack12',
      price: '\$4.99',
      coins: 500,
      type: CoinPackageType.normal,
    ),
    CoinPackage(
      code: '268313',
      name: 'Affie Coin Pack13',
      price: '\$6.99',
      coins: 700,
      type: CoinPackageType.normal,
    ),
    CoinPackage(
      code: '268302',
      name: 'Affie Coin Pack2',
      price: '\$9.99',
      coins: 1000,
      type: CoinPackageType.normal,
    ),
    CoinPackage(
      code: '268303',
      name: 'Affie Coin Pack3',
      price: '\$19.99',
      coins: 2500,
      type: CoinPackageType.normal,
    ),
    CoinPackage(
      code: '268304',
      name: 'Affie Coin Pack4',
      price: '\$49.99',
      coins: 7000,
      type: CoinPackageType.normal,
    ),
    CoinPackage(
      code: '268305',
      name: 'Affie Coin Pack5',
      price: '\$99.99',
      coins: 15000,
      type: CoinPackageType.normal,
    ),

    // 促销商品
    CoinPackage(
      code: '268306',
      name: 'Affie Coin Pack6',
      price: '\$0.99',
      coins: 298,
      type: CoinPackageType.promotion,
    ),
    CoinPackage(
      code: '268307',
      name: 'Affie Coin Pack7',
      price: '\$1.99',
      coins: 500,
      type: CoinPackageType.promotion,
    ),
    CoinPackage(
      code: '268308',
      name: 'Affie Coin Pack8',
      price: '\$4.99',
      coins: 1198,
      type: CoinPackageType.promotion,
    ),
    CoinPackage(
      code: '268309',
      name: 'Affie Coin Pack9',
      price: '\$11.99',
      coins: 2398,
      type: CoinPackageType.promotion,
    ),
    CoinPackage(
      code: '268310',
      name: 'Affie Coin Pack10',
      price: '\$49.99',
      coins: 10000,
      type: CoinPackageType.promotion,
    ),
    CoinPackage(
      code: '268311',
      name: 'Affie Coin Pack11',
      price: '\$79.99',
      coins: 14999,
      type: CoinPackageType.promotion,
    ),
  ];

  // 获取常规商品
  static List<CoinPackage> get normalPackages =>
      packages.where((p) => p.type == CoinPackageType.normal).toList();

  // 获取促销商品
  static List<CoinPackage> get promotionPackages =>
      packages.where((p) => p.type == CoinPackageType.promotion).toList();

  static List<CoinPackage> get orderedPackages {
    final normal = normalPackages..sort(_compareByPriceAsc);
    final promotion = promotionPackages..sort(_compareByPriceAsc);
    return [...normal, ...promotion];
  }

  static int _compareByPriceAsc(CoinPackage a, CoinPackage b) {
    final aPrice = _parsePrice(a.price);
    final bPrice = _parsePrice(b.price);
    return aPrice.compareTo(bPrice);
  }

  static double _parsePrice(String price) {
    return double.tryParse(price.replaceAll('\$', '').trim()) ?? 0;
  }

  // 根据 code 查找商品
  static CoinPackage? findByCode(String code) {
    try {
      return packages.firstWhere((p) => p.code == code);
    } catch (e) {
      return null;
    }
  }
}
