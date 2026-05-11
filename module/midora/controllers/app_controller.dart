import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/lyric_card.dart';
import '../data/mock/mock_data.dart';
import '../data/models/scene_card.dart';
import '../features/store/contact_coins.dart';
import '../services/purchase_service.dart';
import '../services/coins_manager.dart';
import '../interface.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// App Controller - Global state management
class AppController extends GetxController {
  // Singleton instance
  static AppController get I => Get.find();

  // User data
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxInt coins = 100.obs;

  // Scene cards data (from mock_data.dart)
  final RxList<dynamic> feedCards = <dynamic>[].obs;
  final RxList<LyricCard> myLikedCards = <LyricCard>[].obs;
  final RxList<LyricCard> myCreatedCards = <LyricCard>[].obs;
  final RxList<SceneCard> mySceneCards = <SceneCard>[].obs;

  // Loading states
  final RxBool isLoadingFeed = false.obs;
  final RxBool isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  /// Load initial data
  void _loadInitialData() {
    // Load scene cards from mock_data.dart
    feedCards.value = allSceneData;
    myLikedCards.value = _getMockLikedCards();
    myCreatedCards.value = _getMockCreatedCards();
    _loadSceneCards();
  }

  /// Login action
  Future<void> login() async {
    await Future.delayed(const Duration(seconds: 1));
    await CoinsManager.I.initialize();

    // Set mock user
    final persistedCoins = CoinsManager.I.currentCoins;
    currentUser.value = User(
      id: '1',
      name: 'Music Lover',
      avatar: null,
      coins: persistedCoins,
      likedCount: myLikedCards.length,
      createdCount: myCreatedCards.length,
    );

    isLoggedIn.value = true;
    coins.value = persistedCoins;
  }

  /// Logout action
  Future<void> logout() async {
    currentUser.value = null;
    isLoggedIn.value = false;
    // Keep Interface login state in sync so app entry can show LoginPage.
    await Interface().persistAuthToken(null);
    // Keep local data (coins/history) on logout.
    // Only account deletion should clear persisted local data.
  }

  /// Add coins
  void addCoins(int amount) {
    coins.value += amount;
    _updateUser();
  }

  /// Deduct coins
  bool deductCoins(int amount) {
    if (coins.value >= amount) {
      coins.value -= amount;
      _updateUser();
      return true;
    }
    return false;
  }

  /// Toggle like on card
  void toggleLike(dynamic card) {
    // SceneCard doesn't have like functionality in the current model
    // This method is kept for compatibility but does nothing
  }

  /// Create new lyric card
  Future<void> createCard(LyricCard card) async {
    myCreatedCards.insert(0, card);
    feedCards.insert(0, card);

    final user = currentUser.value;
    if (user != null) {
      currentUser.value = user.copyWith(
        createdCount: user.createdCount + 1,
      );
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    await logout();
    // Clear local user data on account deletion.
    await CoinsManager.I.clear();
    await _clearSceneCards();
    coins.value = 100;
    _loadInitialData();
  }

  /// Save SceneCard to persistent storage
  Future<void> saveSceneCard(SceneCard sceneCard) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sceneCards = await _loadSceneCardsFromStorage();

      // Add new scene card at the beginning
      sceneCards.insert(0, sceneCard);

      // Save to storage
      final jsonString = jsonEncode(
        sceneCards.map((card) => card.toJson()).toList(),
      );
      await prefs.setString('scene_cards', jsonString);

      // Update in-memory list
      mySceneCards.insert(0, sceneCard);
      feedCards.insert(0, sceneCard);
    } catch (e) {
      print('Error saving scene card: $e');
    }
  }

  String _sceneCardKey(SceneCard card) {
    // Stable-ish key to match stored cards without introducing a new id field.
    return '${card.assetImg}::${card.visualStory}';
  }

  /// Delete a SceneCard (updates in-memory lists and persistent storage)
  Future<void> deleteSceneCard(SceneCard sceneCard) async {
    final key = _sceneCardKey(sceneCard);

    // Optimistically update in-memory state for immediate UI feedback.
    final myIndex = mySceneCards.indexWhere((card) => _sceneCardKey(card) == key);
    if (myIndex != -1) {
      mySceneCards.removeAt(myIndex);
    }

    final feedIndex = feedCards.indexWhere(
      (card) => card is SceneCard && _sceneCardKey(card) == key,
    );
    if (feedIndex != -1) {
      feedCards.removeAt(feedIndex);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = await _loadSceneCardsFromStorage();
      stored.removeWhere((card) => _sceneCardKey(card) == key);

      final jsonString = jsonEncode(
        stored.map((card) => card.toJson()).toList(),
      );
      await prefs.setString('scene_cards', jsonString);
    } catch (e) {
      print('Error deleting scene card: $e');
    }
  }

  /// Delete a created LyricCard (in-memory only)
  void deleteLyricCard(LyricCard card) {
    final createdIndex = myCreatedCards.indexWhere((item) => item.id == card.id);
    if (createdIndex != -1) {
      myCreatedCards.removeAt(createdIndex);
    }

    final feedIndex = feedCards.indexWhere(
      (item) => item is LyricCard && item.id == card.id,
    );
    if (feedIndex != -1) {
      feedCards.removeAt(feedIndex);
    }
  }

  /// Load SceneCards from persistent storage
  Future<void> _loadSceneCards() async {
    try {
      final sceneCards = await _loadSceneCardsFromStorage();
      mySceneCards.value = sceneCards;

      // Add to feed cards
      feedCards.value = [...sceneCards, ...allSceneData];
    } catch (e) {
      print('Error loading scene cards: $e');
      mySceneCards.clear();
    }
  }

  /// Load SceneCards from SharedPreferences
  Future<List<SceneCard>> _loadSceneCardsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('scene_cards');

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => SceneCard.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing scene cards from storage: $e');
      return [];
    }
  }

  /// Clear all SceneCards from storage
  Future<void> _clearSceneCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('scene_cards');
      mySceneCards.clear();
    } catch (e) {
      print('Error clearing scene cards: $e');
    }
  }

  /// Update user data
  void _updateUser() {
    final user = currentUser.value;
    if (user != null) {
      currentUser.value = user.copyWith(coins: coins.value);
    }
  }

  /// Mock feed cards
  List<LyricCard> _getMockFeedCards() {
    return [
      LyricCard(
        id: '1',
        title: 'Bohemian Rhapsody',
        content:
            'Is this the real life? Is this just fantasy? Caught in a landside, no escape from reality...',
        imageUrl: null,
        artist: 'Queen',
        album: 'A Night at the Opera',
        genre: 'Rock',
        likes: 1234,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      LyricCard(
        id: '2',
        title: 'Shape of You',
        content:
            'The club isn\'t the best place to find a lover, so the bar is where I go...',
        imageUrl: null,
        artist: 'Ed Sheeran',
        album: '÷',
        genre: 'Pop',
        likes: 856,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      LyricCard(
        id: '3',
        title: 'Blinding Lights',
        content:
            'I\'ve been tryna call, I\'ve been on my own for long enough...',
        imageUrl: null,
        artist: 'The Weeknd',
        album: 'After Hours',
        genre: 'Synth-pop',
        likes: 2341,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Mock liked cards
  List<LyricCard> _getMockLikedCards() {
    return [
      LyricCard(
        id: '4',
        title: 'Someone Like You',
        content:
            'I heard that you\'re settled down, that you found a girl and you\'re married now...',
        imageUrl: null,
        artist: 'Adele',
        album: '21',
        genre: 'Pop',
        likes: 5678,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isLiked: true,
      ),
    ];
  }

  /// Mock created cards
  List<LyricCard> _getMockCreatedCards() {
    return [
      LyricCard(
        id: '5',
        title: 'My Own Song',
        content: 'Writing lyrics in the night, dreaming of a morning light...',
        imageUrl: null,
        artist: 'Me',
        album: 'Demo',
        genre: 'Indie',
        likes: 42,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}

/// Coin Store Controller
class CoinStoreController extends GetxController {
  static CoinStoreController get I => Get.find();

  final List<Contact575CoinProduct> packages =
      Privatised236CoinProductData.allProductsGrouped;

  /// Purchase coins with real in-app purchase
  Future<void> purchaseCoins(
    Contact575CoinProduct package, {
    VoidCallback? onSuccess,
    Function(String? error)? onError,
  }) async {
    final completer = Completer<void>();

    void finish() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    await PurchaseService.I.executePurchase(
      productId: package.goodsId,
      coins: package.exchangeCoin,
      onResult: (success, coins, error) {
        if (success) {
          onSuccess?.call();
        } else {
          onError?.call(error);
        }
        finish();
      },
    );

    try {
      await completer.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          onError?.call('Purchase timeout');
          finish();
        },
      );
    } catch (_) {
      // noop
    }
  }
}
