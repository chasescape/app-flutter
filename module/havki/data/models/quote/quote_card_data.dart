import 'package:havki/gen_a/A.dart';

/// Simplified quote card data model
class QuoteCardData {
  final String assetImg;
  final String quote;
  final String author;

  QuoteCardData({
    required this.assetImg,
    required this.quote,
    required this.author,
  });
}

/// Simplified scene analysis model
class SceneAnalysis {
  final String location;
  final String description;

  SceneAnalysis({
    required this.location,
    required this.description,
  });
}

/// Simplified visual elements model
class VisualElements {
  final String colorTone;
  final String atmosphere;

  VisualElements({
    required this.colorTone,
    required this.atmosphere,
  });
}

/// Simplified quote card model
class QuoteCard {
  final String quote;
  final String author;

  QuoteCard({
    required this.quote,
    required this.author,
  });
}
