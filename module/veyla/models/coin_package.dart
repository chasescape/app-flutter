class CoinPackage {
  final String id;
  final String name;
  final int coinAmount;
  final double price;
  final bool isBestValue;

  const CoinPackage({
    required this.id,
    required this.name,
    required this.coinAmount,
    required this.price,
    this.isBestValue = false,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedCoins => '$coinAmount coins';
}

class CoinPackages {
  static const int initialCoins = 30;
  static const int dailyCheckInCost = 1;

  static const List<CoinPackage> all = [
    CoinPackage(
      id: 'starter',
      name: 'Starter',
      coinAmount: 100,
      price: 0.99,
    ),
    CoinPackage(
      id: 'basic',
      name: 'Basic',
      coinAmount: 500,
      price: 4.99,
    ),
    CoinPackage(
      id: 'premium',
      name: 'Premium',
      coinAmount: 1200,
      price: 9.99,
    ),
    CoinPackage(
      id: 'ultimate',
      name: 'Ultimate',
      coinAmount: 3000,
      price: 19.99,
    ),
    CoinPackage(
      id: 'best_value',
      name: 'Best Value',
      coinAmount: 6500,
      price: 49.99,
      isBestValue: true,
    ),
  ];

  static int getCheckInCost() => dailyCheckInCost;
}
