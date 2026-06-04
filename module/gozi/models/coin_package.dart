import 'package:json_annotation/json_annotation.dart';

part 'coin_package.g.dart';

/// Coin package model for IAP
@JsonSerializable()
class CoinPackage {
  final String id;
  final String name;
  final int coinAmount;
  final double price;
  final String? discount;
  final String? originalPrice;

  CoinPackage({
    required this.id,
    required this.name,
    required this.coinAmount,
    required this.price,
    this.discount,
    this.originalPrice,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) =>
      _$CoinPackageFromJson(json);

  Map<String, dynamic> toJson() => _$CoinPackageToJson(this);

  /// Get display price string
  String get priceDisplay => '\$${price.toStringAsFixed(2)}';

  /// Check if has discount
  bool get hasDiscount => discount != null && discount!.isNotEmpty;
}
