import 'composition_result.dart';
import 'image_edit_result.dart';

enum SavedResultType {
  composition,
  imageEdit,
}

class SavedResultItem {
  final String id;
  final SavedResultType type;
  final String imagePath;
  final String title;
  final String? subtitle;
  final String badgeLabel;
  final DateTime createdAt;
  final int coinsUsed;
  final CompositionResult? compositionResult;
  final ImageEditResult? imageEditResult;

  const SavedResultItem._({
    required this.id,
    required this.type,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.createdAt,
    required this.coinsUsed,
    this.compositionResult,
    this.imageEditResult,
  });

  factory SavedResultItem.fromComposition(CompositionResult result) {
    return SavedResultItem._(
      id: result.id,
      type: SavedResultType.composition,
      imagePath: result.originalImagePath,
      title: result.summary,
      subtitle: result.goal?.label,
      badgeLabel: result.imageType.label,
      createdAt: result.createdAt,
      coinsUsed: result.coinsUsed,
      compositionResult: result,
    );
  }

  factory SavedResultItem.fromImageEdit(ImageEditResult result) {
    return SavedResultItem._(
      id: result.id,
      type: SavedResultType.imageEdit,
      imagePath: result.resultImagePath,
      title: result.title,
      subtitle: result.subtitle,
      badgeLabel: 'AI remix',
      createdAt: result.createdAt,
      coinsUsed: result.coinsUsed,
      imageEditResult: result,
    );
  }
}
