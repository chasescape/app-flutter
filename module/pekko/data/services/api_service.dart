import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/perfume_record.dart';
import '../../env/app_env.dart';

/// Custom exception for perfume AI service errors
class PerfumeAIException implements Exception {
  final String message;
  final int? statusCode;

  PerfumeAIException(this.message, [this.statusCode]);

  @override
  String toString() => 'PerfumeAIException: $message${statusCode != null ? ' (code: $statusCode)' : ''}';
}

/// API service for network requests
/// Provides AI-powered perfume recommendations and analysis
class ApiService extends GetxService {
  static ApiService get to => Get.find();

  final http.Client _client;

  ApiService(this._client);

  static Future<ApiService> init() async {
    return ApiService(http.Client());
  }

  /// AI Analysis placeholder
  /// This would call an AI API to analyze perfume preferences
  Future<Map<String, dynamic>> analyzePreferences(
    List<PerfumeRecord> records,
  ) async {
    // Placeholder: Simulate AI analysis
    await Future.delayed(const Duration(seconds: 1));

    if (records.isEmpty) {
      return {
        'topNotes': <PerfumeNote>[],
        'favoritePerfumes': <String>[],
        'scenePreferences': <String, int>{},
        'seasonTrends': <String, List<PerfumeNote>>{},
      };
    }

    // Analyze note preferences
    final noteCount = <PerfumeNote, int>{};
    for (final record in records) {
      noteCount[record.noteType] = (noteCount[record.noteType] ?? 0) + 1;
    }

    final topNotes = noteCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Count scene preferences
    final sceneCount = <String, int>{};
    for (final record in records) {
      sceneCount[record.scene.displayName] =
          (sceneCount[record.scene.displayName] ?? 0) + 1;
    }

    // Analyze seasonal trends
    final seasonTrends = <String, List<PerfumeNote>>{};
    for (final record in records) {
      final season = record.season.displayName;
      seasonTrends.putIfAbsent(season, () => <PerfumeNote>[]);
      if (!seasonTrends[season]!.contains(record.noteType)) {
        seasonTrends[season]!.add(record.noteType);
      }
    }

    // Get top perfumes
    final perfumeCount = <String, int>{};
    for (final record in records) {
      final key = '${record.brand} ${record.perfumeName}';
      perfumeCount[key] = (perfumeCount[key] ?? 0) + 1;
    }

    final sortedPerfumes = perfumeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'topNotes': topNotes.take(3).map((e) => e.key).toList(),
      'favoritePerfumes':
          sortedPerfumes.take(3).map((e) => e.key).toList(),
      'scenePreferences': sceneCount,
      'seasonTrends': seasonTrends,
    };
  }

  /// Get perfume recommendations based on context using AI
  Future<List<Map<String, dynamic>>> getRecommendations({
    required UsageScene scene,
    required TimeOfDayType timeOfDay,
    required Season season,
    List<PerfumeRecord>? history,
  }) async {
    // Build AI prompt for recommendations
    final historyContext = history == null || history.isEmpty
        ? 'No previous history available.'
        : '''
User's perfume history:
${history.map((r) => '- ${r.brand} ${r.perfumeName} (${r.noteType.displayName}) for ${r.scene.displayName}, mood rating: ${r.moodRating}/5').join('\n')}

Top scent families used: ${_getTopNotes(history).map((n) => n.displayName).join(', ')}
Favorite scenes: ${_getTopScenes(history).join(', ')}
''';

    final prompt = '''
You are a perfume recommendation expert. Based on the user's history and current context, recommend 3 perfumes.

$historyContext

Current occasion:
- Scene: ${scene.displayName}
- Time of day: ${timeOfDay.displayName}
- Season: ${season.displayName}

Return ONLY a valid JSON array with this exact structure:
[
  {
    "name": "perfume name",
    "brand": "brand name",
    "note": "scent family (floral/woody/oriental/citrus/fresh/gourmand/green/spicy)",
    "reason": "brief personalized recommendation reason based on their history"
  }
]

Choose perfumes that match the occasion and align with their preferences shown in history.
''';

    try {
      final response = await _callClaudeAPI(prompt);

      // Parse AI response
      final jsonString = _extractJSON(response);
      if (jsonString == null) {
        throw PerfumeAIException('Invalid AI response format');
      }

      final jsonList = json.decode(jsonString) as List;
      final recommendations = <Map<String, dynamic>>[];

      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          final noteStr = item['note'] as String? ?? 'floral';
          final note = PerfumeNote.values.firstWhere(
            (n) => n.name.toLowerCase() == noteStr.toLowerCase() ||
                   n.displayName.toLowerCase() == noteStr.toLowerCase(),
            orElse: () => PerfumeNote.floral,
          );

          recommendations.add({
            'name': item['name'] as String? ?? 'Recommended Perfume',
            'brand': item['brand'] as String? ?? 'Brand',
            'note': note,
            'reason': item['reason'] as String? ?? 'Perfect for this occasion',
            'scene': scene.displayName,
            'timeOfDay': timeOfDay.displayName,
            'season': season.displayName,
          });
        }
      }

      return recommendations.isEmpty ? _getFallbackRecommendations(scene, timeOfDay, season) : recommendations;
    } on PerfumeAIException {
      rethrow;
    } catch (e) {
      // Fallback to mock recommendations on error
      return _getFallbackRecommendations(scene, timeOfDay, season);
    }
  }

  /// Call Claude API for recommendations
  Future<String> _callClaudeAPI(String prompt) async {
    final apiKey = AppEnv().geApiKey;
    if (apiKey.isEmpty) {
      throw PerfumeAIException('API key not configured');
    }

    final url = Uri.parse('https://api.anthropic.com/v1/messages');
    final requestBody = json.encode({
      'model': 'claude-3-haiku-20240307',
      'max_tokens': 1024,
      'messages': [
        {'role': 'user', 'content': prompt}
      ]
    });

    final response = await _client
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: requestBody,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      final errorBody = response.body.isNotEmpty ? response.body : 'Unknown error';
      throw PerfumeAIException('API request failed: ${response.statusCode} - $errorBody');
    }

    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    final content = jsonResponse['content'] as List?;
    if (content != null && content.isNotEmpty) {
      return content[0]['text'] as String? ?? '';
    }

    throw PerfumeAIException('Invalid API response structure');
  }

  /// Extract JSON from AI response (handles markdown code blocks)
  String? _extractJSON(String response) {
    final cleanResponse = response.trim();

    // Try to find JSON in code blocks
    final codeBlockMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(cleanResponse);
    if (codeBlockMatch != null) {
      return codeBlockMatch.group(1);
    }

    final blockMatch = RegExp(r'```\s*([\s\S]*?)\s*```').firstMatch(cleanResponse);
    if (blockMatch != null) {
      return blockMatch.group(1);
    }

    // Try to parse as-is
    try {
      json.decode(cleanResponse);
      return cleanResponse;
    } catch (_) {
      // Try to find array pattern
      final arrayMatch = RegExp(r'\[\s*\{[\s\S]*\}\s*\]').firstMatch(cleanResponse);
      return arrayMatch?.group(0);
    }
  }

  /// Get top scent families from history
  List<PerfumeNote> _getTopNotes(List<PerfumeRecord> history) {
    final noteCount = <PerfumeNote, int>{};
    for (final record in history) {
      noteCount[record.noteType] = (noteCount[record.noteType] ?? 0) + 1;
    }
    final sorted = noteCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Get top scenes from history
  List<String> _getTopScenes(List<PerfumeRecord> history) {
    final sceneCount = <String, int>{};
    for (final record in history) {
      sceneCount[record.scene.displayName] = (sceneCount[record.scene.displayName] ?? 0) + 1;
    }
    final sorted = sceneCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Fallback recommendations when AI fails
  List<Map<String, dynamic>> _getFallbackRecommendations(
    UsageScene scene,
    TimeOfDayType timeOfDay,
    Season season,
  ) {
    final recommendationsMap = {
      UsageScene.date: [
        {
          'name': 'Rose Romance',
          'brand': 'Floral Maison',
          'note': PerfumeNote.floral,
          'reason': 'A romantic floral perfect for special occasions',
        },
        {
          'name': 'Midnight Orchid',
          'brand': 'Oriental Dreams',
          'note': PerfumeNote.oriental,
          'reason': 'Warm and inviting for evening dates',
        },
      ],
      UsageScene.work: [
        {
          'name': 'Fresh Aura',
          'brand': 'Clean Scents',
          'note': PerfumeNote.fresh,
          'reason': 'Light and professional for office settings',
        },
        {
          'name': 'Citrus Burst',
          'brand': 'Zest Co',
          'note': PerfumeNote.citrus,
          'reason': 'Energizing citrus notes for productive days',
        },
      ],
      UsageScene.casual: [
        {
          'name': 'Vanilla Dreams',
          'brand': 'Sweet Scents',
          'note': PerfumeNote.gourmand,
          'reason': 'Comforting gourmand for relaxed outings',
        },
      ],
      UsageScene.party: [
        {
          'name': 'Spice Night',
          'brand': 'Bold Fragrances',
          'note': PerfumeNote.spicy,
          'reason': 'Bold spicy notes stand out at parties',
        },
      ],
      UsageScene.sports: [
        {
          'name': 'Sport Fresh',
          'brand': 'Active Scents',
          'note': PerfumeNote.fresh,
          'reason': 'Light and refreshing for active moments',
        },
      ],
      UsageScene.formal: [
        {
          'name': 'Elegant Wood',
          'brand': 'Luxury Fragrances',
          'note': PerfumeNote.woody,
          'reason': 'Sophisticated woody notes for formal events',
        },
      ],
      UsageScene.relaxation: [
        {
          'name': 'Calm Lavender',
          'brand': 'Zen Scents',
          'note': PerfumeNote.fresh,
          'reason': 'Soothing notes for peaceful moments',
        },
      ],
    };

    final sceneRecs = recommendationsMap[scene] ?? recommendationsMap[UsageScene.casual]!;
    final results = <Map<String, dynamic>>[];

    for (final rec in sceneRecs.take(3)) {
      results.add({
        ...rec,
        'scene': scene.displayName,
        'timeOfDay': timeOfDay.displayName,
        'season': season.displayName,
      });
    }

    return results;
  }

  /// Generate review summary (monthly, quarterly, yearly)
  Future<Map<String, dynamic>> generateReview({
    required DateTime startDate,
    required DateTime endDate,
    required List<PerfumeRecord> records,
  }) async {
    // Placeholder: Simulate review generation
    await Future.delayed(const Duration(seconds: 1));

    final filteredRecords = records.where((r) {
      return r.createdAt.isAfter(startDate) && r.createdAt.isBefore(endDate);
    }).toList();

    if (filteredRecords.isEmpty) {
      return {
        'totalUses': 0,
        'favoritePerfume': null,
        'topNote': null,
        'averageRating': 0.0,
        'highlights': <String>[],
      };
    }

    final noteCount = <PerfumeNote, int>{};
    var totalRating = 0;
    var totalCompliments = 0;
    final perfumeCount = <String, int>{};

    for (final record in filteredRecords) {
      noteCount[record.noteType] = (noteCount[record.noteType] ?? 0) + 1;
      totalRating += record.moodRating;
      totalCompliments += record.compliments ?? 0;

      final key = '${record.brand} ${record.perfumeName}';
      perfumeCount[key] = (perfumeCount[key] ?? 0) + 1;
    }

    final topNote = noteCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedPerfumes = perfumeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highlights = <String>[];
    if (totalCompliments > 0) {
      highlights.add('Received $totalCompliments compliments!');
    }
    if (totalRating >= filteredRecords.length * 4) {
      highlights.add('Excellent mood ratings this period');
    }

    return {
      'totalUses': filteredRecords.length,
      'favoritePerfume': sortedPerfumes.first.key,
      'topNote': topNote.first.key.displayName,
      'averageRating': totalRating / filteredRecords.length,
      'highlights': highlights,
    };
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
