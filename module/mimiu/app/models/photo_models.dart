class PhotoModel {
  const PhotoModel({
    required this.id,
    required this.url,
    required this.categoryId,
    required this.timestamp,
    this.isPrivate,
    this.processed,
  });

  final String id;
  final String url;
  final String categoryId;
  final int timestamp;
  final bool? isPrivate;
  final bool? processed;
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.photoCount,
    required this.lastUpdated,
    this.coverPhoto,
  });

  final String id;
  final String name;
  final String? coverPhoto;
  final int photoCount;
  final int lastUpdated;
}

