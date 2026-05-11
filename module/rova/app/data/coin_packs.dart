class CoinPackData {
  const CoinPackData({
    required this.productId,
    required this.displayName,
    required this.title,
    required this.usdPrice,
    required this.coins,
    required this.category,
    this.originalUsdPrice,
  });

  final int productId;
  final String displayName;
  final String title;
  final String usdPrice;
  final String? originalUsdPrice;
  final int coins;
  final CoinPackCategory category;

  String get priceLabel => '\$$usdPrice';
  String? get originalPriceLabel =>
      (originalUsdPrice == null || originalUsdPrice!.trim().isEmpty)
          ? null
          : '\$${originalUsdPrice!.trim()}';
}

enum CoinPackCategory { standard, promo }

const List<CoinPackData> kCoinPacks = [
  CoinPackData(
    productId: 283100,
    displayName: 'Rova Coin Bundle0',
    title: '99 coins - Standard',
    usdPrice: '0.99',
    coins: 99,
    category: CoinPackCategory.standard,
  ),
  CoinPackData(
    productId: 283112,
    displayName: 'Rova Coin Bundle12',
    title: 'Standard Price',
    usdPrice: '3.99',
    coins: 400,
    category: CoinPackCategory.standard,
  ),
  CoinPackData(
    productId: 283101,
    displayName: 'Rova Coin Bundle1',
    title: '499 coins - Standard',
    usdPrice: '4.99',
    coins: 499,
    category: CoinPackCategory.standard,
  ),
  CoinPackData(
    productId: 283113,
    displayName: 'Rova Coin Bundle13',
    title: 'Standard Price',
    usdPrice: '6.99',
    coins: 700,
    category: CoinPackCategory.standard,
  ),
  CoinPackData(
    productId: 283102,
    displayName: 'Rova Coin Bundle2',
    title: '1199 coins - Standard',
    usdPrice: '9.99',
    coins: 1199,
    category: CoinPackCategory.standard,
  ),
  CoinPackData(
    productId: 283103,
    displayName: 'Rova Coin Bundle3',
    title: '2500 coins - Standard',
    usdPrice: '19.99',
    coins: 2500,
    category: CoinPackCategory.standard,
  ),
  CoinPackData(
    productId: 283104,
    displayName: 'Rova Coin Bundle4',
    title: '7000 coins - Standard',
    usdPrice: '49.99',
    coins: 7000,
    category: CoinPackCategory.standard,
  ),
  CoinPackData(
    productId: 283105,
    displayName: 'Rova Coin Bundle5',
    title: '15000 coins - Standard',
    usdPrice: '99.99',
    coins: 15000,
    category: CoinPackCategory.standard,
  ),
  CoinPackData(
    productId: 283106,
    displayName: 'Rova Coin Bundle6',
    title: '298 coins - Limited Time',
    usdPrice: '0.99',
    originalUsdPrice: '3.99',
    coins: 298,
    category: CoinPackCategory.promo,
  ),
  CoinPackData(
    productId: 283107,
    displayName: 'Rova Coin Bundle7',
    title: '749 coins - Limited Time',
    usdPrice: '2.99',
    originalUsdPrice: '6.99',
    coins: 749,
    category: CoinPackCategory.promo,
  ),
  CoinPackData(
    productId: 283108,
    displayName: 'Rova Coin Bundle8',
    title: '1198 coins - Limited Time',
    usdPrice: '4.99',
    originalUsdPrice: '9.99',
    coins: 1198,
    category: CoinPackCategory.promo,
  ),
  CoinPackData(
    productId: 283109,
    displayName: 'Rova Coin Bundle9',
    title: '2598 coins - Limited Time',
    usdPrice: '12.99',
    originalUsdPrice: '19.99',
    coins: 2598,
    category: CoinPackCategory.promo,
  ),
  CoinPackData(
    productId: 283110,
    displayName: 'Rova Coin Bundle10',
    title: '10000 coins - Limited Time',
    usdPrice: '49.99',
    originalUsdPrice: '69.99',
    coins: 10000,
    category: CoinPackCategory.promo,
  ),
  CoinPackData(
    productId: 283111,
    displayName: 'Rova Coin Bundle11',
    title: '17999 coins - Limited Time',
    usdPrice: '99.99',
    originalUsdPrice: '129.99',
    coins: 17999,
    category: CoinPackCategory.promo,
  ),
];
