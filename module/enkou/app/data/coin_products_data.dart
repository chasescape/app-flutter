class CoinProduct {
  const CoinProduct({
    required this.code,
    required this.name,
    required this.description,
    required this.priceLabel,
    required this.coins,
    required this.type,
    this.originalPrice,
    this.discountLabel,
  });

  final int code;
  final String name;
  final String description;
  final String priceLabel;
  final int coins;
  final CoinProductType type;
  final String? originalPrice;
  final String? discountLabel;
}

enum CoinProductType {
  regular,
  promo,
}

const List<CoinProduct> coinProducts = [
  // 常规（按金币数量升序）
  CoinProduct(
    code: 268600,
    name: 'Enkou Coin Set0',
    description: 'Standard: 99 coins',
    priceLabel: r'$0.99',
    coins: 99,
    type: CoinProductType.regular,
  ),
  CoinProduct(
    code: 268612,
    name: 'Enkou Coin Set12',
    description: 'Standard',
    priceLabel: r'$4.99',
    coins: 500,
    type: CoinProductType.regular,
  ),
  CoinProduct(
    code: 268601,
    name: 'Enkou Coin Set1',
    description: 'Standard: 599 coins',
    priceLabel: r'$5.99',
    coins: 599,
    type: CoinProductType.regular,
  ),
  CoinProduct(
    code: 268613,
    name: 'Enkou Coin Set13',
    description: 'Standard',
    priceLabel: r'$6.99',
    coins: 700,
    type: CoinProductType.regular,
  ),
  CoinProduct(
    code: 268602,
    name: 'Enkou Coin Set2',
    description: 'Standard: 1000 coins',
    priceLabel: r'$9.99',
    coins: 1000,
    type: CoinProductType.regular,
  ),
  CoinProduct(
    code: 268603,
    name: 'Enkou Coin Set3',
    description: 'Standard: 2400 coins',
    priceLabel: r'$19.99',
    coins: 2400,
    type: CoinProductType.regular,
  ),
  CoinProduct(
    code: 268604,
    name: 'Enkou Coin Set4',
    description: 'Standard: 7000 coins',
    priceLabel: r'$49.99',
    coins: 7000,
    type: CoinProductType.regular,
  ),
  CoinProduct(
    code: 268605,
    name: 'Enkou Coin Set5',
    description: 'Standard: 15000 coins',
    priceLabel: r'$99.99',
    coins: 15000,
    type: CoinProductType.regular,
  ),
  // 促销（按金币数量升序）
  CoinProduct(
    code: 268606,
    name: 'Enkou Coin Set6',
    description: 'Limited Deal: 300 coins',
    priceLabel: r'$0.99',
    coins: 300,
    type: CoinProductType.promo,
    originalPrice: r'$2.99',
    discountLabel: 'SALE',
  ),
  CoinProduct(
    code: 268607,
    name: 'Enkou Coin Set7',
    description: 'Limited Deal: 749 coins',
    priceLabel: r'$2.99',
    coins: 749,
    type: CoinProductType.promo,
    originalPrice: r'$5.99',
    discountLabel: 'SALE',
  ),
  CoinProduct(
    code: 268608,
    name: 'Enkou Coin Set8',
    description: 'Limited Deal: 1198 coins',
    priceLabel: r'$4.99',
    coins: 1198,
    type: CoinProductType.promo,
    originalPrice: r'$9.99',
    discountLabel: 'SALE',
  ),
  CoinProduct(
    code: 268609,
    name: 'Enkou Coin Set9',
    description: 'Limited Deal: 2400 coins',
    priceLabel: r'$11.99',
    coins: 2400,
    type: CoinProductType.promo,
    originalPrice: r'$19.99',
    discountLabel: 'SALE',
  ),
  CoinProduct(
    code: 268610,
    name: 'Enkou Coin Set10',
    description: 'Limited Deal: 6999 coins',
    priceLabel: r'$34.99',
    coins: 6999,
    type: CoinProductType.promo,
    originalPrice: r'$49.99',
    discountLabel: 'SALE',
  ),
  CoinProduct(
    code: 268611,
    name: 'Enkou Coin Set11',
    description: 'Limited Deal: 14998 coins',
    priceLabel: r'$79.99',
    coins: 14998,
    type: CoinProductType.promo,
    originalPrice: r'$99.99',
    discountLabel: 'SALE',
  ),
];
