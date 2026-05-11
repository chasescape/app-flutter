import 'dart:convert';
import 'package:get/get.dart' as getx;
import '../models/hairstyle_result.dart';
import '../env/app_env.dart';

class ApiService {
  static const String _baseUrl = 'https://api.example.com';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Generate Hairstyle Preview
  static Future<HairstyleResult> generateHairstyle({
    required String imagePath,
    required int coinsUsed,
  }) async {
    try {
      // In a real app, this would make an API call
      // For MVP, we'll simulate a response

      await Future.delayed(const Duration(seconds: 2));

      // Mock response
      return HairstyleResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalImagePath: imagePath,
        previewImagePath: null, // In real app, this would be the generated image URL
        mainStyleName: _getRandomStyleName(),
        whyItFits: _getRandomWhyItFits(),
        alternativeSuggestions: _getRandomSuggestions(),
        barberNote: _getRandomBarberNote(),
        createdAt: DateTime.now(),
        coinsUsed: coinsUsed,
      );
    } catch (e) {
      throw Exception('Failed to generate hairstyle: $e');
    }
  }

  // Regenerate Hairstyle Preview
  static Future<HairstyleResult> regenerateHairstyle({
    required String resultId,
    required int coinsUsed,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      return HairstyleResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalImagePath: '',
        previewImagePath: null,
        mainStyleName: _getRandomStyleName(),
        whyItFits: _getRandomWhyItFits(),
        alternativeSuggestions: _getRandomSuggestions(),
        barberNote: _getRandomBarberNote(),
        createdAt: DateTime.now(),
        coinsUsed: coinsUsed,
      );
    } catch (e) {
      throw Exception('Failed to regenerate hairstyle: $e');
    }
  }

  // Submit Feedback
  static Future<bool> submitFeedback({
    required String feedback,
    String? email,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  // Helper methods for mock data
  static String _getRandomStyleName() {
    final styles = [
      'Soft Layer Bob',
      'Airy Curtain Bangs',
      'Clean Short Crop',
      'Textured Pixie',
      'Beach Waves',
      'Sleek Straight',
    ];
    return styles[DateTime.now().millisecond % styles.length];
  }

  static String _getRandomWhyItFits() {
    final reasons = [
      'Perfect for your face shape, adding softness and movement',
      'Complements your features beautifully while keeping maintenance low',
      'Enhances your natural texture and fits your lifestyle perfectly',
      'Creates a harmonious balance with your facial structure',
    ];
    return reasons[DateTime.now().millisecond % reasons.length];
  }

  static List<StyleSuggestion> _getRandomSuggestions() {
    return [
      StyleSuggestion(
        styleName: 'Textured Layers',
        description: 'Adds dimension and movement for a casual look',
      ),
      StyleSuggestion(
        styleName: 'Side Swept Bangs',
        description: 'Frames the face while adding softness',
      ),
    ];
  }

  static String _getRandomBarberNote() {
    return "I'd like a style that's modern but easy to maintain. Please keep the length around shoulder level with soft layers throughout.";
  }
}
