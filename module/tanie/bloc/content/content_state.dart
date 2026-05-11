import 'package:equatable/equatable.dart';

class ContentItem extends Equatable {
  final String id;
  final String title;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final int likes;
  final List<String> tags;

  const ContentItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.description,
    required this.createdAt,
    this.likes = 0,
    this.tags = const [],
  });

  ContentItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
    int? likes,
    List<String>? tags,
  }) {
    return ContentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [id, title, imageUrl, description, createdAt, likes, tags];
}

class ContentState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final List<ContentItem> items;
  final ContentItem? selectedItem;
  final String? errorMessage;
  final bool hasReachedMax;

  const ContentState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.items = const [],
    this.selectedItem,
    this.errorMessage,
    this.hasReachedMax = false,
  });

  ContentState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ContentItem>? items,
    ContentItem? selectedItem,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return ContentState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      items: items ?? this.items,
      selectedItem: selectedItem ?? this.selectedItem,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMore,
        items,
        selectedItem,
        errorMessage,
        hasReachedMax,
      ];
}
