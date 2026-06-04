// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinPackage _$CoinPackageFromJson(Map<String, dynamic> json) => CoinPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      coinAmount: (json['coinAmount'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      discount: json['discount'] as String?,
      originalPrice: json['originalPrice'] as String?,
    );

Map<String, dynamic> _$CoinPackageToJson(CoinPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'coinAmount': instance.coinAmount,
      'price': instance.price,
      'discount': instance.discount,
      'originalPrice': instance.originalPrice,
    };
