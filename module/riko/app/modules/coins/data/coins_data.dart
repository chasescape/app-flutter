class CoinProductData {
  final String code;
  final String name;
  final String description;
  final double price;
  final int coins;
  final String type;

  const CoinProductData({
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.coins,
    required this.type,
  });
}

const List<CoinProductData> coinsData = [
  CoinProductData(
    code: '273300',
    name: 'Riko Coin Vault0',
    description: '99 coins - Package',
    price: 0.99,
    coins: 99,
    type: '常规',
  ),
  CoinProductData(
    code: '273312',
    name: 'Riko Coin Vault12',
    description: 'Coins - Package',
    price: 4.99,
    coins: 499,
    type: '常规',
  ),
  CoinProductData(
    code: '273301',
    name: 'Riko Coin Vault1',
    description: '599 coins - Package',
    price: 5.99,
    coins: 599,
    type: '常规',
  ),
  CoinProductData(
    code: '273313',
    name: 'Riko Coin Vault13',
    description: 'Coins - Package',
    price: 6.99,
    coins: 699,
    type: '常规',
  ),
  CoinProductData(
    code: '273302',
    name: 'Riko Coin Vault2',
    description: '1000 coins - Package',
    price: 9.99,
    coins: 1000,
    type: '常规',
  ),
  CoinProductData(
    code: '273303',
    name: 'Riko Coin Vault3',
    description: '2400 coins - Package',
    price: 19.99,
    coins: 2400,
    type: '常规',
  ),
  CoinProductData(
    code: '273304',
    name: 'Riko Coin Vault4',
    description: '7000 coins - Package',
    price: 49.99,
    coins: 7000,
    type: '常规',
  ),
  CoinProductData(
    code: '273305',
    name: 'Riko Coin Vault5',
    description: '15000 coins - Package',
    price: 99.99,
    coins: 15000,
    type: '常规',
  ),
  CoinProductData(
    code: '273306',
    name: 'Riko Coin Vault6',
    description: '300 coins - Flash Deal',
    price: 0.99,
    coins: 300,
    type: '促销',
  ),
  CoinProductData(
    code: '273307',
    name: 'Riko Coin Vault7',
    description: '498 coins - Flash Deal',
    price: 1.99,
    coins: 498,
    type: '促销',
  ),
  CoinProductData(
    code: '273308',
    name: 'Riko Coin Vault8',
    description: '1198 coins - Flash Deal',
    price: 4.99,
    coins: 1198,
    type: '促销',
  ),
  CoinProductData(
    code: '273309',
    name: 'Riko Coin Vault9',
    description: '2400 coins - Flash Deal',
    price: 11.99,
    coins: 2400,
    type: '促销',
  ),
  CoinProductData(
    code: '273310',
    name: 'Riko Coin Vault10',
    description: '10000 coins - Flash Deal',
    price: 49.99,
    coins: 10000,
    type: '促销',
  ),
  CoinProductData(
    code: '273311',
    name: 'Riko Coin Vault11',
    description: '17998 coins - Flash Deal',
    price: 99.99,
    coins: 17998,
    type: '促销',
  ),
];
