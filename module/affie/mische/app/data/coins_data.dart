class CoinProduct {
  const CoinProduct({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.coins,
    required this.type,
    this.originalPrice,
  });

  final String id;
  final String productId;
  final String title;
  final double price;
  final int coins;
  final CoinProductType type;
  final double? originalPrice; // 促销商品的原价
}

enum CoinProductType { regular, promotion }

class CoinsData {
  static const List<CoinProduct> products = [
    // 常规商品 - 按价格排序
    CoinProduct(
      id: '264900',
      productId: 'Mische Coin Vault0',
      title: '99 coins - Pack',
      price: 0.99,
      coins: 99,
      type: CoinProductType.regular,
    ),
    CoinProduct(
      id: '264912',
      productId: 'Mische Coin Vault12',
      title: 'Coins Pack',
      price: 3.99,
      coins: 400,
      type: CoinProductType.regular,
    ),
    CoinProduct(
      id: '264901',
      productId: 'Mische Coin Vault1',
      title: '500 coins - Pack',
      price: 4.99,
      coins: 500,
      type: CoinProductType.regular,
    ),
    CoinProduct(
      id: '264913',
      productId: 'Mische Coin Vault13',
      title: 'Coins Pack',
      price: 6.99,
      coins: 700,
      type: CoinProductType.regular,
    ),
    CoinProduct(
      id: '264902',
      productId: 'Mische Coin Vault2',
      title: '999 coins - Pack',
      price: 9.99,
      coins: 999,
      type: CoinProductType.regular,
    ),
    CoinProduct(
      id: '264903',
      productId: 'Mische Coin Vault3',
      title: '2400 coins - Pack',
      price: 19.99,
      coins: 2400,
      type: CoinProductType.regular,
    ),
    CoinProduct(
      id: '264904',
      productId: 'Mische Coin Vault4',
      title: '7000 coins - Pack',
      price: 49.99,
      coins: 7000,
      type: CoinProductType.regular,
    ),
    CoinProduct(
      id: '264905',
      productId: 'Mische Coin Vault5',
      title: '15000 coins - Pack',
      price: 99.99,
      coins: 15000,
      type: CoinProductType.regular,
    ),
    // 促销商品 - 按价格排序
    CoinProduct(
      id: '264906',
      productId: 'Mische Coin Vault6',
      title: '300 coins - Limited Time',
      price: 0.99,
      coins: 300,
      type: CoinProductType.promotion,
      originalPrice: 2.99,
    ),
    CoinProduct(
      id: '264907',
      productId: 'Mische Coin Vault7',
      title: '750 coins - Limited Time',
      price: 2.99,
      coins: 750,
      type: CoinProductType.promotion,
      originalPrice: 7.49,
    ),
    CoinProduct(
      id: '264908',
      productId: 'Mische Coin Vault8',
      title: '1198 coins - Limited Time',
      price: 4.99,
      coins: 1198,
      type: CoinProductType.promotion,
      originalPrice: 11.99,
    ),
    CoinProduct(
      id: '264909',
      productId: 'Mische Coin Vault9',
      title: '2498 coins - Limited Time',
      price: 11.99,
      coins: 2498,
      type: CoinProductType.promotion,
      originalPrice: 23.99,
    ),
    CoinProduct(
      id: '264910',
      productId: 'Mische Coin Vault10',
      title: '10000 coins - Limited Time',
      price: 49.99,
      coins: 10000,
      type: CoinProductType.promotion,
      originalPrice: 99.99,
    ),
    CoinProduct(
      id: '264911',
      productId: 'Mische Coin Vault11',
      title: '15000 coins - Limited Time',
      price: 79.99,
      coins: 15000,
      type: CoinProductType.promotion,
      originalPrice: 149.99,
    ),
  ];

  static List<CoinProduct> get sortedProducts {
    final sorted = List<CoinProduct>.from(products);
    sorted.sort((a, b) => a.price.compareTo(b.price));
    return sorted;
  }

  static List<CoinProduct> get regularProducts {
    return sortedProducts.where((p) => p.type == CoinProductType.regular).toList();
  }

  static List<CoinProduct> get promotionProducts {
    return sortedProducts.where((p) => p.type == CoinProductType.promotion).toList();
  }
}
