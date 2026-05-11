import 'dart:async';
import '../models/user_model.dart';
import '../models/content_model.dart';

/// API Service - Eager Singleton Pattern
/// Centralized API service for all backend calls
class ApiService {
  // Eager initialization
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // ============ Auth APIs ============

  /// Login (Mock)
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    // Mock login - in real app, call actual API
    await Future.delayed(const Duration(seconds: 1));
    return UserModel.mock();
  }

  /// Logout
  Future<void> logout() async {
    // Mock logout
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Get user profile
  Future<UserModel> getUserProfile() async {
    // Mock API call
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel.mock();
  }

  /// Update user profile
  Future<UserModel> updateUserProfile(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel.mock();
  }

  /// Delete account
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ============ Content APIs ============

  /// Get home feed
  Future<List<ContentModel>> getHomeFeed({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ContentModel.getMockList();
  }

  /// Get content detail
  Future<ContentModel> getContentDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ContentModel.mock();
  }

  /// Like content
  Future<void> likeContent(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Unlike content
  Future<void> unlikeContent(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Bookmark content
  Future<void> bookmarkContent(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Remove bookmark
  Future<void> removeBookmark(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Get user's history
  Future<List<ContentModel>> getUserHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ContentModel.getMockList();
  }

  /// Get user's liked items
  Future<List<ContentModel>> getUserLikedItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ContentModel.getMockList();
  }

  // ============ Create APIs ============

  /// Upload image
  Future<String> uploadImage(String filePath) async {
    // Mock upload - return mock URL
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/uploaded_image.jpg';
  }

  /// Create content with AI
  Future<Map<String, dynamic>> createContent({
    required String imageUrl,
    required String style,
    List<String>? stickerIds,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'result_url': 'https://example.com/ai_result.jpg',
      'content_id': 'mock_content_id',
    };
  }

  // ============ Store APIs ============

  /// Get coin packages
  Future<List<CoinPackage>> getCoinPackages() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CoinPackage.getMockList();
  }

  /// Purchase coins
  Future<Map<String, dynamic>> purchaseCoins({
    required String packageId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'coins_added': 100,
    };
  }

  /// Get user balance
  Future<int> getUserBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 100;
  }

  // ============ Feedback APIs ============

  /// Submit feedback
  Future<void> submitFeedback({
    required String content,
    String? voiceData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Coin Package Model
class CoinPackage {
  final String id;
  final int coins;
  final double price;
  final double? originalPrice;
  final bool isSale;

  CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    this.originalPrice,
    this.isSale = false,
  });

  static List<CoinPackage> getMockList() {
    return [
      CoinPackage(
        id: '1',
        coins: 100,
        price: 0.99,
        originalPrice: 1.99,
      ),
      CoinPackage(
        id: '2',
        coins: 500,
        price: 4.99,
        originalPrice: 9.99,
        isSale: true,
      ),
      CoinPackage(
        id: '3',
        coins: 1000,
        price: 9.99,
        originalPrice: 19.99,
      ),
      CoinPackage(
        id: '4',
        coins: 2500,
        price: 19.99,
        originalPrice: 49.99,
        isSale: true,
      ),
    ];
  }
}
