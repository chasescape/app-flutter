import 'package:flutter/foundation.dart';

/// Post Model - Daily Happiness App
class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final List<String> images;
  final List<String> tags;
  final int likes;
  final int downloads;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.images,
    this.tags = const [],
    this.likes = 0,
    this.downloads = 0,
    required this.createdAt,
  });

  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    List<String>? images,
    List<String>? tags,
    int? likes,
    int? downloads,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      downloads: downloads ?? this.downloads,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'images': images,
      'tags': tags,
      'likes': likes,
      'downloads': downloads,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      images: List<String>.from(json['images'] as List),
      tags: List<String>.from(json['tags'] as List? ?? []),
      likes: json['likes'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Posts State - Manages community posts
class PostsState extends ChangeNotifier {
  final List<PostModel> _posts = [];
  bool _isLoading = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  void setPosts(List<PostModel> posts) {
    _posts.clear();
    _posts.addAll(posts);
    notifyListeners();
  }

  void addPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void updatePost(String postId, PostModel updatedPost) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  void likePost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(likes: _posts[index].likes + 1);
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }

  static final PostsState _instance = PostsState._internal();
  PostsState._internal();
  factory PostsState() => _instance;
}
