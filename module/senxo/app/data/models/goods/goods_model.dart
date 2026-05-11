/// 商品模型
class GoodsModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int coinAmount;
  final String? icon;
  final bool isPopular;
  final bool isAvailable;

  GoodsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.coinAmount,
    this.icon,
    this.isPopular = false,
    this.isAvailable = true,
  });

  /// 从JSON创建商品模型
  factory GoodsModel.fromJson(Map<String, dynamic> json) {
    return GoodsModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      coinAmount: int.tryParse(json['coinAmount']?.toString() ?? '0') ?? 0,
      icon: json['icon']?.toString(),
      isPopular: json['isPopular'] == true,
      isAvailable: json['isAvailable'] != false, // 默认为true
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'coinAmount': coinAmount,
      'icon': icon,
      'isPopular': isPopular,
      'isAvailable': isAvailable,
    };
  }

  /// 格式化价格显示
  String get formattedPrice {
    return '$currency ${price.toStringAsFixed(2)}';
  }

  /// 复制并修改部分字段
  GoodsModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    int? coinAmount,
    String? icon,
    bool? isPopular,
    bool? isAvailable,
  }) {
    return GoodsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      coinAmount: coinAmount ?? this.coinAmount,
      icon: icon ?? this.icon,
      isPopular: isPopular ?? this.isPopular,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  String toString() {
    return 'GoodsModel{id: $id, name: $name, price: $price, coinAmount: $coinAmount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoodsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}