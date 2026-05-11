/// 订单模型
class OrderModel {
  final String orderId;
  final String goodsId;
  final String goodsName;
  final int quantity;
  final double totalPrice;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? paymentMethod;

  OrderModel({
    required this.orderId,
    required this.goodsId,
    required this.goodsName,
    required this.quantity,
    required this.totalPrice,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.paymentMethod,
  });

  /// 从JSON创建订单模型
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId']?.toString() ?? '',
      goodsId: json['goodsId']?.toString() ?? '',
      goodsName: json['goodsName']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null 
        ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now(),
      paidAt: json['paidAt'] != null 
        ? DateTime.tryParse(json['paidAt'].toString())
        : null,
      paymentMethod: json['paymentMethod']?.toString(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'goodsId': goodsId,
      'goodsName': goodsName,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'currency': currency,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
    };
  }

  /// 订单状态枚举
  static const String statusPending = 'pending';
  static const String statusPaid = 'paid';
  static const String statusFailed = 'failed';
  static const String statusCancelled = 'cancelled';

  /// 是否已支付
  bool get isPaid => status == statusPaid;

  /// 是否可以支付
  bool get canPay => status == statusPending;

  /// 格式化价格显示
  String get formattedPrice {
    return '$currency ${totalPrice.toStringAsFixed(2)}';
  }

  /// 状态显示文本
  String get statusText {
    switch (status) {
      case statusPending:
        return 'Pending';
      case statusPaid:
        return 'Paid';
      case statusFailed:
        return 'Payment failed';
      case statusCancelled:
        return 'Cancelled';
      default:
        return 'Unknown status';
    }
  }

  @override
  String toString() {
    return 'OrderModel{orderId: $orderId, goodsName: $goodsName, totalPrice: $totalPrice, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.orderId == orderId;
  }

  @override
  int get hashCode => orderId.hashCode;
}