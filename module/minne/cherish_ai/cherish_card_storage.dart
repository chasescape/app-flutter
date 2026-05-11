import '../core/models/creation_model.dart';
import '../data/datasources/local_storage.dart';
import '../data/models/cherish_card.dart';

/// CherishCard 数据持久化工具
class CherishCardStorage {
  static Future<void> save({
    required CherishCard data,
    required String imagePath,
    required int costCoins,
  }) async {
    final history = await getList();
    final existingCreations = await LocalStorage.getCreationsData();

    final item = CherishCardHistoryItem(
      id: data.id,
      data: data,
      createdAt: DateTime.now(),
      imagePath: imagePath,
      costCoins: costCoins,
    );

    history.removeWhere((entry) => entry.id == item.id);
    history.insert(0, item);
    await LocalStorage.setCherishCardsData(
      history.map((entry) => entry.data.toStorageJson()).toList(),
    );

    final creation = CreationModel(
      id: item.id,
      userId: 'current_user',
      imageUrl: imagePath,
      resultText: data.meta.oneLineMoment,
      aiAnalysis: data.visualPoetry.shortHealingText,
      costCoins: costCoins,
      createdAt: item.createdAt,
    );
    existingCreations.removeWhere((entry) => entry['id'] == creation.id);
    existingCreations.insert(0, creation.toJson());
    await LocalStorage.setCreationsData(existingCreations);
  }

  static Future<List<CherishCardHistoryItem>> getList() async {
    final cardsJson = await LocalStorage.getCherishCardsData();
    final creations = await LocalStorage.getCreationsData();
    return cardsJson.map((json) {
      final card = CherishCard.fromStorageJson(json);
      Map<String, dynamic>? creationMatch;
      for (final entry in creations) {
        if (entry['id'] == card.id) {
          creationMatch = entry;
          break;
        }
      }
      return CherishCardHistoryItem(
        id: card.id,
        data: card,
        createdAt: creationMatch == null
            ? DateTime.tryParse(card.id) ?? DateTime.now()
            : DateTime.parse(creationMatch['createdAt'] as String),
        imagePath: creationMatch == null
            ? card.assetImg
            : creationMatch['imageUrl'] as String,
        costCoins: creationMatch == null
            ? 42
            : creationMatch['costCoins'] as int? ?? 42,
      );
    }).toList();
  }

  static Future<bool> delete(String id) async {
    final history = await getList();
    final creations = await LocalStorage.getCreationsData();
    final initialLength = history.length;

    history.removeWhere((item) => item.id == id);
    creations.removeWhere((item) => item['id'] == id);

    if (history.length < initialLength) {
      await LocalStorage.setCherishCardsData(
        history.map((entry) => entry.data.toStorageJson()).toList(),
      );
      await LocalStorage.setCreationsData(creations);
      return true;
    }
    return false;
  }

  static Future<void> clear() async {
    await LocalStorage.setCherishCardsData(const []);
    await LocalStorage.removeCreationsData();
  }
}

class CherishCardHistoryItem {
  final String id;
  final CherishCard data;
  final DateTime createdAt;
  final String imagePath;
  final int costCoins;

  CherishCardHistoryItem({
    required this.id,
    required this.data,
    required this.createdAt,
    required this.imagePath,
    required this.costCoins,
  });

  String get shortSummary => data.meta.oneLineMoment;
}
