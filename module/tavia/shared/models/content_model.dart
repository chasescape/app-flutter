import 'package:tavia/gen_a/A.dart';

import '../../data/models/cherish_moment.dart';

/// Content model used across the gallery-style experience.
class ContentModel {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? authorId;
  final String? authorName;
  final String? authorAvatar;
  final int? likesCount;
  final int? commentsCount;
  final bool? isLiked;
  final bool? isBookmarked;
  final List<String>? tags;
  final DateTime? createdAt;

  ContentModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.authorId,
    this.authorName,
    this.authorAvatar,
    this.likesCount,
    this.commentsCount,
    this.isLiked,
    this.isBookmarked,
    this.tags,
    this.createdAt,
  });

  factory ContentModel.mock() {
    return mockByIndex(0);
  }

  static List<ContentModel> getMockList() {
    return List.generate(_assetGallery.length, mockByIndex);
  }

  static ContentModel mockByIndex(int index) {
    final normalized = index % _assetGallery.length;
    return ContentModel(
      id: 'content_$normalized',
      title: _titles[normalized],
      description: _descriptions[normalized],
      imageUrl: _assetGallery[normalized],
      authorId: 'author_$normalized',
      authorName: _authors[normalized],
      likesCount: 128 + normalized * 17,
      commentsCount: 18 + normalized * 5,
      isLiked: normalized.isEven,
      isBookmarked: normalized % 3 == 0,
      tags: _tags[normalized],
      createdAt: DateTime.now().subtract(Duration(hours: normalized * 6 + 2)),
    );
  }

  static final List<String> _assetGallery = [
    A.assets_tavia_1,
    A.assets_tavia_3,
    A.assets_tavia_5,
    A.assets_tavia_7,
    A.assets_tavia_9,
    A.assets_tavia_11,
    A.assets_tavia_13,
    A.assets_tavia_15,
    A.assets_tavia_17,
    A.assets_tavia_19,
  ];

  static const List<String> _titles = [
    'Sunset Whisper',
    'Bubble Garden',
    'Joy Spark',
    'Soft Glow',
    'Candy Air',
    'Mango Blush',
    'Pink Drift',
    'Golden Mood',
    'Neon Bloom',
    'Dream Pulse',
  ];

  static const List<String> _descriptions = [
    'Warm gradients and soft bloom create a dreamy scene with almost no visual noise.',
    'A playful composition that lets the image texture carry the story before any copy does.',
    'Bright accent color, rounded forms, and a soft-focus finish make the visual feel lively.',
    'A minimal frame with image-first hierarchy and lightweight storytelling.',
    'Rounded shapes and warm gloss give the artwork a polished, collectible feel.',
    'A sweet gradient blend with enough contrast to keep the focal image crisp and inviting.',
    'Clean spacing, vivid color, and a calm panel layout keep the attention on the visual.',
    'The composition feels premium because the supporting text stays quiet and secondary.',
    'A gallery-like presentation built around color, texture, and a single focal image.',
    'Soft shadows and bold curves make the image feel tangible instead of flat.',
  ];

  static const List<String> _authors = [
    'Luna',
    'Mia',
    'Avery',
    'Nova',
    'Iris',
    'Coco',
    'Nina',
    'Skye',
    'Poppy',
    'Elle',
  ];

  static const List<List<String>> _tags = [
    ['#Soft', '#Cover'],
    ['#Gallery', '#Sweet'],
    ['#Glow', '#Mood'],
    ['#Minimal', '#ImageFirst'],
    ['#Candy', '#Focus'],
    ['#Warm', '#Dreamy'],
    ['#Pink', '#Curated'],
    ['#Lush', '#Premium'],
    ['#Pop', '#Visual'],
    ['#Modern', '#Bloom'],
  ];

  factory ContentModel.fromCherishMoment({
    required String id,
    required CherishMoment moment,
    String? imagePath,
    DateTime? createdAt,
  }) {
    final shortDescription = moment.shareableCaption.trim().isNotEmpty
        ? moment.shareableCaption.trim()
        : moment.oneLineMoment.trim();

    return ContentModel(
      id: id,
      title: moment.cardTitle,
      description: shortDescription,
      imageUrl:
          (imagePath != null && imagePath.trim().isNotEmpty) ? imagePath : moment.assetImg,
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      isBookmarked: true,
      tags: moment.moodTags,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  ContentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isBookmarked,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return ContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
