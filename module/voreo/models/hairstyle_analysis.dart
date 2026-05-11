import 'hairstyle_result.dart';

class HairstyleAnalysis {
  final String mainStyleName;
  final String whyItFits;
  final List<StyleSuggestion> alternativeSuggestions;
  final String barberNote;

  const HairstyleAnalysis({
    required this.mainStyleName,
    required this.whyItFits,
    required this.alternativeSuggestions,
    required this.barberNote,
  });

  factory HairstyleAnalysis.fromJson(Map<String, dynamic> json) {
    final suggestions = (json['alternativeSuggestions'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(StyleSuggestion.fromJson)
            .where((item) => item.styleName.trim().isNotEmpty)
            .toList() ??
        const <StyleSuggestion>[];

    final whyItFits = _readString(json['whyItFits']);

    return HairstyleAnalysis(
      mainStyleName: _readString(
        json['mainStyleName'],
        fallback: 'AI Generated Style',
      ),
      whyItFits: whyItFits.isNotEmpty
          ? whyItFits
          : 'AI analysis generated a hairstyle direction based on your selfie.',
      alternativeSuggestions: suggestions,
      barberNote: _readString(
        json['barberNote'],
        fallback: whyItFits,
      ),
    );
  }

  static String _readString(dynamic value, {String fallback = ''}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }
}
