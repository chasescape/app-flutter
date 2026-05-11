enum CoinProductType {
  regular,
  promo,
}

extension CoinProductTypeX on CoinProductType {
  String get label {
    switch (this) {
      case CoinProductType.regular:
        return 'Regular';
      case CoinProductType.promo:
        return 'Promo';
    }
  }
}

class CoinProductData {
  const CoinProductData({
    required this.code,
    required this.name,
    required this.description,
    required this.priceUsd,
    required this.coins,
    required this.type,
  });

  final int code;
  final String name;
  final String description;
  final double priceUsd;
  final int coins;
  final CoinProductType type;
}

/// Static product table (seed data).
///
/// Columns:
/// - code: product code
/// - name: product name
/// - description: discount/promo description
/// - priceUsd: USD price
/// - coins: coin amount
/// - type: regular or promo
const List<CoinProductData> kCoinProducts = [
  CoinProductData(
    code: 261800,
    name: 'Mimiu Coin Vault0',
    description: 'Standard: 100 coins',
    priceUsd: 0.99,
    coins: 100,
    type: CoinProductType.regular,
  ),
  CoinProductData(
    code: 261812,
    name: 'Mimiu Coin Vault12',
    description: 'Standard',
    priceUsd: 3.99,
    coins: 400,
    type: CoinProductType.regular,
  ),
  CoinProductData(
    code: 261801,
    name: 'Mimiu Coin Vault1',
    description: 'Standard: 500 coins',
    priceUsd: 4.99,
    coins: 500,
    type: CoinProductType.regular,
  ),
  CoinProductData(
    code: 261813,
    name: 'Mimiu Coin Vault13',
    description: 'Standard',
    priceUsd: 6.99,
    coins: 699,
    type: CoinProductType.regular,
  ),
  CoinProductData(
    code: 261802,
    name: 'Mimiu Coin Vault2',
    description: 'Standard: 1000 coins',
    priceUsd: 9.99,
    coins: 1000,
    type: CoinProductType.regular,
  ),
  CoinProductData(
    code: 261803,
    name: 'Mimiu Coin Vault3',
    description: 'Standard: 2500 coins',
    priceUsd: 19.99,
    coins: 2500,
    type: CoinProductType.regular,
  ),
  CoinProductData(
    code: 261804,
    name: 'Mimiu Coin Vault4',
    description: 'Standard: 7000 coins',
    priceUsd: 49.99,
    coins: 7000,
    type: CoinProductType.regular,
  ),
  CoinProductData(
    code: 261805,
    name: 'Mimiu Coin Vault5',
    description: 'Standard: 15000 coins',
    priceUsd: 99.99,
    coins: 15000,
    type: CoinProductType.regular,
  ),
  CoinProductData(
    code: 261806,
    name: 'Mimiu Coin Vault6',
    description: '298 coins - Time-Limited Pack',
    priceUsd: 0.99,
    coins: 298,
    type: CoinProductType.promo,
  ),
  CoinProductData(
    code: 261807,
    name: 'Mimiu Coin Vault7',
    description: '500 coins - Time-Limited Pack',
    priceUsd: 1.99,
    coins: 500,
    type: CoinProductType.promo,
  ),
  CoinProductData(
    code: 261808,
    name: 'Mimiu Coin Vault8',
    description: '1200 coins - Time-Limited Pack',
    priceUsd: 4.99,
    coins: 1200,
    type: CoinProductType.promo,
  ),
  CoinProductData(
    code: 261809,
    name: 'Mimiu Coin Vault9',
    description: '2399 coins - Time-Limited Pack',
    priceUsd: 11.99,
    coins: 2399,
    type: CoinProductType.promo,
  ),
  CoinProductData(
    code: 261810,
    name: 'Mimiu Coin Vault10',
    description: '6999 coins - Time-Limited Pack',
    priceUsd: 34.99,
    coins: 6999,
    type: CoinProductType.promo,
  ),
  CoinProductData(
    code: 261811,
    name: 'Mimiu Coin Vault11',
    description: '18000 coins - Time-Limited Pack',
    priceUsd: 99.99,
    coins: 18000,
    type: CoinProductType.promo,
  ),
];

