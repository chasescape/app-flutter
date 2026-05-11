import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../models/lash_style.dart';
import '../models/lash_history_item.dart';
import '../../../services/image_edit_service.dart';
import '../../../services/coins_manager.dart';

class InsufficientCoinsException implements Exception {
  final int required;
  final int current;

  InsufficientCoinsException({required this.required, required this.current});

  @override
  String toString() => 'InsufficientCoinsException: Need $required coins, but only have $current';
}

class LashProvider with ChangeNotifier {
  static const int imageToImageCost = 42;

  final GetIt getIt;
  late final SharedPreferences prefs;
  late final ImageEditService _imageEditService;
  late final CoinsManager coinsManager;

  LashStyle? _selectedStyle;
  String? _selectedImagePath;
  int _freeCount = 0;
  List<LashHistoryItem> _history = [];

  LashProvider(this.getIt) {
    prefs = getIt<SharedPreferences>();
    _imageEditService = ImageEditService();
    coinsManager = CoinsManager();
    _loadUserData();
  }

  LashStyle? get selectedStyle => _selectedStyle;
  String? get selectedImagePath => _selectedImagePath;
  int get coins => coinsManager.currentCoins;
  int get freeCount => _freeCount;
  List<LashHistoryItem> get history => _history;

  void _loadUserData() {
    _freeCount = prefs.getInt('freeCount') ?? (1 + (DateTime.now().millisecond % 3));
    _loadHistory();
    notifyListeners();
  }

  void _loadHistory() {
    final historyJson = prefs.getStringList('history') ?? [];
    _history = historyJson.map((json) {
      return LashHistoryItem.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(json) as Map,
        ),
      );
    }).toList();
    if (_history.length > 30) {
      _history = _history.sublist(0, 30);
    }
  }

  void _saveHistory() {
    final historyJson = _history.map((item) => jsonEncode(item.toJson())).toList();
    prefs.setStringList('history', historyJson);
  }

  void selectStyle(LashStyle style) {
    _selectedStyle = style;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImagePath = pickedFile.path;
      notifyListeners();
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _selectedImagePath = pickedFile.path;
      notifyListeners();
    }
  }

  void clearSelectedImage() {
    _selectedImagePath = null;
    notifyListeners();
  }

  Future<String?> generatePreview() async {
    if (_selectedImagePath == null || _selectedStyle == null) {
      return null;
    }

    if (_freeCount == 0 && !coinsManager.isEnough(imageToImageCost)) {
      throw InsufficientCoinsException(
        required: imageToImageCost,
        current: coinsManager.currentCoins,
      );
    }

    try {
      final sourceImages = [File(_selectedImagePath!)];
      final prompt = _buildPromptForStyle(_selectedStyle!);

      final historyItem = await _imageEditService.createImageToImageResult(
        sourceImages: sourceImages,
        prompt: prompt,
        styleId: _selectedStyle!.id,
        styleName: _selectedStyle!.name,
        size: '1024x1024',
      );

      final enrichedItem = _enrichHistoryItemWithProductCopy(historyItem);

      if (_freeCount > 0) {
        _freeCount--;
        prefs.setInt('freeCount', _freeCount);
      } else {
        await coinsManager.subCoins(imageToImageCost);
      }

      _history.insert(0, enrichedItem.copyWith(coinsUsed: imageToImageCost));
      if (_history.length > 30) {
        _history.removeLast();
      }
      _saveHistory();

      notifyListeners();
      return enrichedItem.previewImageUrl;
    } catch (e) {
      debugPrint('Generate preview error: $e');
      rethrow;
    }
  }

  String _buildPromptForStyle(LashStyle style) {
    final baseInstruction = 'Transform the uploaded eye photo by adding';

    switch (style.id) {
      case 'natural':
        return '$baseInstruction natural-looking medium-length J-curl eyelashes that create a subtle, awake look. The lashes blend seamlessly with natural lashes, adding gentle definition without appearing overdone. Soft, natural lighting enhances the understated elegance.';
      case 'glamour':
        return '$baseInstruction long C-curl eyelashes that are longer at the outer corners, creating a cat-eye winged effect. The lashes should add noticeable length and curl while maintaining elegance for a sophisticated, red-carpet ready look.';
      case 'doll':
        return '$baseInstruction long D-curl eyelashes that curl upward dramatically, emphasizing the doll-like eye shape. The lashes should be longest at the center to enhance that innocent, wide-eyed look.';
      default:
        return '$baseInstruction ${style.length.toLowerCase()} ${style.curl} eyelashes for a ${style.description}';
    }
  }

  LashHistoryItem _enrichHistoryItemWithProductCopy(LashHistoryItem item) {
    final styleCopy = _getProductCopyForStyle(item.styleId);
    return item.copyWith(
      title: styleCopy['title'],
      subtitle: styleCopy['subtitle'],
      whyBetter: styleCopy['whyBetter'],
      howItWorks: styleCopy['howItWorks'],
      styleMood: styleCopy['styleMood'],
      bestFor: styleCopy['bestFor'],
    );
  }

  Map<String, String> _getProductCopyForStyle(String styleId) {
    switch (styleId) {
      case 'natural':
        return {
          'title': 'Natural Enhancement for Everyday Elegance',
          'subtitle': 'Subtle length, J-curl for a gentle awake look',
          'whyBetter': 'Natural lashes add definition without the drama - perfect for work, school, or any occasion where you want polished but effortless beauty.',
          'howItWorks': 'Upload your eye photo, select Natural style, and watch AI create a seamless lash enhancement that looks like your own lashes - only better.',
          'styleMood': 'Understated, clean, professional',
          'bestFor': 'First-time lash users, natural makeup lovers',
        };
      case 'glamour':
        return {
          'title': 'Glamour - Red Carpet Ready',
          'subtitle': 'Long C-curl for dramatic, sophisticated allure',
          'whyBetter': 'Glamour lashes deliver that special-occasion drama - think date nights, parties, and whenever you want to turn heads.',
          'howItWorks': 'AI analyzes your eye shape and applies the perfect C-curl pattern, giving you salon-worthy glamour in seconds.',
          'styleMood': 'Sophisticated, dramatic, confident',
          'bestFor': 'Special occasions, almond eyes, glamour lovers',
        };
      case 'doll':
        return {
          'title': 'Doll Eyes - Youthful & Playful',
          'subtitle': 'Long D-curl for that innocent, wide-eyed effect',
          'whyBetter': 'Doll lashes maximize your eye\'s natural roundness for a youthful, innocent look that\'s perfect for photos and special occasions.',
          'howItWorks': 'Your eye photo becomes a canvas for AI-precise D-curl lashes that lift and open your eyes into a captivating doll-eye effect.',
          'styleMood': 'Playful, youthful, eye-catching',
          'bestFor': 'Round eyes, selfie lovers, playful styles',
        };
      default:
        return {
          'title': 'Lash Enhancement',
          'subtitle': 'Beautiful lash transformation',
          'whyBetter': 'Enhance your natural beauty with AI-powered lash preview.',
          'howItWorks': 'Upload your photo and let AI create your perfect lash look.',
          'styleMood': 'Beautiful',
          'bestFor': 'Everyone',
        };
    }
  }

  bool get _canGenerate => _freeCount > 0 || coinsManager.isEnough(imageToImageCost);

  bool get canGenerate => _canGenerate;

  static int get costPerCreation => imageToImageCost;

  void deleteHistoryItem(String id) {
    _history.removeWhere((item) => item.id == id);
    _saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    _imageEditService.dispose();
    super.dispose();
  }
}
