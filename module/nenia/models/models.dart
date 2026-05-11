class Post {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String userId;
  final String userName;
  final String userAvatar;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;
  final List<String> tags;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.likes,
    this.isLiked = false,
    required this.createdAt,
    this.tags = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt']) ?? DateTime.now(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'likes': likes,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    String? userId,
    String? userName,
    String? userAvatar,
    int? likes,
    bool? isLiked,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }
}

class CoinPackage {
  final String id;
  final int coins;
  final double price;
  final String? originalPrice;
  final bool isPopular;
  final bool isBestValue;
  final String icon;

  CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    this.originalPrice,
    this.isPopular = false,
    this.isBestValue = false,
    this.icon = 'v',
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      id: json['id'] ?? '',
      coins: json['coins'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice'],
      isPopular: json['isPopular'] ?? false,
      isBestValue: json['isBestValue'] ?? false,
      icon: json['icon'] ?? 'v',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coins': coins,
      'price': price,
      'originalPrice': originalPrice,
      'isPopular': isPopular,
      'isBestValue': isBestValue,
      'icon': icon,
    };
  }
}

class User {
  final String id;
  final String name;
  final String? avatar;
  final int coins;
  final bool isVip;
  final DateTime? vipExpireAt;

  User({
    required this.id,
    required this.name,
    this.avatar,
    this.coins = 0,
    this.isVip = false,
    this.vipExpireAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      coins: json['coins'] ?? 0,
      isVip: json['isVip'] ?? false,
      vipExpireAt: json['vipExpireAt'] != null
          ? DateTime.tryParse(json['vipExpireAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'coins': coins,
      'isVip': isVip,
      'vipExpireAt': vipExpireAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    int? coins,
    bool? isVip,
    DateTime? vipExpireAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      coins: coins ?? this.coins,
      isVip: isVip ?? this.isVip,
      vipExpireAt: vipExpireAt ?? this.vipExpireAt,
    );
  }
}
