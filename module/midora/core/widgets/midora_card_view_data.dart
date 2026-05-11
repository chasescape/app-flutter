import '../../../gen_a/A.dart';
import '../../data/models/scene_card.dart';
import '../../models/lyric_card.dart';

class MidoraCardViewData {
  const MidoraCardViewData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.tags,
    required this.isSceneCard,
    required this.kicker,
  });

  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final List<String> tags;
  final bool isSceneCard;
  final String kicker;
}

MidoraCardViewData describeMidoraCard(dynamic card) {
  if (card is SceneCard) {
    return MidoraCardViewData(
      title: card.sceneCard.location.value.isEmpty
          ? 'Midnight Dream'
          : card.sceneCard.location.value,
      subtitle: card.sceneCard.mood.value.isEmpty
          ? 'Soft glow'
          : card.sceneCard.mood.value,
      description: card.visualStory,
      imagePath:
          card.assetImg.isEmpty ? A.assets_midora_MidoraOpen : card.assetImg,
      tags: [
        if (card.sceneCard.time.value.isNotEmpty) card.sceneCard.time.value,
        if (card.sceneCard.subject.value.isNotEmpty)
          card.sceneCard.subject.value,
        ...card.emotionalKeywords.take(2),
      ],
      isSceneCard: true,
      kicker: 'Scene',
    );
  }

  if (card is LyricCard) {
    final url = card.imageUrl?.trim() ?? '';
    return MidoraCardViewData(
      title: card.title.isEmpty ? 'Untitled track' : card.title,
      subtitle: card.artist.isEmpty ? 'Unknown artist' : card.artist,
      description: card.content,
      // Do not show a default thumbnail for lyric cards; only render when user provided one.
      imagePath: url,
      tags: [
        if (card.genre.isNotEmpty) card.genre,
        if (card.album.isNotEmpty) card.album,
      ],
      isSceneCard: false,
      kicker: 'Lyric',
    );
  }

  return MidoraCardViewData(
    title: 'Midora',
    subtitle: 'Dream collection',
    description: '',
    imagePath: A.assets_midora_MidoraOpen,
    tags: ['Gallery'],
    isSceneCard: true,
    kicker: 'Scene',
  );
}
