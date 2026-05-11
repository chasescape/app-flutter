import 'package:zeria/zeria/constants/app_constants.dart';

// User Model
class User {
  final String id;
  final String name;
  final String? avatar;
  final int coins;

  User({
    required this.id,
    required this.name,
    this.avatar,
    this.coins = AppConstants.defaultCoins,
  });

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    int? coins,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      coins: coins ?? this.coins,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'coins': coins,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      coins: (json['coins'] as int?) ?? AppConstants.defaultCoins,
    );
  }

  // Default user
  static User get defaultUser => User(
        id: 'user_001',
        name: 'Zeria',
        avatar: null,
        coins: AppConstants.defaultCoins,
      );
}

// Create Parameters Model
class CreateParams {
  final String destination;
  final String? season;
  final String? time;
  final String? style;
  final String? landmark;
  final String? mood;
  final bool localPeople;

  CreateParams({
    required this.destination,
    this.season,
    this.time,
    this.style,
    this.landmark,
    this.mood,
    this.localPeople = false,
  });

  CreateParams copyWith({
    String? destination,
    String? season,
    String? time,
    String? style,
    String? landmark,
    String? mood,
    bool? localPeople,
  }) {
    return CreateParams(
      destination: destination ?? this.destination,
      season: season ?? this.season,
      time: time ?? this.time,
      style: style ?? this.style,
      landmark: landmark ?? this.landmark,
      mood: mood ?? this.mood,
      localPeople: localPeople ?? this.localPeople,
    );
  }

  factory CreateParams.fromJson(Map<String, dynamic> json) {
    return CreateParams(
      destination: json['destination'] as String,
      season: json['season'] as String?,
      time: json['time'] as String?,
      style: json['style'] as String?,
      landmark: json['landmark'] as String?,
      mood: json['mood'] as String?,
      localPeople: json['localPeople'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'season': season,
      'time': time,
      'style': style,
      'landmark': landmark,
      'mood': mood,
      'localPeople': localPeople,
    };
  }
}

// History Item Model
class HistoryItem {
  final String id;
  final String destination;
  final String imageUrl;
  final DateTime createdAt;
  final CreateParams? params;

  /// SparkFlow 分析结果（可选，用于图片分析功能）
  final Map<String, dynamic>? sparkResultData;

  HistoryItem({
    required this.id,
    required this.destination,
    required this.imageUrl,
    required this.createdAt,
    this.params,
    this.sparkResultData,
  });

  HistoryItem copyWith({
    String? id,
    String? destination,
    String? imageUrl,
    DateTime? createdAt,
    CreateParams? params,
    Map<String, dynamic>? sparkResultData,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      params: params ?? this.params,
      sparkResultData: sparkResultData ?? this.sparkResultData,
    );
  }

  /// 从 SparkResult 创建 HistoryItem
  factory HistoryItem.fromSparkResult(
    dynamic sparkResult, {
    String? destination,
  }) {
    // 假设 sparkResult 有 toJson 方法或者已经是 Map
    final data = sparkResult is Map ? sparkResult : sparkResult.toJson();
    final sparkId =
        sparkResult is Map ? data['id'] as String? : sparkResult.id as String?;

    return HistoryItem(
      id: sparkId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      destination:
          destination ?? data['one_line_summary'] as String? ?? 'Inspiration',
      imageUrl:
          data['image_path'] as String? ??
              data['asset_img'] as String? ??
              data['assetImg'] as String? ??
              '',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      sparkResultData: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'params': params?.toJson(),
      'sparkResultData': sparkResultData,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      destination: json['destination'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      params: json['params'] != null
          ? CreateParams.fromJson(json['params'] as Map<String, dynamic>)
          : null,
      sparkResultData: json['sparkResultData'] as Map<String, dynamic>?,
    );
  }

  /// 是否包含 SparkFlow 数据
  bool get hasSparkData => sparkResultData != null;

  // Date grouping for history
  String get dateGroup {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    final difference = today.difference(itemDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${createdAt.month}/${createdAt.year}';
  }
}

// Coin Package Model
class CoinPackage {
  final String id;
  final int coins;
  final double price;
  final bool isBestValue;
  final bool isHot;

  CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    this.isBestValue = false,
    this.isHot = false,
  });

  CoinPackage copyWith({
    String? id,
    int? coins,
    double? price,
    bool? isBestValue,
    bool? isHot,
  }) {
    return CoinPackage(
      id: id ?? this.id,
      coins: coins ?? this.coins,
      price: price ?? this.price,
      isBestValue: isBestValue ?? this.isBestValue,
      isHot: isHot ?? this.isHot,
    );
  }

  // Default coin packages
  static List<CoinPackage> get defaultPackages => [
        CoinPackage(
          id: 'package_100',
          coins: 100,
          price: 0.99,
        ),
        CoinPackage(
          id: 'package_500',
          coins: 500,
          price: 4.99,
        ),
        CoinPackage(
          id: 'package_1000',
          coins: 1000,
          price: 9.99,
          isBestValue: true,
        ),
        CoinPackage(
          id: 'package_2000',
          coins: 2000,
          price: 19.99,
          isHot: true,
        ),
      ];
}

// Feedback Type Enum
enum FeedbackType {
  bugReport,
  featureRequest,
  other,
}

extension FeedbackTypeExtension on FeedbackType {
  String get displayName {
    switch (this) {
      case FeedbackType.bugReport:
        return 'Bug Report';
      case FeedbackType.featureRequest:
        return 'Feature Request';
      case FeedbackType.other:
        return 'Other';
    }
  }
}
