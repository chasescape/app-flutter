import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../data/models/style_analysis.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/coins_manager.dart';
import '../routes/app_pages.dart';
import '../style_ai/style_analysis_storage.dart';

class GlobalController extends GetxController {
  static GlobalController get to => Get.find();

  final Rxn<User> currentUser = Rxn<User>();
  final RxList<Post> posts = <Post>[].obs;
  final RxList<Post> myPosts = <Post>[].obs;
  final RxList<StyleAnalysis> styleAnalysisHistory = <StyleAnalysis>[].obs;

  CoinsManager get coinsManager => CoinsManager.to;
  int get currentCoins => coinsManager.currentCoins;

  bool get isLoggedIn => currentUser.value != null;
  User? get user => currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadPosts();
    _loadStyleAnalysisHistory();
  }

  Future<void> _loadUserData() async {
    try {
      await Get.find<StorageService>().getString('user_data');
      currentUser.value = User.fromJson({
        'id': 'currentUser',
        'name': 'Me',
        'coins': CoinsManager.to.currentCoins
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      currentUser.value = User(
          id: 'currentUser', name: 'Me', coins: CoinsManager.to.currentCoins);
    }
  }

  Future<void> _loadPosts() async {
    posts.value = _getMockPosts();
    myPosts.value = _getMockMyPosts();
  }

  List<Post> _getMockPosts() {
    return [
      Post(
        id: '1',
        title: 'Neon Dreams',
        content: 'Exploring the vibrant nightlife of the city...',
        imageUrl: 'https://picsum.photos/400/600?random=1',
        userId: 'user1',
        userName: 'Alice',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        likes: 128,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['night', 'neon', 'city'],
      ),
      Post(
        id: '2',
        title: 'Retro Vibes',
        content: 'Channeling the 80s aesthetic with modern twists...',
        imageUrl: 'https://picsum.photos/400/500?random=2',
        userId: 'user2',
        userName: 'Bob',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        likes: 256,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        tags: ['retro', '80s', 'art'],
      ),
      Post(
        id: '3',
        title: 'Pink Paradise',
        content: 'Lost in a world of pink hues and warm lights...',
        imageUrl: 'https://picsum.photos/400/550?random=3',
        userId: 'user3',
        userName: 'Carol',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        likes: 89,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['pink', 'paradise', 'aesthetic'],
      ),
      Post(
        id: '4',
        title: 'Glow Up',
        content: 'Transformation complete. New era, new energy...',
        imageUrl: 'https://picsum.photos/400/450?random=4',
        userId: 'user1',
        userName: 'Alice',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        likes: 342,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['glow', 'transformation', 'energy'],
      ),
      Post(
        id: '5',
        title: 'Midnight Magic',
        content: 'When the clock strikes twelve, magic happens...',
        imageUrl: 'https://picsum.photos/400/600?random=5',
        userId: 'user4',
        userName: 'David',
        userAvatar: 'https://i.pravatar.cc/150?img=4',
        likes: 167,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['midnight', 'magic', 'fantasy'],
      ),
    ];
  }

  List<Post> _getMockMyPosts() {
    return [
      Post(
        id: '101',
        title: 'My First Post',
        content: 'Hello world! This is my first creation...',
        imageUrl: 'https://picsum.photos/400/500?random=10',
        userId: 'currentUser',
        userName: 'Me',
        userAvatar: 'https://i.pravatar.cc/150?img=5',
        likes: 42,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['first', 'hello'],
      ),
      Post(
        id: '102',
        title: 'Creative Journey',
        content: 'Documenting my creative process...',
        imageUrl: 'https://picsum.photos/400/600?random=11',
        userId: 'currentUser',
        userName: 'Me',
        userAvatar: 'https://i.pravatar.cc/150?img=5',
        likes: 78,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        tags: ['creative', 'journey'],
      ),
    ];
  }

  void toggleLike(String postId) {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = posts[index];
      posts[index] = post.copyWith(
        isLiked: !post.isLiked,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
      );
      posts.refresh();
    }
  }

  void addPost(Post post) {
    myPosts.insert(0, post);
    posts.insert(0, post);
  }

  Future<void> updateCoins(int amount) async {
    if (amount > 0) {
      await coinsManager.addCoins(amount);
    } else if (amount < 0) {
      await coinsManager.subCoins(amount.abs());
    }

    if (currentUser.value != null) {
      currentUser.value =
          currentUser.value!.copyWith(coins: coinsManager.currentCoins);
      _saveUserData();
    }
  }

  void _saveUserData() {
    if (currentUser.value != null) {
      try {
        Get.find<StorageService>()
            .setString('user_data', currentUser.value.toString());
      } catch (e) {
        debugPrint('Error saving user data: $e');
      }
    }
  }

  Future<void> logout({
    bool clearLocalData = false,
    bool clearCoins = false,
  }) async {
    currentUser.value = null;
    posts.clear();
    myPosts.clear();

    try {
      final storage = Get.find<StorageService>();

      if (clearLocalData) {
        await storage.clear();
      } else {
        await storage.remove('user_data');
      }

      if (clearCoins) {
        await CoinsManager.to.clear();
      }

      await AuthService.to.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }

    Get.offAllNamed(Routes.login);
  }

  Future<void> _loadStyleAnalysisHistory() async {
    await refreshStyleAnalysisHistory();
  }

  Future<void> refreshStyleAnalysisHistory() async {
    try {
      final historyItems = await StyleAnalysisStorage.getList();
      styleAnalysisHistory.value = historyItems.map((item) {
        item.data.assetImg = item.imagePath ?? item.data.assetImg;
        return item.data;
      }).toList();
    } catch (e) {
      debugPrint('Error loading style analysis history: $e');
      styleAnalysisHistory.value = [];
    }
  }

  void addStyleAnalysis(StyleAnalysis analysis) {
    styleAnalysisHistory.insert(0, analysis);
    styleAnalysisHistory.refresh();
  }

  Future<void> clearStyleAnalysisHistory() async {
    try {
      await StyleAnalysisStorage.clear();
      styleAnalysisHistory.clear();
    } catch (e) {
      debugPrint('Error clearing style analysis history: $e');
    }
  }
}
