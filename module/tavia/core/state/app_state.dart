import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/user_model.dart';
import '../../shared/models/content_model.dart';

/// App State - Stream-based State Management
/// Centralized state management using StreamController
class AppState {
  // Eager initialization
  static final AppState _instance = AppState._internal();

  factory AppState() {
    return _instance;
  }

  AppState._internal();

  // ============ User State ============

  final StreamController<UserModel?> _userController =
      StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  Stream<UserModel?> get userStream => _userController.stream;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void setUser(UserModel? user) {
    _currentUser = user;
    _userController.add(user);
  }

  void updateUser(Map<String, dynamic> data) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        username: data['username'] as String?,
        avatar: data['avatar'] as String?,
        coinBalance: data['coinBalance'] as int?,
      );
      _userController.add(_currentUser);
    }
  }

  void clearUser() {
    _currentUser = null;
    _userController.add(null);
  }

  // ============ Content State ============

  final StreamController<List<ContentModel>> _homeFeedController =
      StreamController<List<ContentModel>>.broadcast();
  List<ContentModel> _homeFeed = [];
  bool _isLoadingHomeFeed = false;

  Stream<List<ContentModel>> get homeFeedStream => _homeFeedController.stream;
  List<ContentModel> get homeFeed => _homeFeed;
  bool get isLoadingHomeFeed => _isLoadingHomeFeed;

  void setHomeFeedLoading(bool loading) {
    _isLoadingHomeFeed = loading;
  }

  void setHomeFeed(List<ContentModel> feed) {
    _homeFeed = feed;
    _homeFeedController.add(feed);
  }

  void updateContentInFeed(String contentId, ContentModel updatedContent) {
    final index = _homeFeed.indexWhere((c) => c.id == contentId);
    if (index != -1) {
      _homeFeed[index] = updatedContent;
      _homeFeedController.add(_homeFeed);
    }
  }

  void likeContent(String contentId) {
    final index = _homeFeed.indexWhere((c) => c.id == contentId);
    if (index != -1) {
      final content = _homeFeed[index];
      final updatedContent = content.copyWith(
        isLiked: !(content.isLiked ?? false),
        likesCount: (content.likesCount ?? 0) + (content.isLiked ?? false ? -1 : 1),
      );
      _homeFeed[index] = updatedContent;
      _homeFeedController.add(_homeFeed);
    }
  }

  void bookmarkContent(String contentId) {
    final index = _homeFeed.indexWhere((c) => c.id == contentId);
    if (index != -1) {
      final content = _homeFeed[index];
      final updatedContent = content.copyWith(
        isBookmarked: !(content.isBookmarked ?? false),
      );
      _homeFeed[index] = updatedContent;
      _homeFeedController.add(_homeFeed);
    }
  }

  // ============ History State ============

  final StreamController<List<ContentModel>> _historyController =
      StreamController<List<ContentModel>>.broadcast();
  List<ContentModel> _history = [];
  bool _isLoadingHistory = false;

  Stream<List<ContentModel>> get historyStream => _historyController.stream;
  List<ContentModel> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;

  void setHistoryLoading(bool loading) {
    _isLoadingHistory = loading;
  }

  void setHistory(List<ContentModel> history) {
    _history = history;
    _historyController.add(history);
  }

  void addToHistory(ContentModel content) {
    _history.insert(0, content);
    _historyController.add(_history);
  }

  void removeFromHistory(String contentId) {
    _history.removeWhere((c) => c.id == contentId);
    _historyController.add(_history);
  }

  void clearHistory() {
    _history = [];
    _historyController.add(_history);
  }

  // ============ Liked Items State ============

  final StreamController<List<ContentModel>> _likedItemsController =
      StreamController<List<ContentModel>>.broadcast();
  List<ContentModel> _likedItems = [];
  bool _isLoadingLikedItems = false;

  Stream<List<ContentModel>> get likedItemsStream => _likedItemsController.stream;
  List<ContentModel> get likedItems => _likedItems;
  bool get isLoadingLikedItems => _isLoadingLikedItems;

  void setLikedItemsLoading(bool loading) {
    _isLoadingLikedItems = loading;
  }

  void setLikedItems(List<ContentModel> items) {
    _likedItems = items;
    _likedItemsController.add(items);
  }

  void toggleLikeItem(ContentModel content) {
    final index = _likedItems.indexWhere((c) => c.id == content.id);
    if (index != -1) {
      _likedItems.removeAt(index);
    } else {
      _likedItems.insert(0, content.copyWith(isLiked: true));
    }
    _likedItemsController.add(_likedItems);
  }

  // ============ Coin Balance State ============

  final StreamController<int> _coinBalanceController =
      StreamController<int>.broadcast();
  int _coinBalance = 0;

  Stream<int> get coinBalanceStream => _coinBalanceController.stream;
  int get coinBalance => _coinBalance;

  void setCoinBalance(int balance) {
    _coinBalance = balance;
    _coinBalanceController.add(balance);
    _persistCoinBalance(balance);
  }

  void addCoins(int amount) {
    _coinBalance += amount;
    _coinBalanceController.add(_coinBalance);
    _persistCoinBalance(_coinBalance);
  }

  void spendCoins(int amount) {
    _coinBalance -= amount;
    _coinBalanceController.add(_coinBalance);
    _persistCoinBalance(_coinBalance);
  }

  void clearCoinBalance() {
    _coinBalance = 0;
    _coinBalanceController.add(_coinBalance);
    _persistCoinBalance(_coinBalance);
  }

  Future<void> _persistCoinBalance(int balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coin_balance', balance);
  }

  // ============ Loading State ============

  final StreamController<bool> _globalLoadingController =
      StreamController<bool>.broadcast();
  bool _isGlobalLoading = false;

  Stream<bool> get globalLoadingStream => _globalLoadingController.stream;
  bool get isGlobalLoading => _isGlobalLoading;

  void setGlobalLoading(bool loading) {
    _isGlobalLoading = loading;
    _globalLoadingController.add(loading);
  }

  void clearSessionData() {
    clearUser();
    _homeFeed = [];
    _homeFeedController.add(_homeFeed);
    clearHistory();
    _likedItems = [];
    _likedItemsController.add(_likedItems);
    clearCoinBalance();
    _isLoadingHomeFeed = false;
    _isLoadingHistory = false;
    _isLoadingLikedItems = false;
    setGlobalLoading(false);
  }

  // ============ Dispose ============

  void dispose() {
    _userController.close();
    _homeFeedController.close();
    _historyController.close();
    _likedItemsController.close();
    _coinBalanceController.close();
    _globalLoadingController.close();
  }
}
