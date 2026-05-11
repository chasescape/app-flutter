class LashStyle {
  final String id;
  final String name;
  final String description;
  final String length;
  final String curl;
  final String makeup;

  LashStyle({
    required this.id,
    required this.name,
    required this.description,
    required this.length,
    required this.curl,
    required this.makeup,
  });

  static List<LashStyle> get presetStyles => [
    LashStyle(
      id: 'natural',
      name: 'Natural',
      description: 'Natural everyday look',
      length: 'Medium',
      curl: 'J-Curl',
      makeup: 'Natural',
    ),
    LashStyle(
      id: 'glamour',
      name: 'Glamour',
      description: 'Bold and glamorous',
      length: 'Long',
      curl: 'C-Curl',
      makeup: 'Dramatic',
    ),
    LashStyle(
      id: 'doll',
      name: 'Doll',
      description: 'Sweet doll-like eyes',
      length: 'Extra Long',
      curl: 'D-Curl',
      makeup: 'Doll',
    ),
  ];
}
