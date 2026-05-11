class CoinProduct {
  final String id;
  final String code;
  final String name;
  final int coinAmount;
  final double price;
  final String currencyCode;
  final String? localizedPrice;
  final String? description;
  final bool isBestValue;
  final bool isPromotion;
  final String? originalPriceText;
  final double? discountPercentage;

  CoinProduct({
    required this.id,
    required this.code,
    required this.name,
    required this.coinAmount,
    required this.price,
    required this.currencyCode,
    this.localizedPrice,
    this.description,
    this.isBestValue = false,
    this.isPromotion = false,
    this.originalPriceText,
    this.discountPercentage,
  });

  String get displayPrice => localizedPrice ?? '\$$price';

  String get discountText {
    if (discountPercentage != null) {
      return '-${discountPercentage!.toStringAsFixed(0)}%';
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'coinAmount': coinAmount,
      'price': price,
      'currencyCode': currencyCode,
      'localizedPrice': localizedPrice,
      'description': description,
      'isBestValue': isBestValue,
      'isPromotion': isPromotion,
      'originalPriceText': originalPriceText,
      'discountPercentage': discountPercentage,
    };
  }

  factory CoinProduct.fromJson(Map<String, dynamic> json) {
    return CoinProduct(
      id: json['id'] as String,
      code: json['code'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      coinAmount: json['coinAmount'] as int,
      price: (json['price'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      localizedPrice: json['localizedPrice'] as String?,
      description: json['description'] as String?,
      isBestValue: json['isBestValue'] as bool? ?? false,
      isPromotion: json['isPromotion'] as bool? ?? false,
      originalPriceText: json['originalPriceText'] as String?,
      discountPercentage: json['discountPercentage'] as double?,
    );
  }
}
