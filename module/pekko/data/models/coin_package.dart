/// Coin package model for IAP
class CoinPackage {
  final String id;
  final String productId;
  final int coinAmount;
  final double price;
  final String? discountLabel;

  CoinPackage({
    required this.id,
    required this.productId,
    required this.coinAmount,
    required this.price,
    this.discountLabel,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      id: json['id'] as String,
      productId: json['productId'] as String,
      coinAmount: json['coinAmount'] as int,
      price: (json['price'] as num).toDouble(),
      discountLabel: json['discountLabel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'coinAmount': coinAmount,
      'price': price,
      'discountLabel': discountLabel,
    };
  }

  String get formattedPrice => '¥${price.toStringAsFixed(2)}';
  String get formattedCoins => '$coinAmount Coins';
}
