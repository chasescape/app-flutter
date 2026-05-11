class CoinsProduct {
  final String code;
  final String description;
  final double price;
  final int coins;
  final String type; // 常规 / 促销
  final double? originalPrice;

  const CoinsProduct({
    required this.code,
    required this.description,
    required this.price,
    required this.coins,
    required this.type,
    this.originalPrice,
  });

  bool get isPromotion => type == '促销' && originalPrice != null;
}

class CoinsData {
  // Standard price baseline: 100 coins = $0.99
  static const double _baseRate = 0.99 / 100;

  static double _round2(double v) => double.parse(v.toStringAsFixed(2));

  static List<CoinsProduct> all() {
    return [
      const CoinsProduct(
        code: '279600',
        description: 'Standard Price: 100 coins',
        price: 0.99,
        coins: 100,
        type: '常规',
      ),
      const CoinsProduct(
        code: '279601',
        description: 'Standard Price: 399 coins',
        price: 3.99,
        coins: 399,
        type: '常规',
      ),
      const CoinsProduct(
        code: '279612',
        description: 'Standard Price',
        price: 4.99,
        coins: 499,
        type: '常规',
      ),
      const CoinsProduct(
        code: '279613',
        description: 'Standard Price',
        price: 6.99,
        coins: 699,
        type: '常规',
      ),
      const CoinsProduct(
        code: '279602',
        description: 'Standard Price: 1199 coins',
        price: 9.99,
        coins: 1199,
        type: '常规',
      ),
      const CoinsProduct(
        code: '279603',
        description: 'Standard Price: 2500 coins',
        price: 19.99,
        coins: 2500,
        type: '常规',
      ),
      const CoinsProduct(
        code: '279604',
        description: 'Standard Price: 7000 coins',
        price: 49.99,
        coins: 7000,
        type: '常规',
      ),
      const CoinsProduct(
        code: '279605',
        description: 'Standard Price: 15000 coins',
        price: 99.99,
        coins: 15000,
        type: '常规',
      ),
      CoinsProduct(
        code: '279606',
        description: '300 coins - Limited Promotion',
        price: 0.99,
        coins: 300,
        type: '促销',
        originalPrice: _round2(300 * _baseRate),
      ),
      CoinsProduct(
        code: '279607',
        description: '748 coins - Limited Promotion',
        price: 2.99,
        coins: 748,
        type: '促销',
        originalPrice: _round2(748 * _baseRate),
      ),
      CoinsProduct(
        code: '279608',
        description: '1200 coins - Limited Promotion',
        price: 4.99,
        coins: 1200,
        type: '促销',
        originalPrice: _round2(1200 * _baseRate),
      ),
      CoinsProduct(
        code: '279609',
        description: '1999 coins - Limited Promotion',
        price: 9.99,
        coins: 1999,
        type: '促销',
        originalPrice: _round2(1999 * _baseRate),
      ),
      CoinsProduct(
        code: '279610',
        description: '10000 coins - Limited Promotion',
        price: 49.99,
        coins: 10000,
        type: '促销',
        originalPrice: _round2(10000 * _baseRate),
      ),
      CoinsProduct(
        code: '279611',
        description: '17888 coins - Limited Promotion',
        price: 99.99,
        coins: 17888,
        type: '促销',
        originalPrice: _round2(17888 * _baseRate),
      ),

    ];
  }
}
