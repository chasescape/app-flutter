import 'package:get/get.dart';

/// Lyric Card Model
class LyricCard {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? audioUrl;
  final String artist;
  final String album;
  final String genre;
  final int likes;
  final DateTime createdAt;
  bool isLiked;

  LyricCard({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.audioUrl,
    required this.artist,
    required this.album,
    required this.genre,
    this.likes = 0,
    required this.createdAt,
    this.isLiked = false,
  });

  factory LyricCard.fromJson(Map<String, dynamic> json) {
    return LyricCard(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      genre: json['genre'] ?? '',
      likes: json['likes'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']) ?? DateTime.now(),
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'artist': artist,
      'album': album,
      'genre': genre,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
    };
  }

  LyricCard copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    String? audioUrl,
    String? artist,
    String? album,
    String? genre,
    int? likes,
    DateTime? createdAt,
    bool? isLiked,
  }) {
    return LyricCard(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

/// User Model
class User {
  final String id;
  final String name;
  final String? avatar;
  final int coins;
  final int likedCount;
  final int createdCount;

  User({
    required this.id,
    required this.name,
    this.avatar,
    this.coins = 100,
    this.likedCount = 0,
    this.createdCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      coins: json['coins'] ?? 100,
      likedCount: json['likedCount'] ?? 0,
      createdCount: json['createdCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'coins': coins,
      'likedCount': likedCount,
      'createdCount': createdCount,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    int? coins,
    int? likedCount,
    int? createdCount,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      coins: coins ?? this.coins,
      likedCount: likedCount ?? this.likedCount,
      createdCount: createdCount ?? this.createdCount,
    );
  }
}
